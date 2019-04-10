import Cocoa

class ViewControllerFactory {
  weak var dependencyContainer: DependencyContainer!

  init(dependencyContainer: DependencyContainer) {
    self.dependencyContainer = dependencyContainer
  }

  func createApplicationListViewController(with layout: NSCollectionViewFlowLayout) -> ApplicationItemViewController {
    let listViewController = ApplicationItemViewController(layout: layout, iconStore: dependencyContainer)
    listViewController.view.wantsLayer = true
    listViewController.view.layer?.backgroundColor = NSColor.white.cgColor
    listViewController.title = Bundle.main.infoDictionary?["CFBundleName"] as? String

    return listViewController
  }
}
