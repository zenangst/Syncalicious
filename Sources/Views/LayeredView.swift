import Cocoa

class LayeredView: NSView {
  convenience init(cgColor: CGColor?) {
    self.init(frame: .zero)
    self.layer?.backgroundColor = cgColor
  }

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    self.wantsLayer = true
    self.translatesAutoresizingMaskIntoConstraints = false
  }

  required init?(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
