import Cocoa

class BackgroundView: LayeredView, DecorationView {
  override var isOpaque: Bool { return false }
  weak var belongsToView: NSView?
}
