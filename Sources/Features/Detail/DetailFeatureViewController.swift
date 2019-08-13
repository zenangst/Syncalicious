import Cocoa

class DetailFeatureViewController: NSViewController,
  ListFeatureViewControllerDelegate,
  GeneralActionsViewControllerDelegate,
  SplitViewContainedController {

  enum State {
    case multiple([Application])
    case single(Application)
  }

  lazy var titleLabel = SmallBoldLabel()
  lazy var titlebarView = NSView()

  private var layoutConstraints = [NSLayoutConstraint]()
  private(set) var modified: Bool = false

  let containerViewController: DetailContainerViewController
  let applicationController: ApplicationController
  let backupController: BackupController
  let iconController: IconController
  let syncController: SyncController
  let machineController: MachineController

  var machines = [Machine]()
  var application: Application?

  init(applicationController: ApplicationController,
       backupController: BackupController,
       containerViewController: DetailContainerViewController,
       iconController: IconController,
       machineController: MachineController,
       syncController: SyncController) {
    self.applicationController = applicationController
    self.backupController = backupController
    self.containerViewController = containerViewController
    self.iconController = iconController
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
      titleLabel.isHidden = false
      self.application = nil
      let models = applications
        .compactMap({ ApplicationDetailItemModel(title: $0.propertyList.bundleName,
                                                 application: $0) })
      titleLabel.stringValue = "Multi selection (\(models.count))"
      containerViewController.applicationDetailViewController.collectionView.isHidden = false
      containerViewController.generalInfoViewController.view.isHidden = true
      containerViewController.computersViewController.reload(with: [])
      containerViewController.applicationDetailViewController.reload(with: models)
      containerViewController.generalActionsViewController.view.isHidden = true
    case .single(let application):
      titleLabel.isHidden = true
      containerViewController.applicationDetailViewController.reload(with: [])
      containerViewController.generalInfoViewController.render(application,
                                                               iconController: iconController,
                                                               machineController: machineController)
      containerViewController.generalInfoViewController.view.isHidden = false
      containerViewController.applicationDetailViewController.collectionView.isHidden = true
      renderGeneral(for: application)
    }

    NSLayoutConstraint.deactivate(layoutConstraints)
    layoutConstraints = []

    titlebarView.subviews.forEach { $0.removeFromSuperview() }
    titleLabel.alignment = .center

    titlebarView.addSubview(titleLabel)

    layoutConstraints.append(contentsOf: [
      titleLabel.leadingAnchor.constraint(equalTo: titlebarView.leadingAnchor, constant: 10),
      titleLabel.trailingAnchor.constraint(equalTo: titlebarView.trailingAnchor, constant: -10),
      titleLabel.centerYAnchor.constraint(equalTo: titlebarView.centerYAnchor)
      ])

    containerViewController.generalActionsViewController.delegate = self

    NSLayoutConstraint.constrain(layoutConstraints)
  }

  func renderGeneral(for application: Application) {
    if let syncaliciousUrl = UserDefaults.standard.syncaliciousUrl {
      let closure: (Machine) -> ComputerDetailItemModel = { machine in
        let image = syncaliciousUrl
          .appendingPathComponent(machine.name)
          .appendingPathComponent("Info")
          .appendingPathComponent("Computer.tiff")
        let synced = self.syncController.applicationIsSynced(application, on: machine)
        let backupDate = self.backupController.doesBackupExists(for: application,
                                                                on: machine,
                                                                at: UserDefaults.standard.syncaliciousUrl!)
        return ComputerDetailItemModel(title: machine.localizedName,
                                       subtitle: machine.state.rawValue.capitalized,
                                       backupDate: backupDate,
                                       image: image,
                                       machine: machine,
                                       synced: synced)
      }

      var models = [ComputerDetailItemModel]()
      models.append(closure(machineController.machine))
      models.append(contentsOf: machines.compactMap(closure))
      containerViewController.computersViewController.reload(with: models)
    }
    containerViewController.generalActionsViewController.render(application: application,
                                                                backupController: backupController,
                                                                syncController: syncController,
                                                                machineController: machineController)
    containerViewController.generalActionsViewController.view.isHidden = false
    containerViewController.computersViewController.collectionView.isHidden = false
  }

  private func refreshApplicationList() {
    guard let locations = try? applicationController.applicationDirectories() else { return }
    applicationController.loadApplications(at: locations)
  }

  private func handleSelections(for applications: [Application]) {
    if applications.count > 1 {
      render(.multiple(applications))
    } else {
      guard let application = applications.first else { return }
      self.application = application
      render(.single(application))
    }
  }

  // MARK: - GeneralActionsViewControllerDelegate

  func generalActionsViewController(_ controller: GeneralActionsViewController,
                                    didTapBackup backupButton: NSButton,
                                    on application: Application) {
    guard let syncaliciousUrl = UserDefaults.standard.syncaliciousUrl else { return }
    try? backupController.runBackup(for: [application], to: syncaliciousUrl)
    render(.single(application))
    refreshApplicationList()
  }

  func generalActionsViewController(_ controller: GeneralActionsViewController,
                                    didTapSync syncButton: NSButton,
                                    on application: Application) {
    try? syncController.enableSync(for: application, on: machineController.machine)
    render(.single(application))
    refreshApplicationList()
  }

  func generalActionsViewController(_ controller: GeneralActionsViewController,
                                    didTapUnsync unsyncButton: NSButton,
                                    on application: Application) {
    try? syncController.disableSync(for: application, on: machineController.machine)
    render(.single(application))
    refreshApplicationList()
  }

  // MARK: - ListFeatureViewControllerDelegate

  func listFeatureViewController(_ controller: ListFeatureViewController,
                                 didSelectApplications applications: [Application]) {
    handleSelections(for: applications)
  }
}
