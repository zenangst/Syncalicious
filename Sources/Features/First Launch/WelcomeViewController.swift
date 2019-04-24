import Cocoa

@objc protocol WelcomeViewControllerDelegate: class {
  func welcomeViewController(_ viewController: WelcomeViewController,
                             didTapGetStarted button: NSButton)
}

class WelcomeViewController: ViewController {
  weak var delegate: WelcomeViewControllerDelegate?

  lazy var iconView = NSImageView()
  lazy var titleLabel = BoldLabel()
  lazy var button = NSButton(title: "Get started", target: self, action: #selector(getStarted(_:)))
  lazy var gridView = NSGridView()

  override func viewDidLoad() {
    super.viewDidLoad()
    configureViews()
  }

  override func viewWillAppear() {
    super.viewWillAppear()
    titleLabel.alphaValue = 0.0
    iconView.alphaValue = 0.0
    button.alphaValue = 0.0
    gridView.alphaValue = 0.0
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
      button.layer?.add(groupAnimation, forKey: nil)
      button.alphaValue = 1.0
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
      button.layer?.add(groupAnimation, forKey: nil)
      button.alphaValue = 0.0
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
    let image = NSImage(named: "AppIcon")
    iconView.image = image

    titleLabel.font = NSFont.boldSystemFont(ofSize: 48)
    titleLabel.stringValue = "Welcome to Syncalicious"
    titleLabel.textColor = NSColor(named: "Pompadour")
    titleLabel.maximumNumberOfLines = 2
    titleLabel.lineBreakMode = .byWordWrapping
    titleLabel.alignment = .left
    titleLabel.wantsLayer = true

    button.wantsLayer = true
    button.isBordered = false
    button.layer?.backgroundColor = NSColor.init(named: "Green")?.cgColor
    button.layer?.cornerRadius = 18
    button.layer?.borderColor = NSColor.red.cgColor
    button.layer?.borderWidth = 0
    button.contentTintColor = NSColor.white

    gridView.wantsLayer = true
    gridView.xPlacement = .fill

    let syncIcon = NSImageView()
    let syncLabel = Label.init(labelWithString: "Sync application preferences across all your macs")
    syncLabel.maximumNumberOfLines = 2
    syncLabel.lineBreakMode = .byWordWrapping
    syncIcon.image = NSImage.init(named: "Synced")
    syncIcon.contentTintColor = NSColor.init(named: "Green")
    let syncRow = gridView.addRow(with: [syncIcon, syncLabel])
    syncRow.yPlacement = .center

    let backupIcon = NSImageView()
    let backupLabel = Label.init(labelWithString: "Backup your preferences files in case something goes wrong")
    backupLabel.maximumNumberOfLines = 2
    backupLabel.lineBreakMode = .byWordWrapping
    backupIcon.contentTintColor = NSColor.init(named: "Blue")
    backupIcon.image = NSImage.init(named: "Backup")
    let backupRow = gridView.addRow(with: [backupIcon, backupLabel])
    backupRow.yPlacement = .center

    view.addSubview(gridView)
    view.addSubview(titleLabel)
    view.addSubview(iconView)
    view.addSubview(button)

    layoutConstraints = [
      iconView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -120),
      iconView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 72),
      iconView.widthAnchor.constraint(equalToConstant: 512),
      iconView.heightAnchor.constraint(equalToConstant: 512),

      titleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 340),
      titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 64),
      titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -64),

      gridView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
      gridView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
      gridView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

      syncIcon.heightAnchor.constraint(equalToConstant: 48),
      syncIcon.widthAnchor.constraint(equalToConstant: 48),
      backupIcon.heightAnchor.constraint(equalToConstant: 48),
      backupIcon.widthAnchor.constraint(equalToConstant: 48),

      button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -64),
      button.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor),
      button.heightAnchor.constraint(equalToConstant: 36),
      button.widthAnchor.constraint(equalToConstant: 120)
    ]
    NSLayoutConstraint.constrain(layoutConstraints)
  }

  // MARK: - Actions

  @objc func getStarted(_ sender: NSButton) {
    delegate?.welcomeViewController(self, didTapGetStarted: sender)
  }
}
