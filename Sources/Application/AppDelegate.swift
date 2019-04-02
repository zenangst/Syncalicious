import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  var window: NSWindow?
  var dependencyContainer: DependencyContainer?
  @IBOutlet var mainMenuController: MainMenuController?

  // MARK: - NSApplicationDelegate

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    loadInjection()
    loadApplication()
  }

  // MARK: - Private methods

  private func loadInjection() {
    Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/macOSInjection.bundle")?.load()
  }

  private func loadApplication() {
    do {
      let window = createWindow()
      window.makeKeyAndOrderFront(nil)
      let dependencyContainer = try createDependencyContainer()
      let locations = try dependencyContainer.applicationController.applicationDirectories()
      dependencyContainer.applicationController.loadApplications(at: locations)
      self.mainMenuController?.dependencyContainer = dependencyContainer
      self.window = window
      self.dependencyContainer = dependencyContainer
    } catch let error {
      let alert = NSAlert(error: error)
      alert.runModal()
    }
  }

  private func createWindow() -> NSWindow {
    let window = NSWindow()
    window.setFrameAutosaveName(Bundle.main.bundleIdentifier!)
    return window
  }

  private func createDependencyContainer() throws -> DependencyContainer {
    let machineController = try MachineController(host: Host.current())
    let infoPlistController = InfoPropertyListController()
    let preferencesController = PreferencesController()
    let applicationController = ApplicationController(infoPlistController: infoPlistController,
                                                      preferencesController: preferencesController)
    let backupController = BackupController(machineController: machineController)
    let dependencyContainer = DependencyContainer(applicationController: applicationController,
                                                  backupController: backupController,
                                                  infoPlistController: infoPlistController,
                                                  machineController: machineController,
                                                  preferencesController: preferencesController)

    applicationController.delegate = backupController

    return dependencyContainer
  }
}

