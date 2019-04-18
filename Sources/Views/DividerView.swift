import Cocoa

class DividerView: LayeredView, DecorationView {
  weak var belongsToView: NSView?
}

class DarkDividerView: LayeredView, DecorationView {
  weak var belongsToView: NSView?
}

class LightDividerView: LayeredView, DecorationView {
  weak var belongsToView: NSView?
}
