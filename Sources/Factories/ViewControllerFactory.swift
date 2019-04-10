import Cocoa

class ViewControllerFactory {
  weak var dependencyContainer: DependencyContainer!

  init(dependencyContainer: DependencyContainer) {
    self.dependencyContainer = dependencyContainer
  }

  func createApplicationListViewController(with layout: NSCollectionViewFlowLayout) -> ApplicationItemViewController {
    let viewController = ApplicationItemViewController(layout: layout, iconStore: dependencyContainer)
    viewController.view.wantsLayer = true
    viewController.view.layer?.backgroundColor = NSColor.white.cgColor
    viewController.title = Bundle.main.infoDictionary?["CFBundleName"] as? String

    return viewController
  }

  func createApplicationDetailViewController() -> ApplicationContainerViewController {
    let detailViewController = ApplicationInfoViewController()
    let containerViewController = ApplicationContainerViewController(detailViewController: detailViewController)
    return containerViewController
  }
}
