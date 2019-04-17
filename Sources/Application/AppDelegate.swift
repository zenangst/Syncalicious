import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, BackupControllerDelegate, ApplicationControllerDelegate {
  var window: NSWindow?
  var dependencyContainer: DependencyContainer?
  var listFeatureViewController: ApplicationListFeatureViewController?
  @IBOutlet var mainMenuController: MainMenuController?

  // MARK: - NSApplicationDelegate

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    guard NSClassFromString("XCTestCase") == nil else { return }
    #if DEBUG
    loadInjection()
    #endif
    loadApplication()
  }

  // MARK: - Private methods

  private func loadInjection() {
    Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/macOSInjection.bundle")?.load()
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(injected(_:)),
      name: NSNotification.Name(rawValue: "INJECTION_BUNDLE_NOTIFICATION"),
      object: nil
    )
  }

  @objc func injected(_ notification: Notification) {
    loadApplication()
  }

  private func loadApplication() {
    do {
      let previousFrame = self.window?.frame
      self.window?.close()
      self.window = nil

      let dependencyContainer = try createDependencyContainer()
      let locations = try dependencyContainer.applicationController.applicationDirectories()
      let (windowController, listFeatureViewController) = dependencyContainer.windowFactory.createMainWindowControllers()
      self.listFeatureViewController = listFeatureViewController
      self.mainMenuController?.dependencyContainer = dependencyContainer
      self.mainMenuController?.listContainerViewController = listFeatureViewController.containerViewController
      self.window = windowController.window
      self.dependencyContainer = dependencyContainer

      dependencyContainer.applicationController.loadApplications(at: locations)

      windowController.showWindow(nil)
      if let previousFrame = previousFrame {
        windowController.window?.setFrame(previousFrame, display: true)
      }
    } catch let error {
      let alert = NSAlert(error: error)
      alert.runModal()
    }
  }

  private func createDependencyContainer() throws -> DependencyContainer {
    guard let backupDestination = UserDefaults.standard.backupDestination else {
      throw DependencyContainerError.noBackupDestination
    }

    let libraryDirectory = try FileManager.default.url(for: .libraryDirectory,
                                                       in: .userDomainMask,
                                                       appropriateFor: nil,
                                                       create: false)
    let machineController = try MachineController(host: Host.current())
    let infoPlistController = InfoPropertyListController()
    let preferencesController = PreferencesController(libraryDirectory: libraryDirectory)
    let queue = DispatchQueue(label: String(describing: ApplicationController.self),
                              qos: .userInitiated)
    let applicationController = ApplicationController(queue: queue,
                                                      infoPlistController: infoPlistController,
                                                      preferencesController: preferencesController)
    let backupController = BackupController(machineController: machineController)
    let iconController = IconController()
    let syncController = SyncController(destination: backupDestination.appendingPathComponent("Sync"),
                                        machine: machineController.machine)
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

  // MARK: - BackupControllerDelegate

  func backupController(_ controller: BackupController, didSelectDestination destination: URL) {
    UserDefaults.standard.backupDestination = destination
  }

  // MARK: - ApplicationControllerDelegate

  func applicationController(_ controller: ApplicationController,
                             didLoadApplications applications: [Application]) {
    dependencyContainer?.syncController.applications = applications
    dependencyContainer?.backupController.applications = applications
    listFeatureViewController?.render(applications: applications)

    debugPrint("Loaded \(applications.count) applications.")
  }
}
