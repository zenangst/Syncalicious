import Cocoa

class PrototypeView: NSView {
  var storage = [String: NSView]()
  var layoutConstraints = [NSLayoutConstraint]()

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    loadView()
  }

  required init?(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc func loadView() {
    subviews.forEach { $0.removeFromSuperview() }
  }

  func addView(_ view: NSView, with identifier: String) {
    storage[identifier] = view
  }

  func view(_ identifier: String) -> NSView? {
    return storage[identifier]
  }
}
