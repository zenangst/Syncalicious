import Cocoa

open class ViewController: NSViewController {
  open override func loadView() {
    view = NSView()
    view.wantsLayer = true
  }
}
