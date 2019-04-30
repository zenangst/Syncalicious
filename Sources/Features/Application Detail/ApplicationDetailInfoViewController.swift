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
  lazy var stackView = NSStackView()
  lazy var horizontalStackView = NSStackView()
  lazy var iso8601DateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return dateFormatter
  }()

  var application: Application?

  // swiftlint:disable function_body_length
  func render(_ application: Application,
              backupController: BackupController,
              iconController: IconController,
              syncController: SyncController,
              machineController: MachineController) {
    self.application = application
    let applicationIsSynced = syncController.applicationIsSynced(application, on: machineController.machine)

    view.subviews.forEach { $0.removeFromSuperview() }
    stackView.subviews.forEach { $0.removeFromSuperview() }
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

    let leftStackView: NSStackView
    if application.needsFullDiskAccess {
      leftStackView = createStackView(.vertical, views: [iconView])
      leftStackView.alignment = .centerX
      leftStackView.setCustomSpacing(20, after: iconView)
      horizontalStackView.addArrangedSubview(leftStackView)
    } else {
      let backupButton: NSButton
      if backupController.doesBackupExists(for: application, on: machineController.machine, at: UserDefaults.standard.syncaliciousUrl!) != nil {
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

    if let backupDestination = UserDefaults.standard.syncaliciousUrl {
      let backupDate = backupController.doesBackupExists(for: application,
                                                         on: machineController.machine,
                                                         at: backupDestination)
      if let backupDate = backupDate {
        let dateString = iso8601DateFormatter.string(from: backupDate)
        stackView.addArrangedSubview(createStackView(.horizontal, views: [
          BoldLabel(text: "Last backup:"),
          Label(text: "\(dateString)")]))
      }
    }

    if application.needsFullDiskAccess {
      let fullDiskPermission = Button(title: "Needs Full Disk Permission",
                                      backgroundColor: NSColor(named: "Yellow")!,
                                      borderColor: NSColor(named: "Yellow")!,
                                      borderWidth: 1.5,
                                      cornerRadius: .custom(4),
                                      target: self,
                                      action: #selector(fullDiskAccess))

      stackView.addArrangedSubview(fullDiskPermission)
    } else {
      if let syncDate = syncController.applicationLastSynced(application) {
        let dateString = iso8601DateFormatter.string(from: syncDate)
        stackView.addArrangedSubview(createStackView(.horizontal, views: [
          BoldLabel(text: "Last sync:"),
          Label(text: "\(dateString)")]))
      }
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
