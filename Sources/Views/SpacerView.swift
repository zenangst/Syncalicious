import Cocoa

class SpacerView: NSView {
  override var isOpaque: Bool { return true }

  convenience init(size: CGFloat) {
    self.init(frame: .init(origin: .zero, size: .init(width: size, height: size)))
  }

  override func viewWillMove(toSuperview newSuperview: NSView?) {
    super.viewWillMove(toSuperview: newSuperview)
    setContentHuggingPriority(.required, for: .horizontal)
    setContentHuggingPriority(.required, for: .vertical)
  }
}
