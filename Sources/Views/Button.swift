import Cocoa

class Button: NSButton {

  enum CornerRadius {
    case custom(CGFloat)
    case round
  }

  var cornerRadius: CornerRadius = .round

  init(title: String,
       backgroundColor: NSColor,
       borderColor: NSColor,
       borderWidth: CGFloat,
       cornerRadius: CornerRadius,
       target: AnyObject?,
       action: Selector?) {
    super.init(frame: .zero)
    self.cornerRadius = cornerRadius
    self.title = title
    self.target = target
    self.action = action
    self.wantsLayer = true
    self.isBordered = false
    self.font = NSFont.boldSystemFont(ofSize: 14)
    self.layer?.backgroundColor = backgroundColor.cgColor
    self.layer?.borderColor = borderColor.cgColor
    self.layer?.borderWidth = borderWidth

    if backgroundColor == .clear {
      self.contentTintColor = borderColor
    } else {
      self.contentTintColor = NSColor.white
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layout() {
    super.layout()

    switch cornerRadius {
    case .custom(let radius):
      layer?.cornerRadius = radius
    case .round:
      layer?.cornerRadius = frame.size.height / 2
    }
  }

  override var intrinsicContentSize: NSSize {
    var result = super.intrinsicContentSize
    result.width += 20
    result.height += 10
    return result
  }
}
