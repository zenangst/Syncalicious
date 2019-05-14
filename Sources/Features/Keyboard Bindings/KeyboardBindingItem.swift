import Carbon
import Cocoa
import KeyHolder
import Magnet

protocol KeyboardBindingItemDelegate: class {
  func keyboardBindingItem(_ item: KeyboardBindingItem,
                           menuTitleLabelDidChange textField: NSTextField)
  func keyboardBindingItem(_ item: KeyboardBindingItem,
                           recorderViewDidChange recorderView: RecordView,
                           keyCombo: KeyCombo?)
  func keyboardBindingItem(_ item: KeyboardBindingItem,
                           didClickRemoveButton button: NSButton)
}

class KeyboardBindingItem: CollectionViewItem, NSTextFieldDelegate {
  weak var delegate: KeyboardBindingItemDelegate?
  lazy var stackView = NSStackView()
  lazy var menuTitleLabel = NSTextField()
  lazy var recorderView = RecordView()
  lazy var removeButton = Button(title: "",
                                 font: .systemFont(ofSize: 13),
                                 backgroundColor: .clear,
                                 borderColor: NSColor(named: "Red")!,
                                 borderWidth: 1, cornerRadius: .custom(4), target: self,
                                 action: #selector(removeButtonAction(_:)))

  override func viewDidLoad() {
    super.viewDidLoad()

    let image = NSImage(named: "Trash")
    removeButton.image = image
    image?.isTemplate = true
    removeButton.imageScaling = .scaleAxesIndependently

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
      strongSelf.delegate?.keyboardBindingItem(strongSelf,
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
      removeButton.widthAnchor.constraint(equalToConstant: 24),
      removeButton.heightAnchor.constraint(equalToConstant: 24),
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
    delegate?.keyboardBindingItem(self, menuTitleLabelDidChange: menuTitleLabel)
  }

  @objc func removeButtonAction(_ sender: NSButton) {
    delegate?.keyboardBindingItem(self, didClickRemoveButton: removeButton)
  }
}
