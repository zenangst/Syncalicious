import Cocoa

class GeneralInfoViewController: ViewController {
  lazy var rightStackView = VStack()
  lazy var horizontalStackView = HStack()

  var application: Application?

  func render(_ application: Application,
              iconController: IconController,
              machineController: MachineController) {
    self.application = application

    view.subviews.forEach { $0.removeFromSuperview() }
    rightStackView.subviews.forEach { $0.removeFromSuperview() }
    horizontalStackView.subviews.forEach { $0.removeFromSuperview() }
    NSLayoutConstraint.deactivate(layoutConstraints)
    layoutConstraints = []

    let iconView = NSImageView()
    iconView.imageScaling = .scaleProportionallyUpOrDown

    iconController.loadIcon(at: application.url,
                            identifier: application.propertyList.bundleIdentifier,
                            queue: nil) { iconView.image = $0 }

    let nameLabel = Label(text: application.propertyList.bundleName)
    nameLabel.font = NSFont.boldSystemFont(ofSize: 32)

    horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
    horizontalStackView.distribution = .gravityAreas
    horizontalStackView.orientation = .horizontal
    horizontalStackView.alignment = .top
    horizontalStackView.spacing = 20

    let leftStackView = createStackView(.vertical, views: [iconView])
    leftStackView.alignment = .centerX
    leftStackView.setCustomSpacing(20, after: iconView)
    horizontalStackView.addArrangedSubview(leftStackView)

    layoutConstraints.append(leftStackView.widthAnchor.constraint(equalToConstant: 128))

    rightStackView.translatesAutoresizingMaskIntoConstraints = false
    rightStackView.alignment = .top
    rightStackView.distribution = .gravityAreas
    rightStackView.orientation = .vertical

    let applicationTitleLabel = BoldLabel()
    applicationTitleLabel.font = NSFont.boldSystemFont(ofSize: 32)
    applicationTitleLabel.stringValue = application.propertyList.bundleName
    rightStackView.addArrangedSubview(applicationTitleLabel)

    rightStackView.addArrangedSubview(createStackView(.horizontal, views: [
      BoldLabel(text: "Version:").horizontalCompressionResistance(.defaultHigh),
      Label(text: application.propertyList.versionString)
        .horizontalCompressionResistance(.defaultLow)
        .horizontalContentHugging(.defaultLow)
    ]))
    rightStackView.addArrangedSubview(createStackView(.horizontal, views: [
      BoldLabel(text: "Bundle identifier:").horizontalCompressionResistance(.defaultHigh),
      Label(text: application.propertyList.bundleIdentifier)
        .horizontalCompressionResistance(.defaultLow)
        .horizontalContentHugging(.defaultLow)
    ])
    )
    rightStackView.addArrangedSubview(createStackView(.horizontal, views: [
      BoldLabel(text: "Location:").horizontalCompressionResistance(.defaultHigh),
      Label(text: application.url.path)
        .horizontalCompressionResistance(.defaultLow)
        .horizontalContentHugging(.defaultLow)
    ]))
    rightStackView.addArrangedSubview(createStackView(.horizontal, views: [
      BoldLabel(text: "Property list:").horizontalCompressionResistance(.defaultHigh),
      Label(text: application.preferences.url.path)
        .horizontalCompressionResistance(.defaultLow)
        .horizontalContentHugging(.defaultLow)
    ]))

    horizontalStackView.addArrangedSubview(rightStackView)
    view.addSubview(horizontalStackView)

    layoutConstraints.append(contentsOf: [
      iconView.widthAnchor.constraint(equalToConstant: 128),
      iconView.heightAnchor.constraint(equalToConstant: 128),
      horizontalStackView.topAnchor.constraint(equalTo: view.topAnchor),
      horizontalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      horizontalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      rightStackView.heightAnchor.constraint(equalTo: horizontalStackView.heightAnchor)
      ])
    NSLayoutConstraint.activate(layoutConstraints)
  }

  override func viewDidLayout() {
    super.viewDidLayout()
    view.frame.size.height = horizontalStackView.frame.size.height
  }

  // MARK: - Private methods

  private func addStackView(_ stackView: NSStackView, to otherStackView: NSStackView) {
    otherStackView.addArrangedSubview(stackView)
  }

  private func createStackView(_ orientation: NSUserInterfaceLayoutOrientation, views: [NSView]) -> NSStackView {
    let stackView = NSStackView()
    stackView.alignment = .leading
    stackView.orientation = orientation
    stackView.spacing = 5
    views.forEach { stackView.addArrangedSubview($0) }

    return stackView
  }
}
