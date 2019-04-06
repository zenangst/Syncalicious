@testable import Syncalicious

class TestApplicationDelegate: ApplicationControllerDelegate {
  var applications = [Application]()
  func applicationController(_ controller: ApplicationController, didLoadApplications applications: [Application]) {
    self.applications = applications
  }
}
