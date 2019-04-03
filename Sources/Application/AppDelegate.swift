import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, BackupControllerDelegate {
  var window: NSWindow?
  var dependencyContainer: DependencyContainer?
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
      let window = createWindow(with: ViewController())
      let dependencyContainer = try createDependencyContainer()
      let locations = try dependencyContainer.applicationController.applicationDirectories()
      dependencyContainer.applicationController.loadApplications(at: locations)
      self.mainMenuController?.dependencyContainer = dependencyContainer
      self.window = window
      self.dependencyContainer = dependencyContainer

      window.makeKeyAndOrderFront(nil)
      if let previousFrame = previousFrame {
        window.setFrame(previousFrame, display: true)
      }
    } catch let error {
      let alert = NSAlert(error: error)
      alert.runModal()
    }
  }

  private func createWindow(with viewController: NSViewController) -> NSWindow {
    let window = MainWindow.init(contentViewController: viewController)
    window.loadWindow()
    window.setFrameAutosaveName(Bundle.main.bundleIdentifier!)
    return window
  }

  private func createDependencyContainer() throws -> DependencyContainer {
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
    let dependencyContainer = DependencyContainer(applicationController: applicationController,
                                                  backupController: backupController,
                                                  infoPlistController: infoPlistController,
                                                  machineController: machineController,
                                                  preferencesController: preferencesController)

    backupController.delegate = self
    applicationController.delegate = backupController

    return dependencyContainer
  }

  // MARK: - BackupControllerDelegate

  func backupController(_ controller: BackupController, didSelectDestination destination: URL) {
    UserDefaults.standard.backupDestination = destination
  }
}
