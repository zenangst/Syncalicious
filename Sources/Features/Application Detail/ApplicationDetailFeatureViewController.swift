import Cocoa

class ApplicationDetailFeatureViewController: NSViewController,
  ApplicationDetailInfoViewControllerDelegate,
  SplitViewContainedController,
  NSCollectionViewDelegate {

  weak var listViewController: ApplicationListItemViewController?

  lazy var titleLabel = SmallBoldLabel()
  lazy var titlebarView = NSView()

  private var layoutConstraints = [NSLayoutConstraint]()

  let containerViewController: ApplicationDetailContainerViewController
  let applicationInfoViewController: ApplicationDetailInfoViewController
  let applicationController: ApplicationController
  let backupController: BackupController
  let syncController: SyncController
  let machineController: MachineController
  let customizeViewController = ViewController()
  var application: Application?

  init(applicationInfoViewController: ApplicationDetailInfoViewController,
       applicationController: ApplicationController,
       backupController: BackupController,
       containerViewController: ApplicationDetailContainerViewController,
       machineController: MachineController,
       syncController: SyncController) {
    self.applicationController = applicationController
    self.applicationInfoViewController = applicationInfoViewController
    self.backupController = backupController
    self.containerViewController = containerViewController
    self.machineController = machineController
    self.syncController = syncController
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    view = containerViewController.view
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.wantsLayer = true

    customizeViewController.view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
    containerViewController.addChild(applicationInfoViewController,
                                     customInsets: .init(top: 15, left: 30, bottom: 15, right: 30))

    containerViewController.addChild(customizeViewController, height: 280)
  }

  override func viewWillLayout() {
    super.viewWillLayout()

    if view.effectiveAppearance.name == .aqua {
      customizeViewController.view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
      view.layer?.backgroundColor = NSColor.white.cgColor
    } else {
      customizeViewController.view.layer?.backgroundColor = NSColor.darkGray.cgColor
      view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
    }
  }

  private func render(_ applications: [Application]) {
    applicationInfoViewController.view.isHidden = true
  }

  private func render(_ application: Application) {
    applicationInfoViewController.view.isHidden = false
    applicationInfoViewController.render(application,
                                         syncController: syncController,
                                         machineController: machineController)
    NSLayoutConstraint.deactivate(layoutConstraints)
    layoutConstraints = []

    titlebarView.subviews.forEach { $0.removeFromSuperview() }
    titleLabel.stringValue = application.propertyList.bundleName
    titleLabel.alignment = .center
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titlebarView.wantsLayer = true
    titlebarView.addSubview(titleLabel)

    layoutConstraints.append(contentsOf: [
      titleLabel.leadingAnchor.constraint(equalTo: titlebarView.leadingAnchor, constant: 10),
      titleLabel.trailingAnchor.constraint(equalTo: titlebarView.trailingAnchor, constant: -10),
      titleLabel.centerYAnchor.constraint(equalTo: titlebarView.centerYAnchor)
      ])

    applicationInfoViewController.delegate = self

    NSLayoutConstraint.activate(layoutConstraints)
  }

  private func refreshApplicationList() {
    guard let locations = try? applicationController.applicationDirectories() else { return }
    applicationController.loadApplications(at: locations)
  }

  private func handleSelections(in collectionView: NSCollectionView) {
    if collectionView.selectionIndexPaths.count > 1 {
      render([])
    } else {
      guard let indexPath = collectionView.selectionIndexPaths.first else { return }
      guard let listViewController = listViewController else { return }

      let application = listViewController.model(at: indexPath).application
      self.application = application
      render(application)
    }
  }

  // MARK: - ApplicationDetailInfoViewControllerDelegate

  func applicationDetailInfoViewController(_ controller: ApplicationDetailInfoViewController,
                                           didTapBackup backupButton: NSButton) {
    guard let application = application else { return }
    guard let backupDestination = UserDefaults.standard.backupDestination else { return }
    try? backupController.runBackup(for: [application], to: backupDestination)
    render(application)
    refreshApplicationList()
  }

  func applicationDetailInfoViewController(_ controller: ApplicationDetailInfoViewController,
                                           didTapSync syncButton: NSButton) {
    guard let application = application else { return }
    try? syncController.enableSync(for: application, on: machineController.machine)
    render(application)
    refreshApplicationList()
  }

  func applicationDetailInfoViewController(_ controller: ApplicationDetailInfoViewController,
                                           didTapUnsync unsyncButton: NSButton) {
    guard let application = application else { return }
    try? syncController.disableSync(for: application, on: machineController.machine)
    render(application)
    refreshApplicationList()

  }

  // MARK: - NSCollectionViewDelegate

  func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
    handleSelections(in: collectionView)
  }

  func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
    handleSelections(in: collectionView)
  }
}
