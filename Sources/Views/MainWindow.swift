import Cocoa

class MainWindow: NSWindow {
  func loadWindow() {
    let windowSize = CGSize(width: 650, height: 480)
    styleMask = [.closable, .miniaturizable, .resizable, .titled,
                 .fullSizeContentView, .unifiedTitleAndToolbar]
    titleVisibility = .hidden
    toolbar = Toolbar(identifier: String.init(describing: self))
    minSize = windowSize
  }
}
