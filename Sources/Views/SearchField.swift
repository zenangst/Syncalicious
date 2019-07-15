import Cocoa

class SearchField: NSSearchField {
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    wantsLayer = true
    font = NSFont.systemFont(ofSize: 14)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layout() {
    super.layout()
    if currentEditor() != nil {
      layer?.borderColor = NSColor.controlAccentColor.cgColor
    } else {
      layer?.borderColor = NSColor.windowFrameColor.cgColor
    }
    layer?.cornerRadius = frame.size.height / 2
    layer?.borderWidth = 1
  }
}
