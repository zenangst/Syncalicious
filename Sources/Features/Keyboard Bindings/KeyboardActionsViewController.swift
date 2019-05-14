import Cocoa

protocol KeyboardActionsViewControllerDelegate: class {
  func keyboardActionsViewController(_ controller: KeyboardActionsViewController,
                                     didClickSaveButton button: NSButton)
  func keyboardActionsViewController(_ controller: KeyboardActionsViewController,
                                     didClickDiscardButton button: NSButton)
}

class KeyboardActionsViewController: ViewController {
  weak var delegate: KeyboardActionsViewControllerDelegate?
  lazy var stackView = NSStackView()

  // MARK: - View lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    let saveButton = Button(title: "Save",
                            backgroundColor: NSColor(named: "Green")!,
                            borderColor: NSColor(named: "Green")!,
                            borderWidth: 1,
                            cornerRadius: .custom(4), target: self, action: #selector(saveChanges(_:)))
    let discardButton = Button(title: "Discard",
                               backgroundColor: NSColor.clear,
                               borderColor: NSColor(named: "Red")!,
                               borderWidth: 1,
                               cornerRadius: .custom(4), target: self, action: #selector(discardChanges(_:)))

    let noteLabel = SmallLabel(text: "The application will restart when you save your changes.")
    noteLabel.textColor = NSColor.textColor.highlight(withLevel: 0.4)
    noteLabel.lineBreakMode = .byTruncatingMiddle
    noteLabel.alignment = .right

    saveButton.setContentHuggingPriority(.required, for: .horizontal)
    discardButton.setContentHuggingPriority(.required, for: .horizontal)

    stackView.spacing = 8
    stackView.orientation = .horizontal
    stackView.distribution = .fill
    stackView.addArrangedSubview(noteLabel)
    stackView.addArrangedSubview(saveButton)
    stackView.addArrangedSubview(discardButton)

    view.addSubview(stackView)

    NSLayoutConstraint.constrain([
      stackView.topAnchor.constraint(equalTo: view.topAnchor),
      stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15)
      ])
  }

  override func viewWillLayout() {
    super.viewWillLayout()
    view.frame.size.height = stackView.frame.size.height + 10
  }

  // MARK: - Actions

  @objc func saveChanges(_ button: NSButton) {
    delegate?.keyboardActionsViewController(self, didClickSaveButton: button)
  }

  @objc func discardChanges(_ button: NSButton) {
    delegate?.keyboardActionsViewController(self, didClickDiscardButton: button)
  }
}
