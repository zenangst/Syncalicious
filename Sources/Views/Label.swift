import Cocoa

class Label: NSTextField, DecorationView {
  weak var belongsToView: NSView?

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    translatesAutoresizingMaskIntoConstraints = false
    isBezeled = false
    isBordered = false
    isSelectable = false
    isEditable = false
    drawsBackground = false
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
