import Cocoa

class WindowFactory {
  weak var dependencyContainer: DependencyContainer!
  weak var layoutFactory: CollectionViewLayoutFactory!
  weak var viewControllerFactory: ViewControllerFactory!

  init(dependencyContainer: DependencyContainer,
       layoutFactory: CollectionViewLayoutFactory,
       viewControllerFactory: ViewControllerFactory) {
    self.dependencyContainer = dependencyContainer
    self.layoutFactory = layoutFactory
    self.viewControllerFactory = viewControllerFactory
  }

  func createMainWindow() -> MainWindow {
    let window = MainWindow()
    window.loadWindow()
    return window
  }

  func createMainWindowControllers() -> (NSWindowController, ApplicationListFeatureViewController, ApplicationDetailFeatureViewController) {
    let window = createMainWindow()
    let layout = layoutFactory.createApplicationListLayout()
    let listViewController = viewControllerFactory.createApplicationListFeatureViewController(with: layout)
    listViewController.containerViewController.listViewController.collectionView.delegate = listViewController

    let sidebarItem = NSSplitViewItem(contentListWithViewController: listViewController)
    sidebarItem.holdingPriority = .init(rawValue: 260)
    sidebarItem.minimumThickness = 260
    sidebarItem.maximumThickness = sidebarItem.minimumThickness
    sidebarItem.canCollapse = true

    let detailViewController = viewControllerFactory.createApplicationDetailFeatureViewController()
    listViewController.delegate = detailViewController

    let detailControllerItem = NSSplitViewItem(viewController: detailViewController)
    detailControllerItem.minimumThickness = 320
    detailControllerItem.canCollapse = false

    let windowController = WindowController(window: window,
                                            with: [sidebarItem, detailControllerItem])
    let bundleName = (Bundle.main.infoDictionary?["CFBundleName"] as? String) ?? "Syncalicious"
    let frameAutosaveName = "\(bundleName)MainWindow"
    windowController.windowFrameAutosaveName = NSWindow.FrameAutosaveName.init(frameAutosaveName)

    return (windowController, listViewController, detailViewController)
  }

  func createAlert(with text: String = "", error: Error? = nil) -> NSAlert {
    let alert: NSAlert
    if let error = error {
      alert = NSAlert(error: error)
    } else {
      alert = NSAlert()
      alert.messageText = text
    }

    alert.alertStyle = .warning
    alert.addButton(withTitle: "Ok")

    return alert
  }
}
