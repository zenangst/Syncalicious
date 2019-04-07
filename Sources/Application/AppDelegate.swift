import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, BackupControllerDelegate, ApplicationControllerDelegate {
  var window: NSWindow?
  var dependencyContainer: DependencyContainer?
  var mainViewController: ApplicationItemViewController?
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

      let layout = NSCollectionViewFlowLayout()
      layout.itemSize = .init(width: 250, height: 80)

      let dependencyContainer = try createDependencyContainer()
      let locations = try dependencyContainer.applicationController.applicationDirectories()
      let viewController = ApplicationItemViewController(layout: layout, iconStore: dependencyContainer)

      let window = createWindow(with: viewController)

      self.mainViewController = viewController
      self.mainMenuController?.dependencyContainer = dependencyContainer
      self.window = window
      self.dependencyContainer = dependencyContainer

      dependencyContainer.applicationController.loadApplications(at: locations)

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
    let iconController = IconController()
    let dependencyContainer = DependencyContainer(applicationController: applicationController,
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
    dependencyContainer?.backupController.applications = applications

    let models = applications
      .sorted(by: { $0.propertyList.bundleName < $1.propertyList.bundleName })
      .compactMap({
        ApplicationItemModel(data: [
          "title": $0.propertyList.bundleName,
          "subtitle": $0.propertyList.bundleIdentifier,
          "bundleIdentifier": $0.propertyList.bundleIdentifier,
          "path": $0.path,
          "enabled": true
          ])
    })

    mainViewController?.reload(with: models)

    debugPrint("Loaded \(applications.count) applications.")
  }
}
