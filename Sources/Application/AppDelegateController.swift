import Cocoa

class ApplicationDelegateController: ApplicationControllerDelegate,
  BackupControllerDelegate,
  FirstLaunchViewControllerDelegate,
  MachineControllerDelegate {

  weak var appDelegate: AppDelegate?
  var firstLaunchViewController: FirstLaunchViewController?
  var windowController: NSWindowController?
  var dependencyContainer: DependencyContainer?
  weak var listFeatureViewController: ApplicationListFeatureViewController?
  weak var detailFeatureViewController: ApplicationDetailFeatureViewController?

  func applicationDidFinishLaunching(with appDelegate: AppDelegate) {
    do {
      try loadApplication()
    } catch let error {
      let alert = NSAlert(error: error)
      alert.runModal()
    }
  }

  func applicationDidResignActive() {
    guard windowController == nil else { return }

    listFeatureViewController = nil
    detailFeatureViewController = nil
    NSApp.dockTile.badgeLabel = nil
    NSApp.setActivationPolicy(.accessory)
  }

  func applicationShouldHandleReopen() -> Bool {
    return true
  }

  // MARK: - Observers

  @objc func mainWindowDidClose() {
    windowController = nil
  }

  @discardableResult
  func loadApplication(file: StaticString = #file, function: StaticString = #function, line: UInt = #line) throws -> NSWindowController? {
    if UserDefaults.standard.syncaliciousUrl == nil {
      NSApplication.shared.windows.forEach { $0.close() }

      let iconController = IconController()
      let machineController = try MachineController(host: Host.current(), iconController: iconController)
      let backupController = BackupController(machineController: machineController)
      let welcomeWindow = WelcomeWindow()
      welcomeWindow.loadWindow()
      let firstLaunchWindowController = NSWindowController(window: welcomeWindow)
      let firstLaunchViewController = FirstLaunchViewController(backupController: backupController)
      firstLaunchViewController.delegate = self
      self.firstLaunchViewController = firstLaunchViewController
      backupController.delegate = self
      firstLaunchWindowController.contentViewController = firstLaunchViewController
      firstLaunchWindowController.showWindow(nil)
      firstLaunchWindowController.window?.center()
    } else {
      let previousFrame = self.windowController?.window?.frame
      self.windowController?.close()
      self.windowController = nil

      let dependencyContainer: DependencyContainer
      if let previousDependencyContainer = self.dependencyContainer {
        dependencyContainer = previousDependencyContainer
      } else {
        dependencyContainer = try createDependencyContainer()
      }

      let locations = try dependencyContainer.applicationController.applicationDirectories()
      let (windowController, listViewController, detailViewController) = dependencyContainer
        .windowFactory
        .createMainWindowControllers()
      self.listFeatureViewController = listViewController
      self.detailFeatureViewController = detailViewController
      self.dependencyContainer = dependencyContainer
      self.windowController = windowController

      try? dependencyContainer.machineController.refreshMachines()
      dependencyContainer.applicationController.loadApplications(at: locations)

      #if DEBUG
      windowController.showWindow(nil)
      if let previousFrame = previousFrame {
        windowController.window?.setFrame(previousFrame, display: true)
      }
      #endif

      return windowController
    }

    return nil
  }

  // MARK: - Private methods

  private func createDependencyContainer() throws -> DependencyContainer {
    guard let backupDestination = UserDefaults.standard.syncaliciousUrl else {
      throw DependencyContainerError.noBackupDestination
    }

    let libraryDirectory = try FileManager.default.url(for: .libraryDirectory,
                                                       in: .userDomainMask,
                                                       appropriateFor: nil,
                                                       create: false)
    let shellController = ShellController()
    let iconController = IconController()
    let machineController = try MachineController(host: Host.current(),
                                                  iconController: iconController)
    try machineController.createMachineInfoDestination(at: backupDestination)
    machineController.delegate = self

    let infoPlistController = InfoPropertyListController()
    let preferencesController = PreferencesController(libraryDirectory: libraryDirectory)
    let queue = DispatchQueue(label: String(describing: ApplicationController.self),
                              qos: .userInitiated)
    let applicationController = ApplicationController(queue: queue,
                                                      infoPlistController: infoPlistController,
                                                      preferencesController: preferencesController,
                                                      shellController: shellController)
    let backupController = BackupController(machineController: machineController)
    let syncController = SyncController(destination: backupDestination.appendingPathComponent("Sync"),
                                        machineController: machineController,
                                        shellController: shellController)
    let dependencyContainer = DependencyContainer(applicationController: applicationController,
                                                  syncController: syncController,
                                                  backupController: backupController,
                                                  iconController: iconController,
                                                  infoPlistController: infoPlistController,
                                                  machineController: machineController,
                                                  preferencesController: preferencesController)

    backupController.delegate = self
    applicationController.delegate = self

    return dependencyContainer
  }

  // MARK: - ApplicationControllerDelegate

  func applicationController(_ controller: ApplicationController,
                             didLoadApplications applications: [Application]) {
    dependencyContainer?.syncController.applications = applications
    dependencyContainer?.backupController.applications = applications
    listFeatureViewController?.render(applications: applications)
  }

  // MARK: - BackupControllerDelegate

  func backupController(_ controller: BackupController,
                        didSelectDestination destination: URL) {
    UserDefaults.standard.syncaliciousUrl = destination
    firstLaunchViewController?.backupController(controller, didSelectDestination: destination)
  }

  func firstLaunchViewController(_ controller: FirstLaunchViewController, didPressDoneButton button: NSButton) {
    controller.view.window?.close()
    do {
      try loadApplication()?.showWindow(nil)
    } catch let error {
      let alert = NSAlert(error: error)
      alert.runModal()
    }
  }

  // MARK: - MachineControllerDelegate

  func machineController(_ controller: MachineController, didChangeState state: Machine.State) {
    guard let dependencyContainer = dependencyContainer else { return }

    dependencyContainer.syncController.machineDidChangeState(newState: state)
    detailFeatureViewController?.refreshCurrentApplicationIfNeeded()

    guard let syncaliciousUrl = UserDefaults.standard.syncaliciousUrl,
      UserDefaults.standard.backupWhenIdle else { return }

    let machine = dependencyContainer.machineController.machine
    let applications = dependencyContainer.syncController.applications

    let backupApplications = applications.filter({ application in
      return dependencyContainer.backupController.doesBackupExists(for: application,
                                                                   on: machine,
                                                                   at: UserDefaults.standard.syncaliciousUrl!) != nil
    })
    try? dependencyContainer.backupController.runBackup(for: backupApplications, to: syncaliciousUrl)
  }

  func machineController(_ controller: MachineController, didUpdateOtherMachines machines: [Machine]) {
    detailFeatureViewController?.machines = machines
  }
}
