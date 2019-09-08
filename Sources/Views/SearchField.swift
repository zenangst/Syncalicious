import Cocoa

class SearchField: NSSearchField {
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    wantsLayer = true
    font = NSFont.systemFont(ofSize: 13)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layout() {
    super.layout()
    if currentEditor() != nil {
      layer?.borderColor = NSColor.controlAccentColor.cgColor
    } else {
      layer?.borderColor = NSColor.windowFrameTextColor.withAlphaComponent(0.1).cgColor
    }
    layer?.cornerRadius = 4
    layer?.borderWidth = 1
  }
}
