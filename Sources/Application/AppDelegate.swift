import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, ApplicationControllerDelegate {
  var window: NSWindow?
  let applicationController = ApplicationController()

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    loadInjection()
    loadApplication()
  }

  private func loadInjection() {
    Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/macOSInjection.bundle")?.load()
  }

  private func loadApplication() {
    let window = NSWindow()
    window.setFrameAutosaveName(Bundle.main.bundleIdentifier!)
    window.makeKeyAndOrderFront(nil)
    self.window = window
    applicationController.delegate = self
    applicationController.load()
  }

  func applicationController(_ controller: ApplicationController,
                             didLoadApplications applications: [Application]) {
    Swift.print("Loaded \(applications.count) applications.")
  }
}

