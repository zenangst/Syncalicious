import XCTest
@testable import Syncalicious

class SyncControllerTests: XCTestCase {
  let testController = try! TestController()

  override func tearDown() {
    super.tearDown()

    do {
      try FileManager.default.removeItem(at: testController.syncUrl)
    } catch {
      XCTFail("Failed to do cleanup.")
    }
  }

  func testSyncingMachines() {
    let syncUrl = testController.syncUrl
    let applicationController = testController.createApplicationController()
    let delegate = TestApplicationDelegate()

    applicationController.delegate = delegate
    applicationController.loadApplications(at: [testController.applicationUrl])

    let syncController = SyncController(applicationController: applicationController, destination: syncUrl)
    let machineHostA = TestHost(machineName: "MachineA")
    let machineHostB = TestHost(machineName: "MachineB")

    do {
      let machineContorllerA = try MachineController(host: machineHostA)
      let machineContorllerB = try MachineController(host: machineHostB)

      try machineContorllerA.createMachineBackupDestinationIfNeeded(at: syncUrl)
      try machineContorllerB.createMachineBackupDestinationIfNeeded(at: syncUrl)

      // TestApp
      let application = delegate.applications[3]
      let preferensLocation = application.preferences.path.path

      var attributes = try FileManager.default.attributesOfItem(atPath: preferensLocation)
      XCTAssertEqual((attributes as NSDictionary).fileType(), "NSFileTypeRegular")

      try syncController.enableSync(for: application, on: machineContorllerA.machine)
      attributes = try FileManager.default.attributesOfItem(atPath: preferensLocation)
      XCTAssertEqual((attributes as NSDictionary).fileType(), "NSFileTypeSymbolicLink")

      try syncController.disableSync(for: application, on: machineContorllerA.machine)
      attributes = try FileManager.default.attributesOfItem(atPath: preferensLocation)
      XCTAssertEqual((attributes as NSDictionary).fileType(), "NSFileTypeRegular")
    } catch let error {
      XCTFail(error.localizedDescription)
    }
  }
}