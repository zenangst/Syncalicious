import Cocoa

class DependencyContainer: IconStore {
  lazy var layoutFactory = CollectionViewLayoutFactory()
  lazy var viewControllerFactory = ViewControllerFactory(dependencyContainer: self)
  lazy var windowFactory = WindowFactory(dependencyContainer: self,
                                         layoutFactory: layoutFactory,
                                         viewControllerFactory: viewControllerFactory)
  let applicationController: ApplicationController
  let backupController: BackupController
  let iconController: IconController
  private let infoPlistController: InfoPropertyListController
  private let machineController: MachineController
  private let preferencesController: PreferencesController

  init(applicationController: ApplicationController,
       backupController: BackupController,
       iconController: IconController,
       infoPlistController: InfoPropertyListController,
       machineController: MachineController,
       preferencesController: PreferencesController) {
    self.infoPlistController = InfoPropertyListController()
    self.machineController = machineController
    self.preferencesController = preferencesController
    self.backupController = backupController
    self.applicationController = applicationController
    self.iconController = iconController
  }

  // MARK: - IconStore

  func loadIcon(at path: URL, for bundleIdentifier: String, then handler: @escaping (NSImage?) -> Void) {
    DispatchQueue.global(qos: .userInteractive).async { [weak self] in
      guard let strongSelf = self else { return }
      let image = strongSelf.iconController.icon(at: path, for: bundleIdentifier)
      DispatchQueue.main.async { handler(image) }
    }
  }
}

protocol IconStore {
  func loadIcon(at path: URL, for bundleIdentifier: String, then handler: @escaping (NSImage?) -> Void)
}
