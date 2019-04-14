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

  // swiftlint:disable line_length
  func createApplicationDetailViewController() -> ApplicationContainerViewController {
    let applicationInfoViewController = ApplicationInfoViewController(backupController: dependencyContainer.backupController,
                                                                      machine: dependencyContainer.machineController.machine,
                                                                      syncController: dependencyContainer.syncController)
    let containerViewController = ApplicationContainerViewController(applicationInfoViewController: applicationInfoViewController,
                                                                     backupController: dependencyContainer.backupController,
                                                                     machineController: dependencyContainer.machineController,
                                                                     syncController: dependencyContainer.syncController)
    return containerViewController
  }
}
