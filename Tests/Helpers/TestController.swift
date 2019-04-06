import Foundation
@testable import Syncalicious

enum TestControllerError: Error {
  case unableToFindEnvironmentPath
}

class TestController {
  var environmentUrl: URL

  required init() throws {
    guard let environmentPath = ProcessInfo.processInfo.environment["EnvironmentPath"] else {
      throw TestControllerError.unableToFindEnvironmentPath
    }
    self.environmentUrl = URL(string: "file://" + environmentPath)!
  }

  func createApplicationController() -> ApplicationController {
    let libraryDirectory = environmentUrl.appendingPathComponent("Library")
    let preferencesController = PreferencesController(libraryDirectory: libraryDirectory)
    let infoPlistController = InfoPropertyListController()
    let applicationController = ApplicationController(infoPlistController: infoPlistController,
                                                      preferencesController: preferencesController)

    return applicationController
  }
}
