import Cocoa

class ApplicationDetailInfoViewController: ViewController {
  private var layoutConstraints = [NSLayoutConstraint]()
  let backupController: BackupController
  let iconController: IconController
  let syncController: SyncController
  let machine: Machine
  lazy var stackView = NSStackView()

  init(backupController: BackupController,
       iconController: IconController,
       machine: Machine,
       syncController: SyncController) {
    self.backupController = backupController
    self.iconController = iconController
    self.machine = machine
    self.syncController = syncController
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func render(_ application: Application) {
    let applicationIsSynced = syncController.applicationIsSynced(application, on: machine)

    view.subviews.forEach { $0.removeFromSuperview() }
    stackView.subviews.forEach { $0.removeFromSuperview() }
    NSLayoutConstraint.deactivate(layoutConstraints)
    layoutConstraints = []

    let iconView = NSImageView()
    let image = iconController.icon(at: application.url, for: application.propertyList.bundleIdentifier)
    iconView.image = image

    let nameLabel = Label(text: application.propertyList.bundleName)
    nameLabel.font = NSFont.boldSystemFont(ofSize: 32)

    let horizontalStackView = NSStackView()
    horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
    horizontalStackView.distribution = .gravityAreas
    horizontalStackView.orientation = .horizontal
    horizontalStackView.alignment = .top
    horizontalStackView.spacing = 20
    horizontalStackView.addArrangedSubview(iconView)

    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.alignment = .top
    stackView.distribution = .gravityAreas
    stackView.orientation = .vertical
    stackView.addArrangedSubview(nameLabel)

    stackView.addArrangedSubview(createVerticalStackView(with: [
      BoldLabel(text: "Version:"),
      Label(text: application.propertyList.versionString)]))
    stackView.addArrangedSubview(createVerticalStackView(with: [
      BoldLabel(text: "Bundle identifier:"),
      Label(text: application.propertyList.bundleIdentifier)]))

    stackView.addArrangedSubview(createVerticalStackView(with: [BoldLabel(text: "Location:"),
                                                                        Label(text: application.url.path)]))

    if let backupDestination = UserDefaults.standard.backupDestination {
      let backupText = backupController.doesBackupExists(for: application, at: backupDestination) ? "Yes" : "No"
      stackView.addArrangedSubview(createVerticalStackView(with: [BoldLabel(text: "Backup exists:"), Label(text: backupText)]))
    }

    let syncText = applicationIsSynced ? "Yes" : "No"
    stackView.addArrangedSubview(createVerticalStackView(with: [BoldLabel(text: "Is synced:"), Label(text: syncText)]))

    horizontalStackView.addArrangedSubview(stackView)
    view.addSubview(horizontalStackView)
    layoutConstraints = [
      horizontalStackView.topAnchor.constraint(equalTo: view.topAnchor),
      horizontalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      horizontalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      horizontalStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ]
    NSLayoutConstraint.activate(layoutConstraints)

    view.frame.size.height = 180
  }

  func createVerticalStackView(with views: [NSView]) -> NSStackView {
    let stackView = NSStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.orientation = .horizontal
    stackView.alignment = .firstBaseline
    stackView.spacing = 5
    views.forEach { stackView.addArrangedSubview($0) }
    return stackView
  }
}
