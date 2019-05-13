import Cocoa

protocol GeneralActionsViewControllerDelegate: class {
  func generalActionsViewController(_ controller: GeneralActionsViewController,
                                    didTapBackup backupButton: NSButton,
                                    on application: Application)
  func generalActionsViewController(_ controller: GeneralActionsViewController,
                                    didTapSync syncButton: NSButton,
                                    on application: Application)
  func generalActionsViewController(_ controller: GeneralActionsViewController,
                                    didTapUnsync unsyncButton: NSButton,
                                    on application: Application)
}

class GeneralActionsViewController: ViewController {
  weak var delegate: GeneralActionsViewControllerDelegate?
  private(set) var application: Application?
  lazy var gridView = NSGridView()

  lazy var iso8601DateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return dateFormatter
  }()

  func render(application: Application,
              backupController: BackupController,
              syncController: SyncController,
              machineController: MachineController) {
    self.application = application
    gridView.subviews.forEach { $0.removeFromSuperview() }
    while gridView.numberOfRows > 0 { gridView.removeRow(at: 0) }

    if application.needsFullDiskAccess {
      renderNeedsPermissions()
    } else {
      renderActions(for: application, in: gridView,
                    backupController: backupController,
                    syncController: syncController,
                    machineController: machineController)
    }

    gridView.yPlacement = .center
    gridView.xPlacement = .fill

    view.addSubview(gridView)
    layoutConstraints = [
      gridView.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
      gridView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
      gridView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
    ]
    NSLayoutConstraint.constrain(layoutConstraints)
  }

  override func viewDidLayout() {
    super.viewDidLayout()
    view.frame.size.height = gridView.frame.size.height + 30
  }

  // MARK: - Private methods

  private func renderNeedsPermissions() {
    let fullDiskPermission = Button(title: "Grant access",
                                    backgroundColor: NSColor(named: "Yellow")!,
                                    borderColor: NSColor(named: "Yellow")!,
                                    borderWidth: 1.5,
                                    cornerRadius: .custom(4),
                                    target: self,
                                    action: #selector(fullDiskAccess))

    let text = """
    To be able to backup or sync apps like Mail, Messages, Safari and Home, you need to grant permission Full Disk Access.
    """
    let label = Label(text: text)
    label.maximumNumberOfLines = -1
    label.lineBreakMode = .byWordWrapping

    NSLayoutConstraint.constrain([
      fullDiskPermission.widthAnchor.constraint(equalToConstant: 120)
      ])

    gridView.addRow(with: [fullDiskPermission,
                           label])
    gridView.column(at: 0).leadingPadding = 5
    gridView.column(at: 0).trailingPadding = 20
  }

  private func renderActions(for application: Application,
                             in gridView: NSGridView,
                             backupController: BackupController,
                             syncController: SyncController,
                             machineController: MachineController) {
    let syncButton: NSButton
    var backupRow = [NSView]()
    var syncRow = [NSView]()

    let applicationIsSynced = syncController.applicationIsSynced(application,
                                                                 on: machineController.machine)
    let backupExists = backupController.doesBackupExists(for: application,
                                                         on: machineController.machine,
                                                         at: UserDefaults.standard.syncaliciousUrl!) != nil
    let backupButton = Button(title: "Backup",
                              backgroundColor: backupExists ? NSColor(named: "Green")! : NSColor.clear,
                              borderColor: NSColor(named: "Green")!,
                              borderWidth: 1.5,
                              cornerRadius: .custom(4),
                              target: self,
                              action: #selector(performBackup))
    backupRow.append(backupButton)

    if let syncaliciousUrl = UserDefaults.standard.syncaliciousUrl {
      let backupDate = backupController.doesBackupExists(for: application,
                                                         on: machineController.machine,
                                                         at: syncaliciousUrl)
      if let backupDate = backupDate {
        let dateString = iso8601DateFormatter.string(from: backupDate)
        backupRow.append(BoldLabel(text: "Last backup:"))
        backupRow.append(Label(text: "\(dateString)"))
      }
    }

    if applicationIsSynced {
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

    syncRow.append(syncButton)

    NSLayoutConstraint.constrain([
      backupButton.widthAnchor.constraint(equalToConstant: 120),
      syncButton.widthAnchor.constraint(equalToConstant: 120)
      ])

    if let syncDate = syncController.applicationLastSynced(application) {
      let dateString = iso8601DateFormatter.string(from: syncDate)
      syncRow.append(BoldLabel(text: "Last sync:"))
      syncRow.append(Label(text: "\(dateString)"))
    }

    gridView.addRow(with: backupRow)

    gridView.column(at: 0).leadingPadding = 5
    gridView.column(at: 0).trailingPadding = 18

    gridView.addRow(with: syncRow)
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
    delegate?.generalActionsViewController(self, didTapBackup: sender, on: application)
  }

  @objc func sync(_ sender: NSButton) {
    guard let application = application else { return }
    delegate?.generalActionsViewController(self, didTapSync: sender, on: application)
  }

  @objc func unsync(_ sender: NSButton) {
    guard let application = application else { return }
    delegate?.generalActionsViewController(self, didTapUnsync: sender, on: application)
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
}
