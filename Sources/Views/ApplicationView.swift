import Cocoa

// sourcery: let bundleIdentifier = String
// sourcery: let path = URL
class ApplicationItem: NSCollectionViewItem, CollectionViewItemComponent {
  // sourcery: $RawBinding = "iconStore.loadIcon(at: model.path, for: model.bundleIdentifier) { image in view.iconView.image = image }"
  lazy var iconView: NSImageView = .init()
  // sourcery: let title: String = "titleLabel.stringValue = model.title"
  lazy var titleLabel: NSTextField = .init()
  // sourcery: let subtitle: String = "subtitleLabel.stringValue = model.subtitle"
  lazy var subtitleLabel: NSTextField = .init()

  let baseView = NSView()

  private var layoutConstraints = [NSLayoutConstraint]()

  override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    loadView()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    self.view = baseView
    self.view.wantsLayer = true
    configureViews()
  }

  private func configureViews() {
    let verticalStackView = NSStackView(views: [titleLabel, subtitleLabel])
    verticalStackView.alignment = .leading
    verticalStackView.orientation = .vertical
    verticalStackView.spacing = 0
    let stackView = NSStackView(views: [iconView, verticalStackView])
    stackView.orientation = .horizontal

    titleLabel.isEditable = false
    titleLabel.drawsBackground = false
    titleLabel.isBezeled = false
    titleLabel.font = NSFont.boldSystemFont(ofSize: 13)

    subtitleLabel.isEditable = false
    subtitleLabel.drawsBackground = false
    subtitleLabel.isBezeled = false

    stackView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(stackView)
    view.layer?.cornerRadius = 4

    NSLayoutConstraint.deactivate(layoutConstraints)
    layoutConstraints = [
      stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
      stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
      stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
      stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
      iconView.widthAnchor.constraint(equalToConstant: 48),
      iconView.heightAnchor.constraint(equalToConstant: 48)
    ]
    NSLayoutConstraint.activate(layoutConstraints)
  }
}
