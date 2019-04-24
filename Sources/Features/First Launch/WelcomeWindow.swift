import Cocoa

class WelcomeWindow: NSWindow {
  func loadWindow() {
    let windowSize = CGSize(width: 800, height: 480)
    styleMask = [
      .closable, .miniaturizable, .resizable, .titled,
      .fullSizeContentView
    ]
    toolbar = NSToolbar()
    toolbar?.showsBaselineSeparator = false
    titleVisibility = .hidden
    minSize = windowSize
    maxSize = windowSize
    title = "Welcome to Syncalicious"
    titlebarAppearsTransparent = true
    isMovableByWindowBackground = true
    animationBehavior = .documentWindow
    setFrame(.init(origin: .zero, size: maxSize), display: true, animate: false)
  }
}
