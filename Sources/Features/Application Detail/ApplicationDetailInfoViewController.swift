import Cocoa

protocol ApplicationDetailInfoViewControllerDelegate: class {
  func applicationDetailInfoViewController(_ controller: ApplicationDetailInfoViewController,
                                           didTapBackup backupButton: NSButton)
  func applicationDetailInfoViewController(_ controller: ApplicationDetailInfoViewController,
                                           didTapSync syncButton: NSButton)
  func applicationDetailInfoViewController(_ controller: ApplicationDetailInfoViewController,
                                           didTapUnsync unsyncButton: NSButton)
}

class ApplicationDetailInfoViewController: ViewController {
  weak var delegate: ApplicationDetailInfoViewControllerDelegate?
  private var layoutConstraints = [NSLayoutConstraint]()
  let backupController: BackupController
  let iconController: IconController
  let syncController: SyncController
  let machine: Machine
  lazy var stackView = NSStackView()
  lazy var horizontalStackView = NSStackView()

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

  func render(_ application: Application,
              syncController: SyncController,
              machineController: MachineController) {
    let applicationIsSynced = syncController.applicationIsSynced(application, on: machine)

    view.subviews.forEach { $0.removeFromSuperview() }
    stackView.subviews.forEach { $0.removeFromSuperview() }
    horizontalStackView.subviews.forEach { $0.removeFromSuperview() }
    NSLayoutConstraint.deactivate(layoutConstraints)
    layoutConstraints = []

    let iconView = NSImageView()
    let image = iconController.icon(at: application.url, for: application.propertyList.bundleIdentifier)
    iconView.image = image

    let nameLabel = Label(text: application.propertyList.bundleName)
    nameLabel.font = NSFont.boldSystemFont(ofSize: 32)

    horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
    horizontalStackView.distribution = .gravityAreas
    horizontalStackView.orientation = .horizontal
    horizontalStackView.alignment = .top
    horizontalStackView.spacing = 20

    let backupButton = NSButton(title: "Backup", target: self, action: #selector(performBackup))
    let syncButton: NSButton
    if syncController.applicationIsSynced(application, on: machineController.machine) {
      syncButton = NSButton(title: "Unsync", target: self, action: #selector(unsync(_:)))
    } else {
      syncButton = NSButton(title: "Sync", target: self, action: #selector(sync(_:)))
    }

    let leftStackView = createStackView(.vertical, views: [
      iconView, backupButton, syncButton])
    leftStackView.alignment = .centerX
    leftStackView.setCustomSpacing(20, after: iconView)
    horizontalStackView.addArrangedSubview(leftStackView)

    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.alignment = .top
    stackView.distribution = .gravityAreas
    stackView.orientation = .vertical

    stackView.addArrangedSubview(createStackView(.horizontal, views: [
      BoldLabel(text: "Version:"),
      Label(text: application.propertyList.versionString)]))
    stackView.addArrangedSubview(createStackView(.horizontal, views: [
      BoldLabel(text: "Bundle identifier:"),
      Label(text: application.propertyList.bundleIdentifier)]))
    stackView.addArrangedSubview(createStackView(.horizontal, views: [
      BoldLabel(text: "Location:"),
      Label(text: application.url.path)]))

    if let backupDestination = UserDefaults.standard.backupDestination {
      let backupText = backupController.doesBackupExists(for: application, at: backupDestination) ? "Yes" : "No"
      stackView.addArrangedSubview(createStackView(.horizontal, views: [
        BoldLabel(text: "Backup exists:"),
        Label(text: backupText)]))
    }

    let syncText = applicationIsSynced ? "Yes" : "No"
    stackView.addArrangedSubview(createStackView(.horizontal, views: [
      BoldLabel(text: "Is synced:"),
      Label(text: syncText)]))

    horizontalStackView.addArrangedSubview(stackView)
    view.addSubview(horizontalStackView)

    layoutConstraints = [
      horizontalStackView.topAnchor.constraint(equalTo: view.topAnchor),
      horizontalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      horizontalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ]
    NSLayoutConstraint.activate(layoutConstraints)
    horizontalStackView.needsUpdateConstraints = true
    horizontalStackView.updateConstraints()
  }

  override func viewDidLayout() {
    super.viewDidLayout()
    view.frame.size.height = horizontalStackView.frame.size.height
  }

  // MARK: - Private methods

  private func createStackView(_ orientation: NSUserInterfaceLayoutOrientation, views: [NSView]) -> NSStackView {
    let stackView = NSStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.alignment = .leading
    stackView.orientation = orientation
    stackView.spacing = 5
    views.forEach { stackView.addArrangedSubview($0) }
    return stackView
  }

  // MARK: - Actions

  @objc func performBackup(_ sender: NSButton) {
    delegate?.applicationDetailInfoViewController(self, didTapBackup: sender)
  }

  @objc func sync(_ sender: NSButton) {
    delegate?.applicationDetailInfoViewController(self, didTapSync: sender)
  }

  @objc func unsync(_ sender: NSButton) {
    delegate?.applicationDetailInfoViewController(self, didTapUnsync: sender)
  }
}
