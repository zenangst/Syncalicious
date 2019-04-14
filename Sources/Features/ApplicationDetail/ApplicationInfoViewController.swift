import Cocoa

class ApplicationInfoViewController: ViewController {
  private var layoutConstraints = [NSLayoutConstraint]()
  let backupController: BackupController
  let syncController: SyncController
  let machine: Machine
  lazy var stackView = NSStackView()

  init(backupController: BackupController, machine: Machine, syncController: SyncController) {
    self.backupController = backupController
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
    let image = NSWorkspace.shared.icon(forFile: application.url.path)
    iconView.image = image

    let nameLabel = Label(text: application.propertyList.bundleName)
    nameLabel.font = NSFont.boldSystemFont(ofSize: 32)

    let horizontalStackView = NSStackView()
    horizontalStackView.orientation = .horizontal
    horizontalStackView.addArrangedSubview(iconView)
    horizontalStackView.addArrangedSubview(nameLabel)

    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.orientation = .vertical
    stackView.alignment = .leading
    stackView.addArrangedSubview(horizontalStackView)

    stackView.addArrangedSubview(createVerticalStackView(with: [
      BoldLabel(text: "Version:"),
      Label(text: application.propertyList.versionString),
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

    view.addSubview(stackView)
    layoutConstraints = [
      stackView.topAnchor.constraint(equalTo: view.topAnchor),
      stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ]
    NSLayoutConstraint.activate(layoutConstraints)
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
