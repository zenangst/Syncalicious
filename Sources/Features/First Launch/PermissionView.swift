import Cocoa

@objc protocol PermissionViewDelegate: class {
  func permissionView(_ view: PermissionView,
                      didTapPermissions button: NSButton)
  func permissionView(_ view: PermissionView,
                      didTapDoneButton button: NSButton)
}

class PermissionView: NSView {
  weak var delegate: PermissionViewDelegate?

  lazy var iconView = NSImageView()
  lazy var titleLabel = BoldLabel()
  lazy var doneButton = NSButton(title: "All done!", target: self, action: #selector(doneButton(_:)))
  lazy var gridView = NSGridView()
  lazy var permissionsButton = NSButton(title: "System preferences",
                                      target: self,
                                      action: #selector(grantPermission(_:)))

  private var layoutConstraints = [NSLayoutConstraint]()

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    loadView()
  }

  required init?(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func reset() {
    titleLabel.alphaValue = 0.0
    iconView.alphaValue = 0.0
    doneButton.alphaValue = 0.0
    gridView.alphaValue = 0.0
    permissionsButton.alphaValue = 0.0
  }

  func animateIn() {
    CATransaction.begin()
    defer { CATransaction.commit() }
    NSAnimationContext.current.duration = 1.5

    do {
      let groupAnimation = CAAnimationGroup()
      groupAnimation.isRemovedOnCompletion = false
      groupAnimation.timingFunction = .init(name: CAMediaTimingFunctionName.easeInEaseOut)
      let fadeIn = CABasicAnimation(keyPath: "opacity")
      fadeIn.fromValue = 0
      fadeIn.toValue = 1
      let position = CABasicAnimation(keyPath: "position.y")
      position.fromValue = 600
      groupAnimation.animations = [position, fadeIn]
      titleLabel.layer?.anchorPoint = .init(x: 0.5, y: 0.5)
      titleLabel.layer?.add(groupAnimation, forKey: nil)
      titleLabel.alphaValue = 1.0
    }

    do {
      let groupAnimation = CAAnimationGroup()
      groupAnimation.isRemovedOnCompletion = false
      groupAnimation.timingFunction = .init(name: CAMediaTimingFunctionName.easeInEaseOut)
      let fadeIn = CABasicAnimation(keyPath: "opacity")
      fadeIn.fromValue = 0
      fadeIn.toValue = 1
      let position = CABasicAnimation(keyPath: "position.y")
      position.fromValue = -600
      groupAnimation.animations = [position, fadeIn]
      permissionsButton.layer?.anchorPoint = .init(x: 0.5, y: 0.5)
      permissionsButton.layer?.add(groupAnimation, forKey: nil)
      permissionsButton.alphaValue = 1.0
    }

    do {
      let groupAnimation = CAAnimationGroup()
      groupAnimation.isRemovedOnCompletion = false
      groupAnimation.timingFunction = .init(name: CAMediaTimingFunctionName.easeInEaseOut)
      let fadeIn = CABasicAnimation(keyPath: "opacity")
      fadeIn.fromValue = 0
      fadeIn.toValue = 1
      let position = CABasicAnimation(keyPath: "position.y")
      position.fromValue = -600
      groupAnimation.animations = [position, fadeIn]
      doneButton.layer?.add(groupAnimation, forKey: nil)
      doneButton.alphaValue = 1.0
    }

    do {
      let groupAnimation = CAAnimationGroup()
      groupAnimation.isRemovedOnCompletion = false
      groupAnimation.timingFunction = .init(name: CAMediaTimingFunctionName.easeInEaseOut)
      let fadeIn = CABasicAnimation(keyPath: "opacity")
      fadeIn.fromValue = 0
      fadeIn.toValue = 1
      let position = CABasicAnimation(keyPath: "position.y")
      position.fromValue = 600
      groupAnimation.animations = [position, fadeIn]
      gridView.layer?.add(groupAnimation, forKey: nil)
      gridView.alphaValue = 1.0
    }

    let rotate = CABasicAnimation(keyPath: "transform.rotation.z")
    rotate.duration = 7.5
    rotate.fromValue = CGFloat(Double.pi) * 5 / 180.0
    rotate.timingFunction = .init(name: CAMediaTimingFunctionName.easeInEaseOut)
    iconView.layer?.add(rotate, forKey: "transform.rotation.z")
    iconView.animator().alphaValue = 1.0
  }

  func animateOut() {
    CATransaction.begin()
    CATransaction.setCompletionBlock({
      self.removeFromSuperview()
    })
    defer { CATransaction.commit() }
    NSAnimationContext.current.duration = 1.0

    do {
      let groupAnimation = CAAnimationGroup()
      groupAnimation.isRemovedOnCompletion = false
      groupAnimation.timingFunction = .init(name: CAMediaTimingFunctionName.easeInEaseOut)
      let fadeIn = CABasicAnimation(keyPath: "opacity")
      fadeIn.fromValue = 1
      fadeIn.toValue = 0
      let position = CABasicAnimation(keyPath: "position.y")
      position.toValue = 600
      groupAnimation.animations = [position, fadeIn]
      titleLabel.layer?.add(groupAnimation, forKey: nil)
      titleLabel.alphaValue = 0.0
    }

    do {
      let groupAnimation = CAAnimationGroup()
      groupAnimation.isRemovedOnCompletion = false
      groupAnimation.timingFunction = .init(name: CAMediaTimingFunctionName.easeInEaseOut)
      let fadeIn = CABasicAnimation(keyPath: "opacity")
      fadeIn.fromValue = 1
      fadeIn.toValue = 0
      let position = CABasicAnimation(keyPath: "position.y")
      position.toValue = -600
      groupAnimation.animations = [position, fadeIn]
      doneButton.layer?.add(groupAnimation, forKey: nil)
      doneButton.alphaValue = 0.0
    }

    do {
      let groupAnimation = CAAnimationGroup()
      groupAnimation.isRemovedOnCompletion = false
      groupAnimation.timingFunction = .init(name: CAMediaTimingFunctionName.easeInEaseOut)
      let fadeIn = CABasicAnimation(keyPath: "opacity")
      fadeIn.fromValue = 1
      fadeIn.toValue = 0
      let position = CABasicAnimation(keyPath: "position.y")
      position.toValue = -600
      groupAnimation.animations = [position, fadeIn]
      gridView.layer?.add(groupAnimation, forKey: nil)
      gridView.alphaValue = 0.0
    }

    let rotate = CABasicAnimation(keyPath: "transform.rotation.z")
    rotate.duration = 1.25
    rotate.toValue = CGFloat(Double.pi) * 45 / 180.0
    rotate.isAdditive = true
    rotate.isCumulative = true

    rotate.timingFunction = .init(name: CAMediaTimingFunctionName.easeInEaseOut)
    iconView.layer?.add(rotate, forKey: "transform.rotation.z")
    iconView.animator().alphaValue = 0.0
  }

  // MARK: - Private methods

  private func loadView() {
    iconView.imageScaling = .scaleAxesIndependently
    iconView.wantsLayer = true
    let image = NSImage(named: "Hand")
    image?.isTemplate = true
    iconView.image = image
    iconView.contentTintColor = NSColor.init(named: "Orange")
    iconView.translatesAutoresizingMaskIntoConstraints = false

    titleLabel.font = NSFont.boldSystemFont(ofSize: 32)
    titleLabel.stringValue = "Security & Privacy"
    titleLabel.maximumNumberOfLines = 2
    titleLabel.lineBreakMode = .byWordWrapping
    titleLabel.alignment = .center
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.wantsLayer = true

    doneButton.wantsLayer = true
    doneButton.isBordered = false
    doneButton.layer?.backgroundColor = NSColor.init(named: "Green")?.cgColor
    doneButton.layer?.cornerRadius = 18
    doneButton.layer?.borderColor = NSColor.red.cgColor
    doneButton.layer?.borderWidth = 0
    doneButton.contentTintColor = NSColor.white
    doneButton.translatesAutoresizingMaskIntoConstraints = false

    gridView.wantsLayer = true
    gridView.xPlacement = .fill
    gridView.translatesAutoresizingMaskIntoConstraints = false
    gridView.rowSpacing = 30

    let syncIcon = NSImageView()
    // swiftlint:disable line_length
    let syncLabel = Label.init(labelWithString: """
To sync and backup applications like Home, Contacts, Mail, News, Safari and Stocks, Syncalicious will need extra permissions to access those preferences files.

This step is optional but know that you cannot sync the applications mentioned above without granting access.
""")
    syncLabel.maximumNumberOfLines = -1
    syncLabel.lineBreakMode = .byWordWrapping
    syncIcon.image = NSImage.init(named: "Cloud")
    syncIcon.contentTintColor = NSColor.init(named: "Blue")
    let syncRow = gridView.addRow(with: [syncIcon, syncLabel])
    syncRow.yPlacement = .top

    let backupIcon = NSImageView()
    // swiftlint:disable line_length
    let backupLabel = Label.init(labelWithString: "You can grant Syncalicious access by adding it to the list of applications that have Full Disk Access under Security & Privacy in System Preferences, located underr the privacy tab.")
    backupLabel.maximumNumberOfLines = -1
    backupLabel.lineBreakMode = .byWordWrapping
    backupIcon.image = NSImage.init(named: "Unlock")
    backupIcon.contentTintColor = NSColor.init(named: "Yellow")
    let backupRow = gridView.addRow(with: [backupIcon, backupLabel])
    backupRow.yPlacement = .top

    permissionsButton.translatesAutoresizingMaskIntoConstraints = false
    permissionsButton.wantsLayer = true

    addSubview(gridView)
    addSubview(titleLabel)
    addSubview(iconView)
    addSubview(permissionsButton)
    addSubview(doneButton)

    NSLayoutConstraint.deactivate(layoutConstraints)
    layoutConstraints = [
      iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -120),
      iconView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 72),
      iconView.widthAnchor.constraint(equalToConstant: 512),
      iconView.heightAnchor.constraint(equalToConstant: 512),

      titleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 385),
      titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 64),
      titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -64),

      gridView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
      gridView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
      gridView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

      permissionsButton.heightAnchor.constraint(equalToConstant: 56),
      permissionsButton.topAnchor.constraint(equalTo: gridView.bottomAnchor),
      permissionsButton.leadingAnchor.constraint(equalTo: gridView.leadingAnchor, constant: 48),

      syncIcon.heightAnchor.constraint(equalToConstant: 48),
      syncIcon.widthAnchor.constraint(equalToConstant: 48),
      backupIcon.heightAnchor.constraint(equalToConstant: 48),
      backupIcon.widthAnchor.constraint(equalToConstant: 48),

      doneButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -48),
      doneButton.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor),
      doneButton.heightAnchor.constraint(equalToConstant: 36),
      doneButton.widthAnchor.constraint(equalToConstant: 120)
    ]
    NSLayoutConstraint.activate(layoutConstraints)
  }

  // MARK: - Actions

  @objc func grantPermission(_ sender: NSButton) {
    delegate?.permissionView(self, didTapPermissions: sender)
  }

  @objc func doneButton(_ sender: NSButton) {
    delegate?.permissionView(self, didTapDoneButton: sender)
  }
}
