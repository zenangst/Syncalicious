import Cocoa

class HStack: StackView {
  override var isOpaque: Bool { return true }

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    orientation = .horizontal
  }

  required init?(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
