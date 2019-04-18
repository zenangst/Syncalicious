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
    let shellController = ShellController()
    let machineController = try MachineController(host: host, shellController: shellController)
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

    let sandboxedPath = backupDirectory.appendingPathComponent("Container").appendingPathComponent("Preferences")
    let regularPath = backupDirectory.appendingPathComponent("Library").appendingPathComponent("Preferences")

    let sandboxedApps = try fileManager.contentsOfDirectory(atPath: sandboxedPath.path).sorted(by: { $0 < $1 })
    let regularApps = try fileManager.contentsOfDirectory(atPath: regularPath.path).sorted(by: { $0 < $1 })
    let results = sandboxedApps + regularApps

    XCTAssertEqual(results, [
      "6C4433RDLX.group.com.zenangst.Syncalicious.ContainerTestAppSUDefaultsDomain.plist",
      "com.zenangst.Syncalicious.ContainerTestApp.plist",
      "6C4433RDLX.group.com.zenangst.Syncalicious.TestAppWithSUDefaultsDomain.plist",
      "com.zenangst.Syncalicious.TestApp.plist"])

  }
}
