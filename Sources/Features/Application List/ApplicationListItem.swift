import Cocoa

// sourcery: let application = "Application"
class ApplicationListItem: CollectionViewItem, CollectionViewItemComponent {
  let baseView = NSView()

  override var isSelected: Bool { didSet { updateState() } }

  // sourcery: $RawBinding = "iconStore.loadIcon(at: model.application.url, for: model.application.propertyList.bundleIdentifier) { image in view.iconView.image = image }"
  lazy var iconView = NSImageView()
  // sourcery: let title: String = "titleLabel.stringValue = model.title"
  lazy var titleLabel = NSTextField()
  // sourcery: let subtitle: String = "subtitleLabel.stringValue = model.subtitle"
  lazy var subtitleLabel = NSTextField()
  // sourcery: let synced: Bool = "syncView.isHidden = !model.synced"
  lazy var syncView = NSImageView()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(iconView)
    view.addSubview(titleLabel)
    view.addSubview(subtitleLabel)
    view.addSubview(syncView)
    syncView.image = NSImage(named: "Synced")

    iconView.contentTintColor = NSColor.controlAccentColor

    let verticalStackView = NSStackView(views: [titleLabel, subtitleLabel])
    verticalStackView.alignment = .left
    verticalStackView.orientation = .vertical
    verticalStackView.spacing = 0
    verticalStackView.setCustomSpacing(8, after: subtitleLabel)

    let stackView = NSStackView(views: [iconView, verticalStackView, syncView])
    stackView.distribution = .fillProportionally
    stackView.orientation = .horizontal
    stackView.alignment = .top

    titleLabel.isEditable = false
    titleLabel.drawsBackground = false
    titleLabel.isBezeled = false
    titleLabel.font = NSFont.boldSystemFont(ofSize: 13)

    subtitleLabel.isEditable = false
    subtitleLabel.drawsBackground = false
    subtitleLabel.isBezeled = false
    subtitleLabel.maximumNumberOfLines = 1

    view.addSubview(stackView)
    view.layer?.cornerRadius = 4

    let padding: CGFloat = 8

    layoutConstraints = [
      stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: padding),
      stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
      stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
      stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding),
      iconView.widthAnchor.constraint(equalToConstant: 32),
      iconView.heightAnchor.constraint(equalToConstant: 32),
      syncView.widthAnchor.constraint(equalToConstant: 32)
    ]
    NSLayoutConstraint.constrain(layoutConstraints)
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    updateState()
  }

  private func updateState() {
    if isSelected {
      view.layer?.backgroundColor = NSColor.controlAccentColor.withAlphaComponent(0.33).cgColor
    } else {
      view.layer?.backgroundColor = NSColor.clear.cgColor
    }
  }
}
