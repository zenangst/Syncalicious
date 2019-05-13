import Cocoa

// sourcery: let application = "Application"
class ApplicationDetailItem: CollectionViewItem, CollectionViewItemComponent {
  // sourcery: $RawBinding = "iconController.loadIcon(at: model.application.url, identifier: model.application.propertyList.bundleIdentifier) { image in view.iconView.image = image }"
  lazy var iconView = NSImageView()
  // sourcery: let title: String = "titleLabel.stringValue = model.title"
  lazy var titleLabel = NSTextField()

  override func viewDidLoad() {
    super.viewDidLoad()
    let stackView = NSStackView(views: [iconView, titleLabel])
    stackView.distribution = .gravityAreas
    stackView.orientation = .horizontal
    stackView.alignment = .centerX
    view.addSubview(stackView)

    titleLabel.isEditable = false
    titleLabel.drawsBackground = false
    titleLabel.isBezeled = false
    titleLabel.font = NSFont.boldSystemFont(ofSize: 13)
    titleLabel.lineBreakMode = .byTruncatingMiddle
    titleLabel.maximumNumberOfLines = 2
    titleLabel.alignment = .center

    layoutConstraints = [
      iconView.widthAnchor.constraint(equalToConstant: 72),
      iconView.heightAnchor.constraint(equalToConstant: 72),
      stackView.topAnchor.constraint(equalTo: view.topAnchor),
      stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ]
    NSLayoutConstraint.constrain(layoutConstraints)
  }
}
