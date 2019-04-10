import Cocoa

class MainWindow: NSWindow {
  func loadWindow() {
    let windowSize = CGSize(width: 680, height: 480)
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
}
