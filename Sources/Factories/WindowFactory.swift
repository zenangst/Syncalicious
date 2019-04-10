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

  func createMainWindowControllers() -> (NSWindowController, ApplicationItemViewController) {
    let window = createMainWindow()
    let layout = layoutFactory.createApplicationListLayout()
    let listViewController = viewControllerFactory.createApplicationListViewController(with: layout)

    let sidebarItem = NSSplitViewItem(contentListWithViewController: listViewController)
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

    return (windowController, listViewController)
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
