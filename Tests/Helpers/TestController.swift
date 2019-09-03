import Foundation
@testable import Syncalicious

enum TestControllerError: Error {
  case unableToFindEnvironmentPath
}

class TestController {
  var environmentUrl: URL

  var applicationUrl: URL { return environmentUrl.appendingPathComponent("Applications") }
  var backupUrl: URL { return environmentUrl.appendingPathComponent("Backup") }
  var syncUrl: URL { return environmentUrl.appendingPathComponent("Sync") }

  required init() throws {
    guard let environmentPath = ProcessInfo.processInfo.environment["EnvironmentPath"] else {
      throw TestControllerError.unableToFindEnvironmentPath
    }
    self.environmentUrl = URL(string: "file://" + environmentPath)!
  }

  func createApplicationController() -> ApplicationController {
    let shellController = ShellController()
    let libraryDirectory = environmentUrl.appendingPathComponent("Library")
    let preferencesController = PreferencesController(libraryDirectory: libraryDirectory)
    let infoPlistController = InfoPropertyListController()
    let operationController = OperationController()
    let iconController = IconController()
    let notificationContorller = NotificationController(iconController: iconController)
    let applicationController = ApplicationController(queue: nil,
                                                      infoPlistController: infoPlistController,
                                                      notificationController: notificationContorller,
                                                      operationController: operationController,
                                                      operationFactory: OperationFactory(shellController: shellController),
                                                      preferencesController: preferencesController,
                                                      shellController: shellController)

    return applicationController
  }
}
