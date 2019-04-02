import Foundation

class DependencyContainer {
  let applicationController: ApplicationController
  let backupController = BackupController()
  private let infoPlistController: InfoPropertyListController
  private let preferencesController: PreferencesController

  init(applicationController: ApplicationController,
       infoPlistController: InfoPropertyListController,
       preferencesController: PreferencesController) {
    self.infoPlistController = InfoPropertyListController()
    self.preferencesController = PreferencesController()
    self.applicationController = ApplicationController(infoPlistController: infoPlistController,
                                                       preferencesController: preferencesController)

  }
}
