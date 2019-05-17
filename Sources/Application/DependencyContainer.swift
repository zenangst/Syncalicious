import Cocoa

enum DependencyContainerError: Error {
  case noBackupDestination
}

class DependencyContainer {
  lazy var layoutFactory = CollectionViewLayoutFactory()
  lazy var viewControllerFactory = ViewControllerFactory(dependencyContainer: self)
  lazy var windowFactory = WindowFactory(dependencyContainer: self,
                                         layoutFactory: layoutFactory,
                                         viewControllerFactory: viewControllerFactory)
  let applicationController: ApplicationController
  let backupController: BackupController
  let iconController: IconController
  let machineController: MachineController
  let syncController: SyncController
  let keyboardController: KeyboardController
  let notificationController: NotificationController

  private let infoPlistController: InfoPropertyListController
  private let preferencesController: PreferencesController

  init(applicationController: ApplicationController,
       syncController: SyncController,
       backupController: BackupController,
       iconController: IconController,
       infoPlistController: InfoPropertyListController,
       machineController: MachineController,
       preferencesController: PreferencesController,
       keyboardController: KeyboardController,
       notificationController: NotificationController) {
    self.infoPlistController = infoPlistController
    self.machineController = machineController
    self.preferencesController = preferencesController
    self.backupController = backupController
    self.applicationController = applicationController
    self.syncController = syncController
    self.iconController = iconController
    self.keyboardController = keyboardController
    self.notificationController = notificationController
  }
}
