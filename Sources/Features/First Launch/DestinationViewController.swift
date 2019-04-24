import Cocoa

@objc protocol DestinationViewControllerDelegate: class {
  func destinationViewController(_ controller: DestinationViewController,
                                 didTapDirectoryButton button: NSButton)
  func destinationViewController(_ controller: DestinationViewController,
                                 didTapNextButton button: NSButton)
}

class DestinationViewController: ViewController {
  weak var delegate: DestinationViewControllerDelegate?

  lazy var iconView = NSImageView()
  lazy var titleLabel = BoldLabel()
  lazy var nextButton = NSButton(title: "Next", target: self, action: #selector(nextScreen(_:)))
  lazy var gridView = NSGridView()
  lazy var directoryLabel = Label.init(labelWithString: "No destination")
  lazy var directoryButton = NSButton(title: "Select directory",
                                      target: self,
                                      action: #selector(selectDirectory(_:)))

  override func viewDidLoad() {
    super.viewDidLoad()
    configureViews()
  }

  override func viewWillAppear() {
    super.viewWillAppear()
    titleLabel.alphaValue = 0.0
    iconView.alphaValue = 0.0
    nextButton.alphaValue = 0.0
    gridView.alphaValue = 0.0
    directoryButton.alphaValue = 0.0
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
      let groupAnimation = CAAnimationGroup()
      groupAnimation.isRemovedOnCompletion = false
      groupAnimation.timingFunction = .init(name: CAMediaTimingFunctionName.easeInEaseOut)
      let fadeIn = CABasicAnimation(keyPath: "opacity")
      fadeIn.fromValue = 0
      fadeIn.toValue = 1
      let position = CABasicAnimation(keyPath: "position.y")
      position.fromValue = 600
      groupAnimation.animations = [position, fadeIn]
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
      directoryButton.layer?.add(groupAnimation, forKey: nil)
      directoryButton.alphaValue = 1.0
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

  func animateOut(_ block: (() -> Void)?) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(block)
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
      directoryButton.layer?.add(groupAnimation, forKey: nil)
      directoryButton.alphaValue = 0.0
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
      nextButton.layer?.add(groupAnimation, forKey: nil)
      nextButton.alphaValue = 0.0
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

  private func configureViews() {
    iconView.imageScaling = .scaleAxesIndependently
    iconView.wantsLayer = true
    let image = NSImage(named: "Backup")
    image?.isTemplate = true
    iconView.image = image
    iconView.contentTintColor = NSColor.init(named: "Blue")

    titleLabel.font = NSFont.boldSystemFont(ofSize: 32)
    titleLabel.stringValue = "Give Syncalicious a home"
    titleLabel.maximumNumberOfLines = 2
    titleLabel.lineBreakMode = .byWordWrapping
    titleLabel.alignment = .left
    titleLabel.wantsLayer = true

    nextButton.wantsLayer = true
    nextButton.isBordered = false
    nextButton.layer?.backgroundColor = NSColor.init(named: "Green")?.cgColor
    nextButton.layer?.cornerRadius = 18
    nextButton.layer?.borderColor = NSColor.red.cgColor
    nextButton.layer?.borderWidth = 0
    nextButton.contentTintColor = NSColor.white

    gridView.wantsLayer = true
    gridView.xPlacement = .fill
    gridView.rowSpacing = 30

    let syncIcon = NSImageView()
    // swiftlint:disable line_length
    let syncLabel = Label.init(labelWithString: "To sync and make backups of your preferences files, Syncalicious needs a directory to use as a home.")
    syncLabel.maximumNumberOfLines = -1
    syncLabel.lineBreakMode = .byWordWrapping
    syncIcon.image = NSImage.init(named: "Synced")
    syncIcon.contentTintColor = NSColor.init(named: "Green")
    let syncRow = gridView.addRow(with: [syncIcon, syncLabel])
    syncRow.yPlacement = .center

    let backupIcon = NSImageView()
    // swiftlint:disable line_length
    let backupLabel = Label.init(labelWithString: "To sync preferences files across Macs, pick a directory that is synced to the cloud,\ne.g. iCloud, Dropbox or Google Drive.")
    backupLabel.maximumNumberOfLines = -1
    backupLabel.lineBreakMode = .byWordWrapping
    backupIcon.image = NSImage.init(named: "Cloud")
    let backupRow = gridView.addRow(with: [backupIcon, backupLabel])
    backupRow.yPlacement = .center

    let fileLabel = gridView.addRow(with: [NSView(), directoryLabel])
    fileLabel.yPlacement = .center
    directoryLabel.lineBreakMode = .byTruncatingMiddle
    directoryLabel.font = NSFont.boldSystemFont(ofSize: 14)
    directoryButton.wantsLayer = true

    view.addSubview(gridView)
    view.addSubview(titleLabel)
    view.addSubview(iconView)
    view.addSubview(directoryButton)
    view.addSubview(nextButton)

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

      directoryButton.widthAnchor.constraint(equalToConstant: 120),
      directoryButton.heightAnchor.constraint(equalToConstant: 48),
      directoryButton.topAnchor.constraint(equalTo: gridView.bottomAnchor),
      directoryButton.leadingAnchor.constraint(equalTo: gridView.leadingAnchor, constant: 48),

      syncIcon.heightAnchor.constraint(equalToConstant: 48),
      syncIcon.widthAnchor.constraint(equalToConstant: 48),
      backupIcon.heightAnchor.constraint(equalToConstant: 48),
      backupIcon.widthAnchor.constraint(equalToConstant: 48),

      nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -48),
      nextButton.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor),
      nextButton.heightAnchor.constraint(equalToConstant: 36),
      nextButton.widthAnchor.constraint(equalToConstant: 120)
    ]
    NSLayoutConstraint.constrain(layoutConstraints)
  }

  // MARK: - Actions

  @objc func selectDirectory(_ sender: NSButton) {
    delegate?.destinationViewController(self, didTapDirectoryButton: sender)
  }

  @objc func nextScreen(_ sender: NSButton) {
    delegate?.destinationViewController(self, didTapNextButton: sender)
  }
}
