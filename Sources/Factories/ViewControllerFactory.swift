import Cocoa

class ViewControllerFactory {
  weak var dependencyContainer: DependencyContainer!

  init(dependencyContainer: DependencyContainer) {
    self.dependencyContainer = dependencyContainer
  }

  func createApplicationListFeatureViewController(with layout: NSCollectionViewFlowLayout) -> ApplicationListFeatureViewController {
    let iconController = dependencyContainer.iconController
    let listViewController = ApplicationListItemViewController(layout: layout,
                                                               iconController: dependencyContainer.iconController)
    let searchViewController = ApplicationListSearchViewController()
    let sortViewController = ApplicationListSortViewController()
    let containerViewController = ApplicationListContainerViewController(listViewController: listViewController,
                                                                         searchViewController: searchViewController,
                                                                         sortViewController: sortViewController)
    let featureViewController = ApplicationListFeatureViewController(containerViewController: containerViewController,
                                                                     iconController: iconController,
                                                                     machineController: dependencyContainer.machineController,
                                                                     syncController: dependencyContainer.syncController)
    return featureViewController
  }

  func createApplicationDetailFeatureViewController() -> ApplicationDetailFeatureViewController {
    let applicationController = dependencyContainer.applicationController
    let backupController = dependencyContainer.backupController
    let layoutFactory = dependencyContainer.layoutFactory
    let machineController = dependencyContainer.machineController
    let iconController = dependencyContainer.iconController
    let syncController = dependencyContainer.syncController
    let keyboardController = dependencyContainer.keyboardController

    let actionsViewController = ApplicationActionsViewController()
    let applicationsDetailViewController = ApplicationDetailItemViewController(layout: layoutFactory.createApplicationsLayout(),
                                                                               iconController: iconController)
    let applicationInfoViewController = ApplicationInfoViewController()
    let computersViewController = ApplicationComputerDetailItemViewController(title: "Computers",
                                                                              layout: layoutFactory.createComputerLayout(),
                                                                              iconController: iconController)
    let keyboardViewController = ApplicationKeyboardBindingViewController(title: "Keyboard shortcuts",
                                                                          layout: layoutFactory.createKeyboardShortcutLayout(),
                                                                          iconController: iconController,
                                                                          keyboardController: keyboardController)
    let keyboardShortcutActionsViewController = ApplicationKeyboardActionsViewController()
    let containerViewController = ApplicationDetailContainerViewController(actionsViewController: actionsViewController,
                                                                           applicationInfoViewController: applicationInfoViewController,
                                                                           applicationComputersViewController: computersViewController,
                                                                           applicationsDetailViewController: applicationsDetailViewController,
                                                                           keyboardShortcutViewController: keyboardViewController,
                                                                           keyboardShortcutActionsViewController: keyboardShortcutActionsViewController)
    let featureViewController = ApplicationDetailFeatureViewController(applicationController: applicationController,
                                                                       backupController: backupController,
                                                                       containerViewController: containerViewController,
                                                                       iconController: iconController,
                                                                       keyboardController: keyboardController,
                                                                       machineController: machineController,
                                                                       syncController: syncController)
    return featureViewController
  }
}
