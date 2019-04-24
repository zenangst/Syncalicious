import Cocoa

protocol ApplicationDetailInfoViewControllerDelegate: class {
  func applicationDetailInfoViewController(_ controller: ApplicationDetailInfoViewController,
                                           didTapBackup backupButton: NSButton,
                                           on application: Application)
  func applicationDetailInfoViewController(_ controller: ApplicationDetailInfoViewController,
                                           didTapSync syncButton: NSButton,
                                           on application: Application)
  func applicationDetailInfoViewController(_ controller: ApplicationDetailInfoViewController,
                                           didTapUnsync unsyncButton: NSButton,
                                           on application: Application)
}

class ApplicationDetailInfoViewController: ViewController {
  weak var delegate: ApplicationDetailInfoViewControllerDelegate?
  let backupController: BackupController
  let iconController: IconController
  let syncController: SyncController
  let machine: Machine
  lazy var stackView = NSStackView()
  lazy var horizontalStackView = NSStackView()

  var application: Application?

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

  // swiftlint:disable function_body_length
  func render(_ application: Application,
              syncController: SyncController,
              machineController: MachineController) {
    self.application = application
    let applicationIsSynced = syncController.applicationIsSynced(application, on: machine)

    view.subviews.forEach { $0.removeFromSuperview() }
    stackView.subviews.forEach { $0.removeFromSuperview() }
    horizontalStackView.subviews.forEach { $0.removeFromSuperview() }
    NSLayoutConstraint.deactivate(layoutConstraints)
    layoutConstraints = []

    let iconView = NSImageView()
    iconView.imageScaling = .scaleProportionallyUpOrDown
    let image = iconController.icon(at: application.url, for: application.propertyList.bundleIdentifier)
    iconView.image = image

    let nameLabel = Label(text: application.propertyList.bundleName)
    nameLabel.font = NSFont.boldSystemFont(ofSize: 32)

    horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
    horizontalStackView.distribution = .gravityAreas
    horizontalStackView.orientation = .horizontal
    horizontalStackView.alignment = .top
    horizontalStackView.spacing = 20

    let leftStackView: NSStackView
    if application.needsFullDiskAccess {
      leftStackView = createStackView(.vertical, views: [iconView])
      leftStackView.alignment = .centerX
      leftStackView.setCustomSpacing(20, after: iconView)
      horizontalStackView.addArrangedSubview(leftStackView)
    } else {
      let backupButton: NSButton
      if backupController.doesBackupExists(for: application, at: UserDefaults.standard.backupDestination!) {
        backupButton = Button(title: "Backup",
                              backgroundColor: NSColor(named: "Green")!,
                              borderColor: NSColor(named: "Green")!,
                              borderWidth: 1.5,
                              cornerRadius: .custom(4),
                              target: self,
                              action: #selector(performBackup))
      } else {
        backupButton = Button(title: "Backup",
                              backgroundColor: NSColor.clear,
                              borderColor: NSColor(named: "Green")!,
                              borderWidth: 1.5,
                              cornerRadius: .custom(4),
                              target: self,
                              action: #selector(performBackup))
      }

      let syncButton: NSButton
      if syncController.applicationIsSynced(application, on: machineController.machine) {
        syncButton = Button(title: "Unsync",
                            backgroundColor: NSColor.init(named: "Blue")!,
                            borderColor: NSColor.init(named: "Blue")!,
                            borderWidth: 1.5,
                            cornerRadius: .custom(4),
                            target: self, action: #selector(unsync(_:)))
      } else {
        syncButton = Button(title: "Sync",
                            backgroundColor: NSColor.clear,
                            borderColor: NSColor.init(named: "Blue")!,
                            borderWidth: 1.5,
                            cornerRadius: .custom(4),
                            target: self, action: #selector(sync(_:)))
      }

      leftStackView = createStackView(.vertical, views: [iconView, backupButton, syncButton])
      leftStackView.alignment = .centerX
      leftStackView.setCustomSpacing(20, after: iconView)
      horizontalStackView.addArrangedSubview(leftStackView)
      layoutConstraints.append(syncButton.widthAnchor.constraint(equalTo: backupButton.widthAnchor))
    }

    layoutConstraints.append(leftStackView.widthAnchor.constraint(equalToConstant: 128))

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

    if application.needsFullDiskAccess {
      let fullDiskPermission = Button(title: "Needs Full Disk Permission",
                                      backgroundColor: NSColor(named: "Yellow")!,
                                      borderColor: NSColor(named: "Yellow")!,
                                      borderWidth: 1.5,
                                      cornerRadius: .custom(4),
                                      target: self,
                                      action: #selector(fullDiskAccess))

      stackView.addArrangedSubview(fullDiskPermission)
    }

    horizontalStackView.addArrangedSubview(stackView)
    view.addSubview(horizontalStackView)

    layoutConstraints.append(contentsOf: [
      iconView.widthAnchor.constraint(equalToConstant: 128),
      iconView.heightAnchor.constraint(equalToConstant: 128),
      horizontalStackView.topAnchor.constraint(equalTo: view.topAnchor),
      horizontalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      horizontalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ])
    NSLayoutConstraint.activate(layoutConstraints)
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

  private func showPermissionsDialog(for application: Application, handler completion: (Bool) -> Void) {
    let alert = NSAlert()
    alert.messageText = "Additional privileges needed"
    alert.informativeText = """
    To be able to change the appearance of apps like Mail, Messages, Safari and Home, you need to grant permission Full Disk Access.

    """
    alert.alertStyle = .informational
    alert.addButton(withTitle: "Open Security & Preferences")
    alert.addButton(withTitle: "OK")
    completion(alert.runModal() == .alertFirstButtonReturn)
  }

  // MARK: - Actions

  @objc func fullDiskAccess(_ sender: NSButton) {
    guard let application = application else { return }
    showPermissionsDialog(for: application) { result in
      guard result else { return }
      let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!
      NSWorkspace.shared.open(url)
    }
  }

  @objc func performBackup(_ sender: NSButton) {
    guard let application = application else { return }
    delegate?.applicationDetailInfoViewController(self, didTapBackup: sender, on: application)
  }

  @objc func sync(_ sender: NSButton) {
    guard let application = application else { return }
    delegate?.applicationDetailInfoViewController(self, didTapSync: sender, on: application)
  }

  @objc func unsync(_ sender: NSButton) {
    guard let application = application else { return }
    delegate?.applicationDetailInfoViewController(self, didTapUnsync: sender, on: application)
  }
}
