import Cocoa

class TitleToolbarItem: NSToolbarItem {
  static var itemIdentifier: NSToolbarItem.Identifier = .init(String(describing: self))
  lazy var titleLabel = NSTextField()
  lazy var customView = NSView()

  override init(itemIdentifier: NSToolbarItem.Identifier) {
    super.init(itemIdentifier: itemIdentifier)
    view = customView
    customView.addSubview(titleLabel)
    minSize = .init(width: 175, height: 25)
    maxSize = .init(width: 175, height: 25)
    loadToolbarItem()
  }

  private func loadToolbarItem() {
    titleLabel.font = NSFont.systemFont(ofSize: 14)
    titleLabel.isBezeled = false
    titleLabel.isSelectable = false
    titleLabel.isEditable = false
    titleLabel.alignment = .center
    titleLabel.drawsBackground = false
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.centerXAnchor.constraint(equalTo: customView.centerXAnchor).isActive = true
    titleLabel.centerYAnchor.constraint(equalTo: customView.centerYAnchor).isActive = true
    titleLabel.widthAnchor.constraint(equalTo: customView.widthAnchor).isActive = true
  }
}
