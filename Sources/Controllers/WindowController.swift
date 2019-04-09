import Cocoa

class WindowController: NSWindowController {

  lazy var splitViewController = SplitViewController()

  required init(window: MainWindow?, with items: [NSSplitViewItem]) {
    super.init(window: window)
    items.forEach { splitViewController.addSplitViewItem($0) }
    window?.contentViewController = splitViewController
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
