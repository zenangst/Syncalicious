import Cocoa

class CollectionViewHeader: NSView {
  override var isFlipped: Bool { return true }

  lazy var customTextField = NSTextField()

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    loadView()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc func loadView() {
    addSubview(customTextField)
    customTextField.isBezeled = false
    customTextField.isBordered = false
    customTextField.isEditable = false
    customTextField.isSelectable = false
    customTextField.drawsBackground = false
    customTextField.font = NSFont.systemFont(ofSize: 18)
    customTextField.alphaValue = 0.6
  }

  func setText(_ text: String) {
    customTextField.stringValue = text
  }

  override func layout() {
    super.layout()
    let height: CGFloat = customTextField.intrinsicContentSize.height
    customTextField.frame = .init(origin: .init(x: 10, y: bounds.maxY - height),
                                  size: .init(width: frame.width - 10, height: height))
  }
}
