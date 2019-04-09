import Cocoa
// swiftlint:disable line_length function_body_length
// sourcery: $RawBinding = "iconStore.loadIcon(at: model.url("path"), for: model.string("bundleIdentifier")) { image in item.image("iconView").image = image }"
// sourcery: item.label("titleLabel").stringValue = model.string("title")
// sourcery: item.label("subtitleLabel").stringValue = model.string("subtitle")
// sourcery: item.button("checkbox").state = = model.bool("enabled") ? .on : .off
class ApplicationItem: PrototypeItem, PrototypeItemComponent {
  let baseView = NSView()

  override var isSelected: Bool { didSet { updateState() } }

  private var layoutConstraints = [NSLayoutConstraint]()

  override func loadView() {
    super.loadView()
    self.view.wantsLayer = true
    let iconView = NSImageView()
    let titleLabel = NSTextField()
    let subtitleLabel = NSTextField()
    let checkbox = NSButton()
    checkbox.cell?.title = "Sync enabled"
    checkbox.setButtonType(.switch)

    addView(iconView, with: "iconView")
    addView(titleLabel, with: "titleLabel")
    addView(subtitleLabel, with: "subtitleLabel")
//    addView(checkbox, with: "checkbox")

    let verticalStackView = NSStackView(views: [titleLabel, subtitleLabel])
    verticalStackView.alignment = .left
    verticalStackView.orientation = .vertical
    verticalStackView.spacing = 0
    verticalStackView.setCustomSpacing(8, after: subtitleLabel)

    let stackView = NSStackView(views: [iconView, verticalStackView])
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
      iconView.heightAnchor.constraint(equalToConstant: 32)
    ]
    NSLayoutConstraint.activate(layoutConstraints)
  }

  private func updateState() {
    if isSelected {
      view.layer?.backgroundColor = NSColor.controlAccentColor.withAlphaComponent(0.33).cgColor
    } else {
      view.layer?.backgroundColor = NSColor.clear.cgColor
    }
  }
}
