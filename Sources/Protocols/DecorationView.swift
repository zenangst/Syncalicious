import Cocoa

protocol DecorationView: NSView {
  var belongsToView: NSView? { get }
}
