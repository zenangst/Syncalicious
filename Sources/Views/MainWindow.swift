import Cocoa

enum MainWindowNotification: String {
  case didClose
  case didResign
  case becomeKey

  var notificationName: Notification.Name { return Notification.Name(rawValue: self.rawValue) }
  var notification: Notification { return Notification(name: notificationName )  }
}

class MainWindow: NSWindow {
  func loadWindow() {
    let windowSize = CGSize(width: 800, height: 280)
    styleMask = [
      .closable, .miniaturizable, .resizable, .titled, .fullSizeContentView
    ]
    titleVisibility = .hidden
    titlebarAppearsTransparent = true
    toolbar = NSToolbar(identifier: String.init(describing: self))
    minSize = windowSize
    backgroundColor = NSColor.windowBackgroundColor

    if frame.size.width < windowSize.width || frame.size.width > maxSize.width {
      setFrame(NSRect.init(origin: .zero, size: windowSize),
               display: false)
    }
  }

  override func close() {
    super.close()
    NotificationCenter.default.post(MainWindowNotification.didClose.notification)
  }

  override func resignKey() {
    super.resignKey()
    NotificationCenter.default.post(MainWindowNotification.didResign.notification)
  }

  override func becomeKey() {
    super.becomeKey()
    NSApp.setActivationPolicy(.regular)
    NotificationCenter.default.post(MainWindowNotification.becomeKey.notification)
  }
}
