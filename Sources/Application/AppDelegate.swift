import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, ApplicationControllerDelegate {
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
    let window = createWindow()
    window.makeKeyAndOrderFront(nil)
    let dependencyContainer = createDependencyContainer()
    dependencyContainer.applicationController.delegate = self

    UserDefaults.standard.backupDestination = nil

    do {
      let locations = try dependencyContainer.applicationController.applicationDirectories()
      dependencyContainer.applicationController.loadApplications(at: locations)
    } catch {}

    self.mainMenuController?.dependencyContainer = dependencyContainer
    self.window = window
    self.dependencyContainer = dependencyContainer
  }

  private func createWindow() -> NSWindow {
    let window = NSWindow()
    window.setFrameAutosaveName(Bundle.main.bundleIdentifier!)
    return window
  }

  private func createDependencyContainer() -> DependencyContainer {
    let infoPlistController = InfoPropertyListController()
    let preferencesController = PreferencesController()
    let applicationController = ApplicationController(infoPlistController: infoPlistController,
                                                      preferencesController: preferencesController)
    return DependencyContainer(applicationController: applicationController,
                               infoPlistController: infoPlistController,
                               preferencesController: preferencesController)
  }

  // MARK: - ApplicationControllerDelegate

  func applicationController(_ controller: ApplicationController,
                             didLoadApplications applications: [Application]) {
    debugPrint("Loaded \(applications.count) applications.")
  }
}

