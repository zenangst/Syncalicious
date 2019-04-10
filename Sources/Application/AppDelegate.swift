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
      let windowController = createWindowController(dependencyContainer: dependencyContainer)

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

  private func createWindowController(dependencyContainer: DependencyContainer) -> NSWindowController {
    let layout = NSCollectionViewFlowLayout()
    layout.sectionInset = .init(top: 10, left: 10, bottom: 10, right: 10)
    layout.minimumLineSpacing = 0
    layout.itemSize = .init(width: 250, height: 48)
    let listController = ApplicationItemViewController(layout: layout, iconStore: dependencyContainer)
    listController.view.wantsLayer = true
    listController.view.layer?.backgroundColor = NSColor.white.cgColor
    listController.title = Bundle.main.infoDictionary?["CFBundleName"] as? String

    self.mainViewController = listController

    let window = MainWindow.init()
    window.loadWindow()
    window.setFrameAutosaveName(Bundle.main.bundleIdentifier!)

    Swift.print(layout.itemSize.width + layout.sectionInset.left + layout.sectionInset.right)

    let sidebarItem = NSSplitViewItem(contentListWithViewController: listController)
    sidebarItem.holdingPriority = .init(rawValue: 260)
    sidebarItem.minimumThickness = layout.itemSize.width + layout.sectionInset.left + layout.sectionInset.right
    sidebarItem.maximumThickness = sidebarItem.minimumThickness
    sidebarItem.canCollapse = true

    let detailViewController = ViewController()
    detailViewController.view.wantsLayer = true
    detailViewController.view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
    detailViewController.title = "Customize"

    let detailControllerItem = NSSplitViewItem(viewController: detailViewController)
    detailControllerItem.minimumThickness = 320
    detailControllerItem.canCollapse = false

    let inspectorController = ViewController()
    inspectorController.view.wantsLayer = true
    inspectorController.view.layer?.backgroundColor = NSColor.white.cgColor

    let inspectorControllerItem = NSSplitViewItem(viewController: inspectorController)
    inspectorControllerItem.holdingPriority = .init(rawValue: 260)
    inspectorControllerItem.minimumThickness = 260
    inspectorControllerItem.maximumThickness = 260
    inspectorControllerItem.canCollapse = true

    let windowController = WindowController(window: window,
                                            with: [sidebarItem, detailControllerItem])

    return windowController
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
      .sorted(by: { $0.propertyList.bundleName.lowercased() < $1.propertyList.bundleName.lowercased() })
      .compactMap({
        ApplicationItemModel(data: [
          "title": $0.propertyList.bundleName,
          "subtitle": $0.propertyList.bundleIdentifier,
          "bundleIdentifier": $0.propertyList.bundleIdentifier,
          "path": $0.path,
          "enabled": true
          ])
    })

    if let mainViewController = mainViewController {
      mainViewController.reload(with: models)
      mainViewController.collectionView.selectItems(at: [IndexPath.init(item: 0, section: 0)], scrollPosition: .top)
    }

    debugPrint("Loaded \(applications.count) applications.")
  }
}
