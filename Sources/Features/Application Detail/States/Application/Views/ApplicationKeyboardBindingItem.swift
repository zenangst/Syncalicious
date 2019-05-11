import Carbon
import Cocoa
import KeyHolder
import Magnet

protocol ApplicationKeyboardBindingItemDelegate: class {
  func applicationKeyboardBindingItem(_ item: ApplicationKeyboardBindingItem,
                                      menuTitleLabelDidChange textField: NSTextField)
  func applicationKeyboardBindingItem(_ item: ApplicationKeyboardBindingItem,
                                      recorderViewDidChange recorderView: RecordView,
                                      keyCombo: KeyCombo?)
  func applicationKeyboardBindingItem(_ item: ApplicationKeyboardBindingItem,
                                      didClickRemoveButton button: NSButton)
}

class ApplicationKeyboardBindingItem: CollectionViewItem, NSTextFieldDelegate {
  weak var delegate: ApplicationKeyboardBindingItemDelegate?
  lazy var stackView = NSStackView()
  lazy var menuTitleLabel = NSTextField()
  lazy var recorderView = RecordView()
  lazy var removeButton = Button(title: "X",
                                 font: .systemFont(ofSize: 13),
                                 backgroundColor: .clear,
                                 borderColor: NSColor(named: "Red")!,
                                 borderWidth: 1, cornerRadius: .custom(4), target: self,
                                 action: #selector(removeButtonAction(_:)))

  override func viewDidLoad() {
    super.viewDidLoad()

    menuTitleLabel.delegate = self
    menuTitleLabel.font = NSFont.systemFont(ofSize: 15)
    menuTitleLabel.placeholderString = "Add new keyboard shortcut"
    menuTitleLabel.nextResponder = recorderView
    menuTitleLabel.wantsLayer = true
    menuTitleLabel.layer?.cornerRadius = 4
    menuTitleLabel.layer?.borderColor = NSColor.lightGray.cgColor
    menuTitleLabel.layer?.borderWidth = 1

    recorderView.borderColor = NSColor.systemGray
    recorderView.borderWidth = 1
    recorderView.cornerRadius = 12
    recorderView.didChange = { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.delegate?.applicationKeyboardBindingItem(strongSelf,
                                                          recorderViewDidChange: strongSelf.recorderView,
                                                          keyCombo: $0)
    }

    stackView.addArrangedSubview(menuTitleLabel)
    stackView.addArrangedSubview(recorderView)
    stackView.addArrangedSubview(removeButton)
    stackView.wantsLayer = true
    stackView.layer?.backgroundColor = NSColor.white.cgColor
    stackView.layer?.cornerRadius = 6
    stackView.spacing = 15
    stackView.edgeInsets = .init(top: 20, left: 10, bottom: 20, right: 10)
    view.addSubview(stackView)

    layoutConstraints = [
      stackView.topAnchor.constraint(equalTo: view.topAnchor),
      stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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

  func roundCorners(corners: CACornerMask) {
    stackView.layer?.maskedCorners = corners
  }

  // MARK: - Actions

  func controlTextDidChange(_ obj: Notification) {
    delegate?.applicationKeyboardBindingItem(self,
                                             menuTitleLabelDidChange: menuTitleLabel)
  }

  @objc func removeButtonAction(_ sender: NSButton) {
    delegate?.applicationKeyboardBindingItem(self,
                                             didClickRemoveButton: removeButton)
  }
}
