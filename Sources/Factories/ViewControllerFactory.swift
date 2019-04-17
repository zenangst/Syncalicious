import Cocoa

class ViewControllerFactory {
  weak var dependencyContainer: DependencyContainer!

  init(dependencyContainer: DependencyContainer) {
    self.dependencyContainer = dependencyContainer
  }

  func createApplicationListViewController(with layout: NSCollectionViewFlowLayout) -> ApplicationListFeatureViewController {
    let listViewController = ApplicationListItemViewController(layout: layout, iconStore: dependencyContainer)
    let searchViewController = ApplicationListSearchViewController()
    let containerViewController = ApplicationListContainerViewController(listViewController: listViewController,
                                                                         searchViewController: searchViewController)
    let featureViewController = ApplicationListFeatureViewController(containerViewController: containerViewController)
    return featureViewController
  }

  // swiftlint:disable line_length
  func createApplicationDetailViewController() -> ApplicationDetailContainerViewController {
    let iconController = dependencyContainer.iconController
    let applicationInfoViewController = ApplicationDetailInfoViewController(backupController: dependencyContainer.backupController,
                                                                      iconController: iconController,
                                                                      machine: dependencyContainer.machineController.machine,
                                                                      syncController: dependencyContainer.syncController)
    let containerViewController = ApplicationDetailContainerViewController(applicationInfoViewController: applicationInfoViewController,
                                                                     backupController: dependencyContainer.backupController,
                                                                     machineController: dependencyContainer.machineController,
                                                                     syncController: dependencyContainer.syncController)
    return containerViewController
  }
}
