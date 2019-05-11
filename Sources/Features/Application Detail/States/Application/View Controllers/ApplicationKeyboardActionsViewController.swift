import Cocoa

protocol ApplicationKeyboardActionsViewControllerDelegate: class {
  func applicationKeyboardActionsViewController(_ controller: ApplicationKeyboardActionsViewController,
                                                didClickSaveButton button: NSButton)
  func applicationKeyboardActionsViewController(_ controller: ApplicationKeyboardActionsViewController,
                                                didClickDiscardButton button: NSButton)
}

class ApplicationKeyboardActionsViewController: ViewController {
  weak var delegate: ApplicationKeyboardActionsViewControllerDelegate?
  lazy var gridView = NSGridView()

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

    gridView.addRow(with: [discardButton, saveButton])
    gridView.xPlacement = .trailing
    view.addSubview(gridView)

    NSLayoutConstraint.constrain([
      gridView.topAnchor.constraint(equalTo: view.topAnchor),
      gridView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15)
      ])
  }

  override func viewWillAppear() {
    super.viewWillAppear()
    view.frame.size.height = gridView.frame.size.height + 10
  }

  // MARK: - Actions

  @objc func saveChanges(_ button: NSButton) {
    delegate?.applicationKeyboardActionsViewController(self, didClickDiscardButton: button)
  }

  @objc func discardChanges(_ button: NSButton) {
    delegate?.applicationKeyboardActionsViewController(self, didClickDiscardButton: button)
  }
}
