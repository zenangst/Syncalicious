import Foundation

class DependencyContainer {
  let applicationController: ApplicationController
  let backupController: BackupController
  private let infoPlistController: InfoPropertyListController
  private let machineController: MachineController
  private let preferencesController: PreferencesController

  init(applicationController: ApplicationController,
       backupController: BackupController,
       infoPlistController: InfoPropertyListController,
       machineController: MachineController,
       preferencesController: PreferencesController) {
    self.infoPlistController = InfoPropertyListController()
    self.machineController = machineController
    self.preferencesController = preferencesController
    self.backupController = backupController
    self.applicationController = applicationController
  }
}
