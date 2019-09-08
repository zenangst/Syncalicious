import Cocoa

class SplitView: NSSplitView {
  override var dividerThickness: CGFloat { return 0.0 }

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    dividerStyle = .thin
    isVertical = true
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
