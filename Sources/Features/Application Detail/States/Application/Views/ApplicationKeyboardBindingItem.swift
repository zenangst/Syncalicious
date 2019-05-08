import Carbon
import Cocoa
import KeyHolder

// sourcery: let modified = "Bool"
class ApplicationKeyboardBindingItem: CollectionViewItem {
  // sourcery: let menuTitle: String = "menuTitleLabel.stringValue = !model.modified ? model.menuTitle : "" "
  lazy var menuTitleLabel = NSTextField()
  // sourcery: let keyboardShortcut: String = "configureWithString(model.keyboardShortcut)"
  lazy var recorderView = RecordView()

  lazy var removeButton = NSButton(title: "Remove", target: nil, action: nil)

  override func viewDidLoad() {
    super.viewDidLoad()

    menuTitleLabel.font = NSFont.systemFont(ofSize: 15)
    menuTitleLabel.placeholderString = "Menu Title (Enter the name of the menu command you want to add)"
    menuTitleLabel.nextResponder = recorderView

    recorderView.borderColor = NSColor.systemGray
    recorderView.borderWidth = 1
    recorderView.cornerRadius = 12

    let gridView = NSGridView()
    gridView.addRow(with: [menuTitleLabel, recorderView, removeButton])
    gridView.yPlacement = .center
    view.addSubview(gridView)

    layoutConstraints = [
      gridView.topAnchor.constraint(equalTo: view.topAnchor),
      gridView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      gridView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      gridView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      menuTitleLabel.heightAnchor.constraint(equalToConstant: 24),
      recorderView.widthAnchor.constraint(equalToConstant: 120),
      recorderView.heightAnchor.constraint(equalTo: menuTitleLabel.heightAnchor)
    ]
    NSLayoutConstraint.constrain(layoutConstraints)
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    menuTitleLabel.stringValue = ""
    recorderView.clear()
  }
}
