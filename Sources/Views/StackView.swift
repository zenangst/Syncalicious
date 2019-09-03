import Cocoa

class StackView: NSStackView {
  override var isOpaque: Bool { return true }

  convenience init(_ views: [NSView]) {
    self.init(views: views)
  }

  convenience init(_ views: NSView...) {
    self.init(views: views)
  }
}
