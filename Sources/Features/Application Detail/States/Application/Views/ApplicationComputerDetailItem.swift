import Cocoa

// sourcery: let image = "URL"
// sourcery: let machine = "Machine"
// sourcery: let synced = "Bool"
// sourcery: let backupDate = "Date?"
class ApplicationComputerDetailItem: CollectionViewItem, CollectionViewItemComponent {
  // sourcery: $RawBinding = "iconController.loadIcon(at: model.image, identifier: model.machine.name) { image in view.iconView.image = image }"
  lazy var iconView = NSImageView()
  // sourcery: let title: String = "titleLabel.stringValue = model.title"
  lazy var titleLabel = NSTextField()
  // sourcery: let subtitle: String = "subtitleLabel.stringValue = model.subtitle"
  lazy var subtitleLabel = NSTextField()
  // sourcery: $RawBinding = "view.backupIconView.isHidden = model.backupDate == nil"
  lazy var backupIconView = NSImageView()
  // sourcery: $RawBinding = "view.syncIconView.isHidden = !model.synced"
  lazy var syncIconView = NSImageView()

  override func viewDidLoad() {
    super.viewDidLoad()

    syncIconView.image = NSImage(named: "Synced")
    syncIconView.contentTintColor = NSColor(named: "Green")
    backupIconView.image = NSImage(named: "Backup")
    backupIconView.contentTintColor = NSColor(named: "Blue")

    let horizontalStackView = NSStackView(views: [syncIconView, backupIconView])
    horizontalStackView.orientation = .horizontal
    horizontalStackView.distribution = .fillProportionally
    let stackView = NSStackView(views: [iconView, titleLabel, subtitleLabel, horizontalStackView])
    stackView.distribution = .fillProportionally
    stackView.orientation = .vertical
    stackView.alignment = .centerX
    stackView.spacing = 0
    view.addSubview(stackView)

    stackView.setCustomSpacing(8, after: subtitleLabel)

    titleLabel.isEditable = false
    titleLabel.drawsBackground = false
    titleLabel.isBezeled = false
    titleLabel.font = NSFont.systemFont(ofSize: 15)
    titleLabel.alignment = .center

    subtitleLabel.isEditable = false
    subtitleLabel.drawsBackground = false
    subtitleLabel.isBezeled = false
    subtitleLabel.font = NSFont.boldSystemFont(ofSize: 13)
    subtitleLabel.alignment = .center

    layoutConstraints = [
      iconView.widthAnchor.constraint(equalToConstant: 128),
      iconView.heightAnchor.constraint(equalToConstant: 128),
      syncIconView.widthAnchor.constraint(equalToConstant: 32),
      syncIconView.heightAnchor.constraint(equalToConstant: 32),
      backupIconView.widthAnchor.constraint(equalToConstant: 32),
      backupIconView.heightAnchor.constraint(equalToConstant: 32),
      stackView.topAnchor.constraint(equalTo: view.topAnchor),
      stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ]
    NSLayoutConstraint.constrain(layoutConstraints)
  }
}
