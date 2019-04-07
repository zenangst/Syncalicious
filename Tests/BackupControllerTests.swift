import XCTest
@testable import Syncalicious

class BackupControllerTests: XCTestCase {
  let testController = try! TestController()

  override func tearDown() {
    super.tearDown()

    do {
      try FileManager.default.removeItem(at: testController.backupUrl)
    } catch {
      XCTFail("Failed to do cleanup.")
    }
  }

  func testInitializeBackup() throws {
    let delegate = TestApplicationDelegate()
    let host = TestHost(machineName: "BackupMachineTest")
    let applicationController = testController.createApplicationController()
    let machineController = try MachineController(host: host)
    let backupController = BackupController(machineController: machineController)

    let applicationUrl = testController.applicationUrl
    let backupUrl = testController.backupUrl

    applicationController.delegate = delegate
    applicationController.loadApplications(at: [applicationUrl])

    backupController.applications = delegate.applications
    try backupController.initializeBackup(to: backupUrl)

    let fileManager = FileManager.default
    let backupDirectory = machineController.machineBackupDestination(for: testController.backupUrl)
    var isDirectory = ObjCBool(true)
    XCTAssertTrue(fileManager.fileExists(atPath: backupDirectory.path, isDirectory: &isDirectory))

    let contents = try fileManager.contentsOfDirectory(atPath: backupDirectory.path).sorted(by: { $0 < $1 })

    XCTAssertEqual(contents, [
      "6C4433RDLX.group.com.zenangst.Syncalicious.ContainerTestAppSUDefaultsDomain.plist",
      "6C4433RDLX.group.com.zenangst.Syncalicious.TestAppWithSUDefaultsDomain.plist",
      "com.zenangst.Syncalicious.ContainerTestApp.plist",
      "com.zenangst.Syncalicious.TestApp.plist"])

  }
}
