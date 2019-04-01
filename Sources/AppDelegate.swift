import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  var window: NSWindow?

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
  }
}

