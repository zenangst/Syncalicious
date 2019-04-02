import Cocoa

class Toolbar: NSToolbar, NSToolbarDelegate {
  override init(identifier: NSToolbar.Identifier) {
    super.init(identifier: identifier)
    delegate = self
    allowsUserCustomization = false
    showsBaselineSeparator = false
  }

  func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    return [
      NSToolbarItem.Identifier.space,
      NSToolbarItem.Identifier.flexibleSpace,
      TitleToolbarItem.itemIdentifier
    ]
  }

  func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    return [
      NSToolbarItem.Identifier.flexibleSpace,
      TitleToolbarItem.itemIdentifier,
      NSToolbarItem.Identifier.flexibleSpace
    ]
  }

  func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
    switch itemIdentifier {
    case TitleToolbarItem.itemIdentifier:
      let item = TitleToolbarItem(itemIdentifier: TitleToolbarItem.itemIdentifier)
      let applicationName = Bundle.main.infoDictionary?["CFBundleName"] as? String
      if let applicationName = applicationName {
        item.titleLabel.stringValue = applicationName
      }
      return item
    case NSToolbarItem.Identifier.flexibleSpace:
      return NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.flexibleSpace)
    default:
      return nil
    }
  }
}
