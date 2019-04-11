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

      let dependencyContainer = try createDependencyContainer()
      let locations = try dependencyContainer.applicationController.applicationDirectories()
      let (windowController, listController) = dependencyContainer.windowFactory.createMainWindowControllers()
      self.mainViewController = listController
      self.mainMenuController?.dependencyContainer = dependencyContainer
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

    let closure: (Application) -> ApplicationItemModel = { item in
      var subtitle = "\(item.propertyList.versionString)"
      if !item.propertyList.buildVersion.isEmpty && item.propertyList.versionString != item.propertyList.buildVersion {
        subtitle.append(" (\(item.propertyList.buildVersion))")
      }

      return ApplicationItemModel(data: [
        "title": item.propertyList.bundleName,
        "subtitle": subtitle,
        "bundleIdentifier": item.propertyList.bundleIdentifier,
        "path": item.url,
        "enabled": true,
        "model": item
        ])
    }
    let models = applications
      .sorted(by: { $0.propertyList.bundleName.lowercased() < $1.propertyList.bundleName.lowercased() })
      .compactMap(closure)

    if let mainViewController = mainViewController {
      mainViewController.reload(with: models)

      let collectionView = mainViewController.collectionView
      collectionView.selectItems(at: [IndexPath.init(item: 19, section: 0)], scrollPosition: .centeredHorizontally)
      collectionView.delegate?.collectionView?(collectionView, didSelectItemsAt: [IndexPath.init(item: 19, section: 0)])
    }

    debugPrint("Loaded \(applications.count) applications.")
  }
}
