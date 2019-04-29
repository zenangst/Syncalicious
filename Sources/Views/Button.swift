import Cocoa

class Button: NSButton {

  enum CornerRadius {
    case custom(CGFloat)
    case round
  }

  var backgroundColor: NSColor
  var borderColor: NSColor
  var cornerRadius: CornerRadius = .round

  init(title: String,
       backgroundColor: NSColor,
       borderColor: NSColor,
       borderWidth: CGFloat,
       cornerRadius: CornerRadius,
       target: AnyObject?,
       action: Selector?) {
    self.backgroundColor = backgroundColor
    self.borderColor = borderColor
    super.init(frame: .zero)
    self.cornerRadius = cornerRadius
    self.setButtonType(.momentaryChange)
    self.title = title
    self.target = target
    self.action = action
    self.wantsLayer = true
    self.isBordered = false
    self.font = NSFont.boldSystemFont(ofSize: 14)
    self.layer?.backgroundColor = backgroundColor.cgColor
    self.layer?.borderWidth = borderWidth
    self.layer?.borderColor = borderColor.cgColor
  }

  override func draw(_ dirtyRect: NSRect) {
    if isHighlighted {
      if backgroundColor == .clear {
        borderColor.withSystemEffect(.pressed).setFill()
        contentTintColor = borderColor.withSystemEffect(.pressed)
        layer?.borderColor = borderColor.withSystemEffect(.pressed).cgColor
      } else {
        backgroundColor.withSystemEffect(.pressed).setFill()
        contentTintColor = backgroundColor.withSystemEffect(.pressed)
        layer?.borderColor = backgroundColor.withSystemEffect(.pressed).cgColor
      }
      dirtyRect.fill()
    } else {
      if backgroundColor == .clear {
        contentTintColor = borderColor
      } else {
        contentTintColor = NSColor.white
      }
      layer?.borderColor = borderColor.cgColor
    }

    super.draw(dirtyRect)
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
    result.width += 35
    result.height += 10
    return result
  }
}
