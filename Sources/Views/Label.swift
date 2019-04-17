import Cocoa

class Label: NSTextField, DecorationView {
  weak var belongsToView: NSView?

  convenience init(text: String) {
    self.init(frame: .zero)
    stringValue = text
  }

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    font = NSFont.systemFont(ofSize: 15)
    translatesAutoresizingMaskIntoConstraints = false
    isBezeled = false
    isBordered = false
    isSelectable = false
    isEditable = false
    drawsBackground = false
    backgroundColor = .clear
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class SmallLabel: Label {

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    font = NSFont.systemFont(ofSize: 13)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class SmallBoldLabel: Label {

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    font = NSFont.boldSystemFont(ofSize: 13)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class BoldLabel: Label {
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    font = NSFont.boldSystemFont(ofSize: font?.pointSize ?? 13)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
