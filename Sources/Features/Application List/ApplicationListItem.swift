import Cocoa

// sourcery: let path = "URL"
// sourcery: let bundleIdentifier = "String"
// sourcery: let application = "Application"
class ApplicationListItem: NSCollectionViewItem, CollectionViewItemComponent {
  let baseView = NSView()

  override var isSelected: Bool { didSet { updateState() } }

  private var layoutConstraints = [NSLayoutConstraint]()

  // sourcery: $RawBinding = "iconStore.loadIcon(at: model.path, for: model.bundleIdentifier) { image in view.iconView.image = image }"
  lazy var iconView = NSImageView()
  // sourcery: let title: String = "titleLabel.stringValue = model.title"
  lazy var titleLabel = NSTextField()
  // sourcery: let subtitle: String = "subtitleLabel.stringValue = model.subtitle"
  lazy var subtitleLabel = NSTextField()
  // sourcery: let synced: Bool = "syncView.isHidden = !model.synced"
  lazy var syncView = NSImageView()

  override func loadView() {
    view = NSView()
    view.wantsLayer = true
    view.addSubview(iconView)
    view.addSubview(titleLabel)
    view.addSubview(subtitleLabel)
    view.addSubview(syncView)
    syncView.image = NSImage(named: "Synced")
//    addView(checkbox, with: "checkbox")

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

    stackView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(stackView)
    view.layer?.cornerRadius = 4

    NSLayoutConstraint.deactivate(layoutConstraints)
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
    NSLayoutConstraint.activate(layoutConstraints)
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
