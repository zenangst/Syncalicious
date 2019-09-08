import Cocoa

@objc protocol PermissionViewControllerDelegate: class {
  func permissionViewController(_ controller: PermissionViewController,
                                didTapPermissions button: NSButton)
  func permissionViewController(_ controller: PermissionViewController,
                                didTapDoneButton button: NSButton)
}

class PermissionViewController: ViewController {
  weak var delegate: PermissionViewControllerDelegate?

  lazy var iconView = NSImageView()
  lazy var titleLabel = BoldLabel()
  lazy var gridView = NSGridView()
  lazy var doneButton = NSButton(title: "All done!", target: self,
                                 action: #selector(doneButton(_:)))
  lazy var permissionsButton = Button(title: "System preferences",
                                      backgroundColor: NSColor.systemGreen,
                                      borderColor: NSColor.clear,
                                      borderWidth: 0,
                                      cornerRadius: .custom(4),
                                      target: self,
                                      action: #selector(grantPermission(_:)))

  let factory = AnimationFactory()

  override func viewDidLoad() {
    super.viewDidLoad()
    configureViews()
  }

  override func viewWillAppear() {
    super.viewWillAppear()
    titleLabel.alphaValue = 0.0
    iconView.alphaValue = 0.0
    doneButton.alphaValue = 0.0
    gridView.alphaValue = 0.0
    permissionsButton.alphaValue = 0.0
  }

  override func viewDidAppear() {
    super.viewDidAppear()
    animateIn()
  }

  func animateIn() {
    CATransaction.begin()
    defer { CATransaction.commit() }
    NSAnimationContext.current.duration = 1.0

    do {
      let fadeIn = factory.createBasicAnimation(keyPath: "opacity")
      fadeIn.fromValue = 0
      fadeIn.toValue = 1
      let position = factory.createBasicAnimation(keyPath: "position.y")
      position.fromValue = 600
      let groupAnimation = factory.createAnimationGroup([position, fadeIn])
      titleLabel.layer?.add(groupAnimation, forKey: nil)
      titleLabel.alphaValue = 1.0
    }

    do {
      let fadeIn = factory.createBasicAnimation(keyPath: "opacity")
      fadeIn.fromValue = 0
      fadeIn.toValue = 1
      let position = factory.createBasicAnimation(keyPath: "position.y")
      position.fromValue = -600
      let groupAnimation = factory.createAnimationGroup([position, fadeIn])
      permissionsButton.layer?.add(groupAnimation, forKey: nil)
      permissionsButton.alphaValue = 1.0
    }

    do {
      let fadeIn = factory.createBasicAnimation(keyPath: "opacity")
      fadeIn.fromValue = 0
      fadeIn.toValue = 1
      let position = factory.createBasicAnimation(keyPath: "position.y")
      position.fromValue = -600
      let groupAnimation = factory.createAnimationGroup([position, fadeIn])
      doneButton.layer?.add(groupAnimation, forKey: nil)
      doneButton.alphaValue = 1.0
    }

    do {
      let fadeIn = factory.createBasicAnimation(keyPath: "opacity")
      fadeIn.fromValue = 0
      fadeIn.toValue = 1
      let position = factory.createBasicAnimation(keyPath: "position.y")
      position.fromValue = 600
      let groupAnimation = factory.createAnimationGroup([position, fadeIn])
      gridView.layer?.add(groupAnimation, forKey: nil)
      gridView.alphaValue = 1.0
    }

    let rotate = factory.createBasicAnimation(keyPath: "transform.rotation.z")
    rotate.duration = 7.5
    rotate.fromValue = CGFloat(Double.pi) * 5 / 180.0
    rotate.timingFunction = .init(name: CAMediaTimingFunctionName.easeInEaseOut)
    iconView.layer?.add(rotate, forKey: "transform.rotation.z")
    iconView.animator().alphaValue = 1.0
  }

  // MARK: - Private methods

  private func configureViews() {
    iconView.imageScaling = .scaleAxesIndependently
    iconView.wantsLayer = true
    let image = NSImage(named: "Hand")
    image?.isTemplate = true
    iconView.image = image
    iconView.contentTintColor = NSColor.init(named: "Orange")

    titleLabel.font = NSFont.boldSystemFont(ofSize: 32)
    titleLabel.stringValue = "Security & Privacy"
    titleLabel.maximumNumberOfLines = 2
    titleLabel.lineBreakMode = .byWordWrapping
    titleLabel.alignment = .center
    titleLabel.textColor = .black
    titleLabel.wantsLayer = true

    doneButton.wantsLayer = true
    doneButton.isBordered = false
    doneButton.layer?.backgroundColor = NSColor.init(named: "Green")?.cgColor
    doneButton.layer?.cornerRadius = 18
    doneButton.layer?.borderColor = NSColor.red.cgColor
    doneButton.layer?.borderWidth = 0
    doneButton.contentTintColor = NSColor.white

    gridView.wantsLayer = true
    gridView.xPlacement = .fill
    gridView.rowSpacing = 30

    let syncIcon = NSImageView()
    // swiftlint:disable line_length
    let syncLabel = Label.init(labelWithString: """
To sync and backup applications like Home, Contacts, Mail, News, Safari and Stocks, Syncalicious will need extra permissions to access those preferences files.

This step is optional but know that you cannot sync the applications mentioned above without granting access.
""")
    syncLabel.textColor = .black
    syncLabel.maximumNumberOfLines = -1
    syncLabel.lineBreakMode = .byWordWrapping
    syncIcon.image = NSImage.init(named: "Cloud")
    syncIcon.contentTintColor = NSColor.init(named: "Blue")
    let syncRow = gridView.addRow(with: [syncIcon, syncLabel])
    syncRow.yPlacement = .top

    let backupIcon = NSImageView()
    // swiftlint:disable line_length
    let backupLabel = Label.init(labelWithString: "You can grant Syncalicious access by adding it to the list of applications that have Full Disk Access under Security & Privacy in System Preferences, located underr the privacy tab.")
    backupLabel.textColor = .black
    backupLabel.maximumNumberOfLines = -1
    backupLabel.lineBreakMode = .byWordWrapping
    backupIcon.image = NSImage.init(named: "Unlock")
    backupIcon.contentTintColor = NSColor.init(named: "Yellow")
    let backupRow = gridView.addRow(with: [backupIcon, backupLabel])
    backupRow.yPlacement = .top

    view.addSubview(gridView)
    view.addSubview(titleLabel)
    view.addSubview(iconView)
    view.addSubview(permissionsButton)
    view.addSubview(doneButton)

    NSLayoutConstraint.deactivate(layoutConstraints)
    layoutConstraints = [
      iconView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -120),
      iconView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 72),
      iconView.widthAnchor.constraint(equalToConstant: 512),
      iconView.heightAnchor.constraint(equalToConstant: 512),

      titleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 385),
      titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 64),
      titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -64),

      gridView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
      gridView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
      gridView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

      permissionsButton.topAnchor.constraint(equalTo: gridView.bottomAnchor, constant: 10),
      permissionsButton.leadingAnchor.constraint(equalTo: backupLabel.leadingAnchor),

      syncIcon.heightAnchor.constraint(equalToConstant: 48),
      syncIcon.widthAnchor.constraint(equalToConstant: 48),
      backupIcon.heightAnchor.constraint(equalToConstant: 48),
      backupIcon.widthAnchor.constraint(equalToConstant: 48),

      doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -48),
      doneButton.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor),
      doneButton.heightAnchor.constraint(equalToConstant: 36),
      doneButton.widthAnchor.constraint(equalToConstant: 120)
    ]
    NSLayoutConstraint.constrain(layoutConstraints)
  }

  // MARK: - Actions

  @objc func grantPermission(_ sender: NSButton) {
    delegate?.permissionViewController(self, didTapPermissions: sender)
  }

  @objc func doneButton(_ sender: NSButton) {
    delegate?.permissionViewController(self, didTapDoneButton: sender)
  }
}
