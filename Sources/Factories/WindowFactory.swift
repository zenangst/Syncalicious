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
    window.setFrameAutosaveName(Bundle.main.bundleIdentifier!)
    return window
  }

  func createMainWindowControllers() -> (NSWindowController, ApplicationListFeatureViewController) {
    let window = createMainWindow()
    let layout = layoutFactory.createApplicationListLayout()
    let listFeatureViewController = viewControllerFactory.createApplicationListViewController(with: layout)

    let sidebarItem = NSSplitViewItem(contentListWithViewController: listFeatureViewController)
    sidebarItem.holdingPriority = .init(rawValue: 260)
    sidebarItem.minimumThickness = 260
    sidebarItem.maximumThickness = sidebarItem.minimumThickness
    sidebarItem.canCollapse = true

    let detailViewController = viewControllerFactory.createApplicationDetailViewController()
    detailViewController.view.wantsLayer = true
    detailViewController.view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
    detailViewController.title = "Customize"
    detailViewController.listViewController = listFeatureViewController.containerViewController.listViewController
    listFeatureViewController.containerViewController.listViewController.collectionView.delegate = detailViewController

    let detailControllerItem = NSSplitViewItem(viewController: detailViewController)
    detailControllerItem.minimumThickness = 320
    detailControllerItem.canCollapse = false

    let windowController = WindowController(window: window,
                                            with: [sidebarItem, detailControllerItem])

    return (windowController, listFeatureViewController)
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
