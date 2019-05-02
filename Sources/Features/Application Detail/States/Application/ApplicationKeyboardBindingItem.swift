import Cocoa

class ApplicationKeyboardBindingItem: CollectionViewItem, CollectionViewItemComponent {
  // sourcery: let menuTitle: String = "menuTitleLabel.stringValue = model.menuTitle"
  lazy var menuTitleLabel = NSTextField()
  // sourcery: let keyboardShortcut: String = "keyboardShortcutLabel.stringValue = model.keyboardShortcut"
  lazy var keyboardShortcutLabel = NSTextField()

  override func viewDidLoad() {
    super.viewDidLoad()

    let stackView = NSStackView(views: [menuTitleLabel, keyboardShortcutLabel])
    stackView.orientation = .horizontal
    stackView.distribution = .fillEqually
    view.addSubview(stackView)

    layoutConstraints = [
      stackView.topAnchor.constraint(equalTo: view.topAnchor),
      stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ]
    NSLayoutConstraint.constrain(layoutConstraints)
  }
}
