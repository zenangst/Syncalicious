import Cocoa

class ViewControllerFactory {
  weak var dependencyContainer: DependencyContainer!

  init(dependencyContainer: DependencyContainer) {
    self.dependencyContainer = dependencyContainer
  }

  func createApplicationListFeatureViewController(with layout: NSCollectionViewFlowLayout) -> ListFeatureViewController {
    let iconController = dependencyContainer.iconController
    let listViewController = ApplicationListItemViewController(layout: layout,
                                                               iconController: dependencyContainer.iconController)
    let searchViewController = ListSearchViewController()
    let sortViewController = ListSortViewController()
    let containerViewController = ListContainerViewController(listViewController: listViewController,
                                                              searchViewController: searchViewController,
                                                              sortViewController: sortViewController)
    let featureViewController = ListFeatureViewController(containerViewController: containerViewController,
                                                          iconController: iconController,
                                                          machineController: dependencyContainer.machineController,
                                                          syncController: dependencyContainer.syncController)
    return featureViewController
  }

  func createApplicationDetailFeatureViewController() -> DetailFeatureViewController {
    let applicationController = dependencyContainer.applicationController
    let backupController = dependencyContainer.backupController
    let layoutFactory = dependencyContainer.layoutFactory
    let machineController = dependencyContainer.machineController
    let iconController = dependencyContainer.iconController
    let syncController = dependencyContainer.syncController

    let actionsViewController = GeneralActionsViewController()
    let applicationsDetailViewController = ApplicationDetailItemViewController(layout: layoutFactory.createApplicationsLayout(),
                                                                               iconController: iconController)
    let applicationInfoViewController = GeneralInfoViewController()
    let computersViewController = ComputerDetailItemViewController(title: "Computers",
                                                                   layout: layoutFactory.createComputerLayout(),
                                                                   iconController: iconController)
    let containerViewController = DetailContainerViewController(generalActionsViewController: actionsViewController,
                                                                generalInfoViewController: applicationInfoViewController,
                                                                computersViewController: computersViewController,
                                                                applicationsDetailViewController: applicationsDetailViewController)
    let featureViewController = DetailFeatureViewController(applicationController: applicationController,
                                                            backupController: backupController,
                                                            containerViewController: containerViewController,
                                                            iconController: iconController,
                                                            machineController: machineController,
                                                            syncController: syncController)
    return featureViewController
  }
}
