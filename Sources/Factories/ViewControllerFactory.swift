import Cocoa

class ViewControllerFactory {
  weak var dependencyContainer: DependencyContainer!

  init(dependencyContainer: DependencyContainer) {
    self.dependencyContainer = dependencyContainer
  }

  func createApplicationListViewController(with layout: NSCollectionViewFlowLayout) -> ApplicationListFeatureViewController {
    let listViewController = ApplicationListItemViewController(layout: layout, iconStore: dependencyContainer)
    let searchViewController = ApplicationListSearchViewController()
    let sortViewController = ApplicationListSortViewController()
    let containerViewController = ApplicationListContainerViewController(listViewController: listViewController,
                                                                         searchViewController: searchViewController,
                                                                         sortViewController: sortViewController)
    let featureViewController = ApplicationListFeatureViewController(containerViewController: containerViewController,
                                                                     machineController: dependencyContainer.machineController,
                                                                     syncController: dependencyContainer.syncController)
    return featureViewController
  }

  // swiftlint:disable line_length
  func createApplicationDetailViewController() -> ApplicationDetailFeatureViewController {
    let iconController = dependencyContainer.iconController
    let applicationInfoViewController = ApplicationDetailInfoViewController(backupController: dependencyContainer.backupController,
                                                                      iconController: iconController,
                                                                      machine: dependencyContainer.machineController.machine,
                                                                      syncController: dependencyContainer.syncController)
    let containerViewController = ApplicationDetailContainerViewController()
    let featureViewController = ApplicationDetailFeatureViewController(applicationInfoViewController: applicationInfoViewController,
                                                                       applicationController: dependencyContainer.applicationController,
                                                                       backupController: dependencyContainer.backupController,
                                                                       containerViewController: containerViewController,
                                                                       machineController: dependencyContainer.machineController,
                                                                       syncController: dependencyContainer.syncController)
    return featureViewController
  }
}
