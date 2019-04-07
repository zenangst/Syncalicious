import Cocoa

class PrototypeItem: NSCollectionViewItem {
  lazy var prototypeView = PrototypeView()

  override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    loadView()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func addView(_ view: NSView, with identifier: String) {
    prototypeView.addView(view, with: identifier)
  }

  func view(_ identifier: String) -> NSView? {
    return prototypeView.view(identifier)
  }

  override func loadView() {
    self.view = prototypeView
    prototypeView.subviews.forEach { $0.removeFromSuperview() }
  }

  func label(_ key: String) -> NSTextField {
    return (prototypeView.storage[key] as? NSTextField) ?? NSTextField()
  }

  func image(_ key: String) -> NSImageView {
    return (prototypeView.storage[key] as? NSImageView) ?? NSImageView()
  }

  func button(_ key: String) -> NSButton {
    return (prototypeView.storage[key] as? NSButton) ?? NSButton()
  }
}
