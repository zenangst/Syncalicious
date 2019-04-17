import Cocoa
import Family

class ApplicationDetailContainerViewController: FamilyViewController,
  SplitViewContainedController, NSCollectionViewDelegate {
  weak var listViewController: ApplicationListItemViewController?

  lazy var titleLabel = SmallBoldLabel()
  lazy var titlebarView = NSView()

  private var layoutConstraints = [NSLayoutConstraint]()

  let applicationInfoViewController: ApplicationDetailInfoViewController
  let backupController: BackupController
  let syncController: SyncController
  let machineController: MachineController
  var application: Application?

  init(applicationInfoViewController: ApplicationDetailInfoViewController,
       backupController: BackupController,
       machineController: MachineController,
       syncController: SyncController) {
    self.applicationInfoViewController = applicationInfoViewController
    self.backupController = backupController
    self.machineController = machineController
    self.syncController = syncController
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    view.wantsLayer = true
    view.layer?.backgroundColor = NSColor.white.cgColor
    addChild(applicationInfoViewController,
             customInsets: .init(top: 15, left: 15, bottom: 15, right: 15))
  }

  // MARK: - Private methods

  private func render(_ application: Application) {
    applicationInfoViewController.render(application)
    NSLayoutConstraint.deactivate(layoutConstraints)
    layoutConstraints = []

    titlebarView.subviews.forEach { $0.removeFromSuperview() }
    titleLabel.stringValue = application.propertyList.bundleName
    titleLabel.alignment = .center
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titlebarView.wantsLayer = true
    titlebarView.addSubview(titleLabel)

    let backupButton = NSButton(title: "Backup", target: self, action: #selector(performBackup))
    backupButton.translatesAutoresizingMaskIntoConstraints = false
    titlebarView.addSubview(backupButton)

    let syncButton: NSButton
    if syncController.applicationIsSynced(application, on: machineController.machine) {
      syncButton = NSButton(title: "Unsync", target: self, action: #selector(unsync))
    } else {
      syncButton = NSButton(title: "Sync", target: self, action: #selector(sync))
    }

    syncButton.translatesAutoresizingMaskIntoConstraints = false
    titlebarView.addSubview(syncButton)

    layoutConstraints.append(contentsOf: [
      titleLabel.leadingAnchor.constraint(equalTo: titlebarView.leadingAnchor, constant: 10),
      titleLabel.trailingAnchor.constraint(equalTo: titlebarView.trailingAnchor, constant: -10),
      titleLabel.centerYAnchor.constraint(equalTo: titlebarView.centerYAnchor),
      syncButton.trailingAnchor.constraint(equalTo: backupButton.leadingAnchor, constant: -5),
      syncButton.centerYAnchor.constraint(equalTo: titlebarView.centerYAnchor),
      backupButton.centerYAnchor.constraint(equalTo: titlebarView.centerYAnchor),
      backupButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
      ])

    NSLayoutConstraint.activate(layoutConstraints)
  }

  // MARK: - Actions

  @objc func performBackup() {
    guard let application = application else { return }
    guard let backupDestination = UserDefaults.standard.backupDestination else { return }
    try? backupController.runBackup(for: [application], to: backupDestination)
    render(application)
  }

  @objc func sync() {
    guard let application = application else { return }
    try? syncController.enableSync(for: application, on: machineController.machine)
    render(application)
  }

  @objc func unsync() {
    guard let application = application else { return }
    try? syncController.disableSync(for: application, on: machineController.machine)
    render(application)
  }

  // MARK: - NSCollectionViewDelegate

  func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
    guard let indexPath = indexPaths.first else { return }
    guard let listViewController = listViewController else { return }
    guard let application = listViewController.model(at: indexPath).data["model"] as? Application else { return }

    self.application = application
    render(application)
  }
}
