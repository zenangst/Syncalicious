import Cocoa

extension NSWorkspace {
  func applicationIsRunning(_ application: Application) -> Bool {
    return runningApplication(for: application) != nil
  }

  func runningApplication(for application: Application) -> NSRunningApplication? {
    let query: (NSRunningApplication) -> Bool = { $0.bundleIdentifier == application.propertyList.bundleIdentifier }
    return runningApplications.first(where: query)
  }
}
