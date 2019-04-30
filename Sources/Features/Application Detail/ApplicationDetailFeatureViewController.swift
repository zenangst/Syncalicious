import Cocoa

class ApplicationDetailFeatureViewController: NSViewController,
  ApplicationListFeatureViewControllerDelegate,
  ApplicationDetailInfoViewControllerDelegate,
  SplitViewContainedController {

  enum State {
    case multiple([Application])
    case single(Application)
  }

  lazy var titleLabel = SmallBoldLabel()
  lazy var titlebarView = NSView()

  private var layoutConstraints = [NSLayoutConstraint]()

  let containerViewController: ApplicationDetailContainerViewController
  let applicationController: ApplicationController
  let backupController: BackupController
  let iconController: IconController
  let syncController: SyncController
  let machineController: MachineController

  var machines = [Machine]()
  var application: Application?

  init(applicationController: ApplicationController,
       backupController: BackupController,
       containerViewController: ApplicationDetailContainerViewController,
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
      self.application = nil
      let models = applications
        .compactMap({ ApplicationDetailItemModel(title: $0.propertyList.bundleName,
                                                 application: $0) })
      titleLabel.stringValue = "Multi selection (\(models.count))"
      containerViewController.detailViewController.collectionView.isHidden = false
      containerViewController.infoViewController.view.isHidden = true
      containerViewController.computersViewController.reload(with: [])
      containerViewController.detailViewController.reload(with: models)
    case .single(let application):
      containerViewController.infoViewController.view.isHidden = false
      containerViewController.detailViewController.collectionView.isHidden = true
      containerViewController.detailViewController.reload(with: [])
      containerViewController.infoViewController.render(application,
                                                                   backupController: backupController,
                                                                   iconController: iconController,
                                                                   syncController: syncController,
                                                                   machineController: machineController)

      if let syncaliciousUrl = UserDefaults.standard.syncaliciousUrl {
        let closure: (Machine) -> ApplicationComputerDetailItemModel = { machine in
          let image = syncaliciousUrl
            .appendingPathComponent(machine.name)
            .appendingPathComponent("Info")
            .appendingPathComponent("Computer.tiff")
          let synced = self.syncController.applicationIsSynced(application, on: machine)
          let backupDate = self.backupController.doesBackupExists(for: application,
                                                                  on: machine,
                                                                  at: UserDefaults.standard.syncaliciousUrl!)
          return ApplicationComputerDetailItemModel(title: machine.localizedName,
                                                    subtitle: machine.state.rawValue.capitalized,
                                                    backupDate: backupDate,
                                                    image: image,
                                                    machine: machine,
                                                    synced: synced)
        }

        var models = [ApplicationComputerDetailItemModel]()
        models.append(closure(machineController.machine))
        models.append(contentsOf: machines.compactMap(closure))
        containerViewController.computersViewController.reload(with: models)
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

      containerViewController.infoViewController.delegate = self

      NSLayoutConstraint.activate(layoutConstraints)
    }
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

  // MARK: - ApplicationDetailInfoViewControllerDelegate

  func applicationDetailInfoViewController(_ controller: ApplicationDetailInfoViewController,
                                           didTapBackup backupButton: NSButton,
                                           on application: Application) {
    guard let syncaliciousUrl = UserDefaults.standard.syncaliciousUrl else { return }
    try? backupController.runBackup(for: [application], to: syncaliciousUrl)
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

  // MARK: - ApplicationListFeatureViewControllerDelegate

  func applicationListFeatureViewController(_ controller: ApplicationListFeatureViewController,
                                            didSelectApplications applications: [Application]) {
    handleSelections(for: applications)
  }
}
