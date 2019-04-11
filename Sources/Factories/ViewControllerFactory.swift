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
    let sync = UserDefaults.standard.backupDestination!
    let syncController = SyncController(applicationController: dependencyContainer.applicationController, destination: sync.appendingPathComponent("Sync"))
    let applicationInfoViewController = ApplicationInfoViewController(backupController: dependencyContainer.backupController)
    let containerViewController = ApplicationContainerViewController(applicationInfoViewController: applicationInfoViewController,
                                                                     backupController: dependencyContainer.backupController,
                                                                     machineController: dependencyContainer.machineController,
                                                                     syncController: syncController)
    return containerViewController
  }
}
