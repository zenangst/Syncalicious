import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, BackupControllerDelegate, ApplicationControllerDelegate, FirstLaunchViewControllerDelegate {
  var firstLaunchViewController: FirstLaunchViewController?
  var windowController: NSWindowController?
  var statusItem: NSStatusItem?
  var dependencyContainer: DependencyContainer?
  var listFeatureViewController: ApplicationListFeatureViewController?
  @IBOutlet var statusMenu: NSMenu!
  @IBOutlet var mainMenuController: MainMenuController?

  // MARK: - NSApplicationDelegate

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    guard NSClassFromString("XCTestCase") == nil else { return }
    #if DEBUG
    loadInjection()
    #endif
    do { try loadApplication() }
    catch let error {
      let alert = NSAlert(error: error)
      alert.runModal()
    }
  }

  // MARK: - Private methods

  private func loadInjection() {
    Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/macOSInjection.bundle")?.load()
  }

  @objc func injected() {
    do { try loadApplication() }
    catch let error {
      let alert = NSAlert(error: error)
      alert.runModal()
    }
  }

  func loadApplication() throws {
    if UserDefaults.standard.backupDestination == nil {
      NSApplication.shared.windows.forEach { $0.close() }

      let machineController = try MachineController(host: Host.current())
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

      configureStatusMenu()

      let dependencyContainer = try createDependencyContainer()
      let locations = try dependencyContainer.applicationController.applicationDirectories()
      let (windowController, listFeatureViewController) = dependencyContainer.windowFactory.createMainWindowControllers()
      self.listFeatureViewController = listFeatureViewController
      self.mainMenuController?.appDelegate = self
      self.mainMenuController?.dependencyContainer = dependencyContainer
      self.mainMenuController?.listContainerViewController = listFeatureViewController.containerViewController
      self.windowController = windowController
      self.dependencyContainer = dependencyContainer

      dependencyContainer.applicationController.loadApplications(at: locations)

      #if DEBUG
      windowController.showWindow(nil)
      if let previousFrame = previousFrame {
        windowController.window?.setFrame(previousFrame, display: true)
      }
      #endif
    }
  }

  private func configureStatusMenu() {
    let statusBar = NSStatusBar.system
    let statusItem = statusBar.statusItem(withLength: statusBar.thickness)
    statusItem.button?.image = NSImage(named: "StatusMenu")
    statusItem.button?.toolTip = "Syncalicious"
    statusItem.button?.isEnabled = true
    statusItem.menu = statusMenu
    self.statusItem = statusItem
  }

  private func createDependencyContainer() throws -> DependencyContainer {
    guard let backupDestination = UserDefaults.standard.backupDestination else {
      throw DependencyContainerError.noBackupDestination
    }

    let libraryDirectory = try FileManager.default.url(for: .libraryDirectory,
                                                       in: .userDomainMask,
                                                       appropriateFor: nil,
                                                       create: false)
    let shellController = ShellController()
    let machineController = try MachineController(host: Host.current())
    let infoPlistController = InfoPropertyListController()
    let preferencesController = PreferencesController(libraryDirectory: libraryDirectory)
    let queue = DispatchQueue(label: String(describing: ApplicationController.self),
                              qos: .userInitiated)
    let applicationController = ApplicationController(queue: queue,
                                                      infoPlistController: infoPlistController,
                                                      preferencesController: preferencesController,
                                                      shellController: shellController)
    let backupController = BackupController(machineController: machineController)
    let iconController = IconController()
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

  func firstLaunchViewController(_ controller: FirstLaunchViewController,
                                 didPressDoneButton button: NSButton) {
    controller.view.window?.close()
    do { try loadApplication() }
    catch let error {
      let alert = NSAlert(error: error)
      alert.runModal()
    }
    windowController?.showWindow(nil)
  }

  // MARK: - BackupControllerDelegate

  func backupController(_ controller: BackupController,
                        didSelectDestination destination: URL) {
    UserDefaults.standard.backupDestination = destination
    firstLaunchViewController?.backupController(controller, didSelectDestination: destination)
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
