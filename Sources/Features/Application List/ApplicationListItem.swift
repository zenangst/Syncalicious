import Cocoa

class OpaqueView: NSView {
  override var isOpaque: Bool { return true }
}

class TextField: NSTextField {
  override var isOpaque: Bool { return true }
}

class Spacer: NSView {
  override var isOpaque: Bool { return true }

  convenience init(size: CGFloat) {
    self.init(frame: .init(origin: .zero, size: .init(width: size, height: size)))
  }

  override func viewWillMove(toSuperview newSuperview: NSView?) {
    super.viewWillMove(toSuperview: newSuperview)
    setContentHuggingPriority(.required, for: .horizontal)
    setContentHuggingPriority(.required, for: .vertical)
  }
}

class ImageView: NSImageView {
  override var isOpaque: Bool { return true }
}

class StackView: NSStackView {
  override var isOpaque: Bool { return true }

  convenience init(_ views: [NSView]) {
    self.init(views: views)
  }

  convenience init(_ views: NSView...) {
    self.init(views: views)
  }
}

class HStack: StackView {
  override var isOpaque: Bool { return true }

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    orientation = .horizontal
  }

  required init?(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class VStack: StackView {
  override var isOpaque: Bool { return true }

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    orientation = .vertical
  }

  required init?(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// sourcery: let application = "Application"
class ApplicationListItem: CollectionViewItem, CollectionViewItemComponent {
  let baseView = NSView()

  override var isSelected: Bool { didSet { updateState() } }

  lazy var iconView = ImageView()
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
    syncView.image = NSImage(named: "Synced")
    syncView.image?.isTemplate = true
    syncView.contentTintColor = NSColor.controlAccentColor

    let verticalStackView = VStack(Spacer(size: 10), titleLabel, subtitleLabel, Spacer(size: 10))
    verticalStackView.alignment = .leading
    verticalStackView.distribution = .equalCentering
    verticalStackView.spacing = 0
    verticalStackView.setCustomSpacing(8, after: subtitleLabel)

    stackView = HStack(iconView, verticalStackView, syncView)
    stackView.distribution = .fill
    stackView.spacing = 8
    stackView.edgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)

    titleLabel.isEditable = false
    titleLabel.drawsBackground = false
    titleLabel.isBezeled = false
    titleLabel.font = NSFont.boldSystemFont(ofSize: 13)

    subtitleLabel.isEditable = false
    subtitleLabel.drawsBackground = false
    subtitleLabel.isBezeled = false
    subtitleLabel.maximumNumberOfLines = 1

    view.addSubview(stackView)
    stackView.wantsLayer = true
    stackView.layer?.cornerRadius = 4

    layoutConstraints = [
      stackView.topAnchor.constraint(equalTo: view.topAnchor),
      stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      verticalStackView.heightAnchor.constraint(equalTo: stackView.heightAnchor),
      iconView.widthAnchor.constraint(equalToConstant: 32),
      iconView.heightAnchor.constraint(equalToConstant: 32),
      syncView.widthAnchor.constraint(equalToConstant: 32)
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
      titleLabel.textColor = NSColor.controlAccentColor.blended(withFraction: 0.75, of: .textColor)
      subtitleLabel.textColor = NSColor.controlAccentColor.blended(withFraction: 0.4, of: .textColor)
    } else {
      stackView.layer?.backgroundColor = NSColor.clear.cgColor
      syncView.contentTintColor = NSColor.controlAccentColor
      titleLabel.textColor = NSColor.textColor
      subtitleLabel.textColor = NSColor.textColor.blended(withFraction: 0.4, of: .white)
    }
  }
}
