import XCTest
@testable import Syncalicious

class TestController {
  var environmentUrl: URL!

  init() {
    guard let environmentPath = ProcessInfo.processInfo.environment["EnvironmentPath"] else {
      XCTFail("Couldn't find EnvironmentPath")
      return
    }
    environmentUrl = URL(string: environmentPath)!
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
