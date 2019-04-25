import Cocoa

class CollectionViewHeader: NSView {
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
    NSLayoutConstraint.constrain([
      customTextField.bottomAnchor.constraint(equalTo: bottomAnchor),
      customTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
      customTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15)
    ])
    customTextField.isBezeled = false
    customTextField.isBordered = false
    customTextField.isEditable = false
    customTextField.isSelectable = false
    customTextField.drawsBackground = false
    customTextField.font = NSFont.systemFont(ofSize: 18)
    customTextField.alphaValue = 0.6
  }

  func setText(_ text: String) {
    self.customTextField.stringValue = text
  }
}
