import Cocoa

class ApplicationDetailFeatureViewController: NSViewController,
  ApplicationDetailInfoViewControllerDelegate,
  SplitViewContainedController,
  NSCollectionViewDelegate {

  enum State {
    case multiple([Application])
    case single(Application)
  }

  weak var listViewController: ApplicationListItemViewController?

  lazy var titleLabel = SmallBoldLabel()
  lazy var titlebarView = NSView()

  private var layoutConstraints = [NSLayoutConstraint]()

  let containerViewController: ApplicationDetailContainerViewController
  let applicationController: ApplicationController
  let backupController: BackupController
  let syncController: SyncController
  let machineController: MachineController

  var machines = [Machine]()
  var application: Application?

  init(applicationController: ApplicationController,
       backupController: BackupController,
       containerViewController: ApplicationDetailContainerViewController,
       machineController: MachineController,
       syncController: SyncController) {
    self.applicationController = applicationController
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
    view.wantsLayer = true
  }

  override func viewWillLayout() {
    super.viewWillLayout()

    if view.effectiveAppearance.name == .aqua {
      view.layer?.backgroundColor = NSColor.white.cgColor
    } else {
      view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
    }
  }

  func refreshCurrentApplicationIfNeeded() {
    guard let application = application else { return }
    render(.single(application))
  }

  private func render(_ state: State) {
    switch state {
    case .multiple(let applications):
      self.application = nil
      let models = applications
        .compactMap({ ApplicationDetailItemModel(title: $0.propertyList.bundleName,
                                                 application: $0) })
      titleLabel.stringValue = "Multi selection (\(models.count))"
      containerViewController.applicationsDetailViewController.collectionView.isHidden = false
      containerViewController.applicationInfoViewController.view.isHidden = true
      containerViewController.applicationComputersViewController.reload(with: [])
      containerViewController.applicationsDetailViewController.reload(with: models)
    case .single(let application):
      containerViewController.applicationInfoViewController.view.isHidden = false
      containerViewController.applicationsDetailViewController.collectionView.isHidden = true
      containerViewController.applicationsDetailViewController.reload(with: [])
      containerViewController.applicationInfoViewController.render(application,
                                                                   syncController: syncController,
                                                                   machineController: machineController)

      if let backupDestination = UserDefaults.standard.backupDestination {
        let closure: (Machine) -> ApplicationComputerDetailItemModel = { machine in
          let image = backupDestination
            .appendingPathComponent(machine.name)
            .appendingPathComponent("Info")
            .appendingPathComponent("Computer.tiff")
          let synced = self.syncController.applicationIsSynced(application, on: machine)
          let backuped = self.backupController.doesBackupExists(for: application,
                                                                on: machine,
                                                                at: UserDefaults.standard.backupDestination!)

          return ApplicationComputerDetailItemModel(title: machine.localizedName,
                                                    subtitle: machine.state.rawValue.capitalized,
                                                    backuped: backuped,
                                                    image: image,
                                                    machine: machine,
                                                    synced: synced)
        }

        var models = [ApplicationComputerDetailItemModel]()
        models.append(closure(machineController.machine))
        models.append(contentsOf: machines.compactMap(closure))
        containerViewController.applicationComputersViewController.reload(with: models)
      }

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

      containerViewController.applicationInfoViewController.delegate = self

      NSLayoutConstraint.activate(layoutConstraints)
    }
  }

  private func refreshApplicationList() {
    guard let locations = try? applicationController.applicationDirectories() else { return }
    applicationController.loadApplications(at: locations)
  }

  private func handleSelections(in collectionView: NSCollectionView) {
    if collectionView.selectionIndexPaths.count > 1 {
      guard let listViewController = listViewController else { return }
      var applications = [Application]()
      collectionView.selectionIndexPaths.forEach {
        applications.append( listViewController.model(at: $0).application )
      }
      let sortedApplications = applications.sorted(by: { $0.propertyList.bundleName.lowercased() < $1.propertyList.bundleName.lowercased() })
      render(.multiple(sortedApplications))
    } else {
      guard let indexPath = collectionView.selectionIndexPaths.first else { return }
      guard let listViewController = listViewController else { return }

      let application = listViewController.model(at: indexPath).application
      self.application = application
      render(.single(application))
    }
  }

  // MARK: - ApplicationDetailInfoViewControllerDelegate

  func applicationDetailInfoViewController(_ controller: ApplicationDetailInfoViewController,
                                           didTapBackup backupButton: NSButton,
                                           on application: Application) {
    guard let backupDestination = UserDefaults.standard.backupDestination else { return }
    try? backupController.runBackup(for: [application], to: backupDestination)
    render(.single(application))
    refreshApplicationList()
  }

  func applicationDetailInfoViewController(_ controller: ApplicationDetailInfoViewController,
                                           didTapSync syncButton: NSButton,
                                           on application: Application) {
    try? syncController.enableSync(for: application, on: machineController.machine)
    render(.single(application))
    refreshApplicationList()
  }

  func applicationDetailInfoViewController(_ controller: ApplicationDetailInfoViewController,
                                           didTapUnsync unsyncButton: NSButton,
                                           on application: Application) {
    try? syncController.disableSync(for: application, on: machineController.machine)
    render(.single(application))
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
