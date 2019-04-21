import Cocoa

@objc protocol DestinationViewDelegate: class {
  func destinationView(_ view: DestinationView,
                       didTapDirectoryButton button: NSButton)
  func destinationView(_ view: DestinationView,
                       didTapNextButton button: NSButton)
}

class DestinationView: NSView {
  weak var delegate: DestinationViewDelegate?

  lazy var iconView = NSImageView()
  lazy var titleLabel = BoldLabel()
  lazy var doneButton = NSButton(title: "All done!", target: self, action: #selector(getStarted(_:)))
  lazy var gridView = NSGridView()
  lazy var directoryLabel = Label.init(labelWithString: "No destination")
  lazy var directoryButton = NSButton(title: "Select directory",
                                      target: self,
                                      action: #selector(selectDirectory(_:)))

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
    directoryButton.alphaValue = 0.0
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

//    do {
//      let groupAnimation = CAAnimationGroup()
//      groupAnimation.isRemovedOnCompletion = false
//      groupAnimation.timingFunction = .init(name: CAMediaTimingFunctionName.easeInEaseOut)
//      let fadeIn = CABasicAnimation(keyPath: "opacity")
//      fadeIn.fromValue = 0
//      fadeIn.toValue = 1
//      let position = CABasicAnimation(keyPath: "position.y")
//      position.fromValue = -600
//      groupAnimation.animations = [position, fadeIn]
//      button.layer?.anchorPoint = .init(x: 0.5, y: 0.5)
//      button.layer?.add(groupAnimation, forKey: nil)
//      button.alphaValue = 1.0
//    }

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
      directoryButton.layer?.anchorPoint = .init(x: 0.5, y: 0.5)
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
    let image = NSImage(named: "Synced")
    image?.isTemplate = true
    iconView.image = image
    iconView.contentTintColor = NSColor.init(named: "Green")
    iconView.translatesAutoresizingMaskIntoConstraints = false

    titleLabel.font = NSFont.boldSystemFont(ofSize: 32)
    titleLabel.stringValue = "Give Syncalicious a home"
    titleLabel.maximumNumberOfLines = 2
    titleLabel.lineBreakMode = .byWordWrapping
    titleLabel.alignment = .left
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.wantsLayer = true

    doneButton.wantsLayer = true
    doneButton.isBordered = false
    doneButton.layer?.backgroundColor = NSColor.init(named: "Blue")?.cgColor
    doneButton.layer?.cornerRadius = 18
    doneButton.layer?.borderColor = NSColor.red.cgColor
    doneButton.layer?.borderWidth = 0
    doneButton.contentTintColor = NSColor.white
    doneButton.translatesAutoresizingMaskIntoConstraints = false
    doneButton.wantsLayer = true

    gridView.wantsLayer = true
    gridView.xPlacement = .fill
    gridView.translatesAutoresizingMaskIntoConstraints = false

    let syncIcon = NSImageView()
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

    gridView.addRow(with: [NSView(), NSView()])

    let fileLabel = gridView.addRow(with: [NSView(), directoryLabel])
    fileLabel.yPlacement = .center
    directoryLabel.lineBreakMode = .byTruncatingMiddle

    directoryButton.translatesAutoresizingMaskIntoConstraints = false
    directoryButton.wantsLayer = true

    addSubview(gridView)
    addSubview(titleLabel)
    addSubview(iconView)
    addSubview(directoryButton)
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

      directoryButton.widthAnchor.constraint(equalToConstant: 120),
      directoryButton.heightAnchor.constraint(equalToConstant: 48),
      directoryButton.topAnchor.constraint(equalTo: gridView.bottomAnchor),
      directoryButton.leadingAnchor.constraint(equalTo: gridView.leadingAnchor, constant: 48),

      syncIcon.heightAnchor.constraint(equalToConstant: 48),
      syncIcon.widthAnchor.constraint(equalToConstant: 48),
      backupIcon.heightAnchor.constraint(equalToConstant: 48),
      backupIcon.widthAnchor.constraint(equalToConstant: 48),

      doneButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -64),
      doneButton.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor),
      doneButton.heightAnchor.constraint(equalToConstant: 36),
      doneButton.widthAnchor.constraint(equalToConstant: 120)
    ]
    NSLayoutConstraint.activate(layoutConstraints)
  }

  // MARK: - Actions

  @objc func selectDirectory(_ sender: NSButton) {
    delegate?.destinationView(self, didTapDirectoryButton: sender)
  }

  @objc func getStarted(_ sender: NSButton) {
    delegate?.destinationView(self, didTapNextButton: sender)
  }
}
