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

  func createApplicationDetailViewController() -> ApplicationDetailFeatureViewController {
    let layoutFactory = dependencyContainer.layoutFactory
    let iconController = dependencyContainer.iconController
    let applicationsDetailViewController = ApplicationDetailItemViewController(layout: layoutFactory.createApplicationsLayout(),
                                                                               iconStore: dependencyContainer)
    let applicationInfoViewController = ApplicationDetailInfoViewController(backupController: dependencyContainer.backupController,
                                                                            iconController: iconController,
                                                                            machine: dependencyContainer.machineController.machine,
                                                                            syncController: dependencyContainer.syncController)

    let computersViewController = ApplicationComputerDetailItemViewController(title: "Computers",
                                                                              layout: layoutFactory.createComputerLayout(),
                                                                              iconStore: dependencyContainer)

    let containerViewController = ApplicationDetailContainerViewController(applicationInfoViewController: applicationInfoViewController,
                                                                           applicationComputersViewController: computersViewController,
                                                                           applicationsDetailViewController: applicationsDetailViewController)
    let featureViewController = ApplicationDetailFeatureViewController(applicationController: dependencyContainer.applicationController,
                                                                       backupController: dependencyContainer.backupController,
                                                                       containerViewController: containerViewController,
                                                                       machineController: dependencyContainer.machineController,
                                                                       syncController: dependencyContainer.syncController)
    return featureViewController
  }
}
