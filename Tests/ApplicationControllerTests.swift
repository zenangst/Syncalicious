import XCTest
@testable import Syncalicious

class ApplicationControllerTests: XCTestCase {
  let testController = try! TestController()

  func testApplicationParsing() {
    let delegate = TestApplicationDelegate()
    let applicationController = testController.createApplicationController()
    applicationController.delegate = delegate
    applicationController.loadApplications(at: [
      testController.environmentUrl.appendingPathComponent("Applications")
    ])

    if delegate.applications.count != 4 {
      XCTAssertEqual(delegate.applications.count, 4)
      return
    }

    XCTAssertEqual(delegate.applications[0].propertyList.bundleIdentifier,
                   "com.zenangst.Syncalicious.TestAppWithSUDefaultsDomain")
    XCTAssertEqual(delegate.applications[1].propertyList.bundleIdentifier,
                   "com.zenangst.Syncalicious.ContainerTestAppSUDefaultsDomain")
    XCTAssertEqual(delegate.applications[2].propertyList.bundleIdentifier,
                   "com.zenangst.Syncalicious.ContainerTestApp")
    XCTAssertEqual(delegate.applications[3].propertyList.bundleIdentifier,
                   "com.zenangst.Syncalicious.TestApp")

  }
}
