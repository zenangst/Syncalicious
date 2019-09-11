import Cocoa

// sourcery: let application = "Application"
class ApplicationListItem: CollectionViewItem, CollectionViewItemComponent {
  let baseView = NSView()

  override var isSelected: Bool { didSet { updateState() } }

  lazy var iconView = OpaqueView()
  // sourcery: let title: String = "titleLabel.stringValue = model.title"
  lazy var titleLabel = TextField()
  // sourcery: let subtitle: String = "subtitleLabel.stringValue = model.subtitle"
  lazy var subtitleLabel = TextField()
  // sourcery: let synced: Bool = "syncView.isHidden = !model.synced"
  lazy var syncView = ImageView()

  lazy var stackView = HStack()

  // MARK: - View lifecycle

  override func loadView() {
    self.view = OpaqueView()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(iconView)
    view.addSubview(titleLabel)
    view.addSubview(subtitleLabel)
    view.addSubview(syncView)

    syncView.wantsLayer = true
    syncView.layerContentsPlacement = .scaleProportionallyToFit
    syncView.image = IconController.shared.syncedIcon
    syncView.contentTintColor = NSColor.controlAccentColor

    syncView.layer?.drawsAsynchronously = true
    iconView.layer?.drawsAsynchronously = true

    let verticalStackView = VStack(SpacerView(size: 10), titleLabel, subtitleLabel, SpacerView(size: 10))
    verticalStackView.alignment = .leading
    verticalStackView.distribution = .equalCentering
    verticalStackView.spacing = 0
    verticalStackView.setCustomSpacing(8, after: subtitleLabel)

    stackView = HStack(iconView, verticalStackView, syncView)
    stackView.distribution = .fillProportionally
    stackView.alignment = .centerY
    stackView.spacing = 10
    stackView.edgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)

    titleLabel.isEditable = false
    titleLabel.drawsBackground = false
    titleLabel.isBezeled = false
    titleLabel.maximumNumberOfLines = 1
    titleLabel.allowsDefaultTighteningForTruncation = true
    titleLabel.lineBreakMode = .byTruncatingTail
    titleLabel.font = NSFont.systemFont(ofSize: 13)

    subtitleLabel.isEditable = false
    subtitleLabel.drawsBackground = false
    subtitleLabel.isBezeled = false
    subtitleLabel.maximumNumberOfLines = 1
    subtitleLabel.font = NSFont.systemFont(ofSize: 11)
    subtitleLabel.alphaValue = 0.4

    view.addSubview(stackView)
    stackView.wantsLayer = true

    layoutConstraints = [
      stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      iconView.widthAnchor.constraint(equalToConstant: 32),
      iconView.heightAnchor.constraint(equalToConstant: 32),
      syncView.widthAnchor.constraint(equalToConstant: 28),
      syncView.heightAnchor.constraint(equalToConstant: 28)
    ]
    NSLayoutConstraint.constrain(layoutConstraints)
    updateState()
  }

  override func viewDidLayout() {
    super.viewDidLayout()
    updateState()
  }

  // MARK: - Private methods

  private func updateState() {
    if isSelected {
      stackView.layer?.backgroundColor = NSColor.controlAccentColor.withAlphaComponent(0.3).cgColor
      syncView.contentTintColor = NSColor.controlAccentColor
      titleLabel.textColor = NSColor.selectedTextColor
      subtitleLabel.textColor = NSColor.selectedTextColor
    } else {
      stackView.layer?.backgroundColor = NSColor.clear.cgColor
      syncView.contentTintColor = NSColor.controlAccentColor
      titleLabel.textColor = NSColor.textColor
      subtitleLabel.textColor = NSColor.textColor
    }
  }
}
