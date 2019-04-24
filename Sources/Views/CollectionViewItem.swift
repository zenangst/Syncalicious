import Cocoa

open class CollectionViewItem: NSCollectionViewItem {
  var layoutConstraints = [NSLayoutConstraint]()

  override open func loadView() {
    view = NSView()
    view.wantsLayer = true
  }

  open override func viewDidLoad() {
    super.viewDidLoad()
    NSLayoutConstraint.deactivate(layoutConstraints)
  }
}
