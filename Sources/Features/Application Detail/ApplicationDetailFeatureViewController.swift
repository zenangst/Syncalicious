import Cocoa

class ApplicationDetailFeatureViewController: NSViewController,
  ApplicationListFeatureViewControllerDelegate,
  ApplicationActionsViewControllerDelegate,
  SplitViewContainedController,
  ApplicationKeyboardActionsViewControllerDelegate {

  enum Tab: String, CaseIterable {
    case general = "General"
    case customize = "Customize"
  }

  enum State {
    case multiple([Application])
    case single(Application)
  }

  lazy var titleLabel = SmallBoldLabel()
  lazy var titlebarView = NSView()
  lazy var segmentedControl = NSSegmentedControl(labels: Tab.allCases.compactMap({ $0.rawValue }),
                                                 trackingMode: .selectOne,
                                                 target: self, action: #selector(changeTab(_:)))

  private var layoutConstraints = [NSLayoutConstraint]()
  private(set) var modified: Bool = false

  let containerViewController: ApplicationDetailContainerViewController
  let applicationController: ApplicationController
  let backupController: BackupController
  let iconController: IconController
  let syncController: SyncController
  let machineController: MachineController
  let keyboardController: KeyboardController

  var machines = [Machine]()
  var application: Application?

  init(applicationController: ApplicationController,
       backupController: BackupController,
       containerViewController: ApplicationDetailContainerViewController,
       iconController: IconController,
       keyboardController: KeyboardController,
       machineController: MachineController,
       syncController: SyncController) {
    self.applicationController = applicationController
    self.backupController = backupController
    self.containerViewController = containerViewController
    self.iconController = iconController
    self.keyboardController = keyboardController
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
      segmentedControl.isHidden = true
      titleLabel.isHidden = false
      self.application = nil
      let models = applications
        .compactMap({ ApplicationDetailItemModel(title: $0.propertyList.bundleName,
                                                 application: $0) })
      titleLabel.stringValue = "Multi selection (\(models.count))"
      containerViewController.detailViewController.collectionView.isHidden = false
      containerViewController.infoViewController.view.isHidden = true
      containerViewController.computersViewController.reload(with: [])
      containerViewController.detailViewController.reload(with: models)
      containerViewController.keyboardShortcutViewController.reload(with: [])
      containerViewController.actionsViewController.view.isHidden = true
      containerViewController.keyboardShortcutActionsViewController.view.isHidden = true
    case .single(let application):
      segmentedControl.isHidden = false
      titleLabel.isHidden = true
      containerViewController.detailViewController.reload(with: [])
      containerViewController.infoViewController.render(application,
                                                        iconController: iconController,
                                                        machineController: machineController)
      containerViewController.infoViewController.view.isHidden = false
      containerViewController.detailViewController.collectionView.isHidden = true

      var keyboardShortcuts = keyboardController.keyboardShortcuts(for: application)
      if keyboardShortcuts.isEmpty {
        if let keyboardContents = application.preferences.keyEquivalents {
          for (key, value) in keyboardContents {
            keyboardShortcuts.append(ApplicationKeyboardBindingModel(menuTitle: key, keyboardShortcut: value))
          }
        }
        keyboardShortcuts.append(ApplicationKeyboardBindingModel(placeholder: true))
      }

      switch UserDefaults.standard.detailTab {
      case .general:
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
        containerViewController.actionsViewController.render(application: application,
                                                             backupController: backupController,
                                                             syncController: syncController,
                                                             machineController: machineController)
        containerViewController.actionsViewController.view.isHidden = false
        containerViewController.computersViewController.collectionView.isHidden = false
        containerViewController.keyboardShortcutViewController.collectionView.isHidden = true
        containerViewController.keyboardShortcutActionsViewController.view.isHidden = true
      case .customize:
        containerViewController.actionsViewController.view.isHidden = true
        containerViewController.computersViewController.collectionView.isHidden = true
        containerViewController.keyboardShortcutViewController.collectionView.isHidden = false
        containerViewController.keyboardShortcutViewController.application = application
        containerViewController.keyboardShortcutActionsViewController.delegate = self
        NSAnimationContext.current.duration = 0.0
        containerViewController.performBatchUpdates({ _ in
          containerViewController.keyboardShortcutActionsViewController.view.isHidden = false
          containerViewController.keyboardShortcutViewController.reload(with: [])
          containerViewController.keyboardShortcutViewController.reload(with: keyboardShortcuts)
        }, completion: nil)
      }
    }

    NSLayoutConstraint.deactivate(layoutConstraints)
    layoutConstraints = []

    titlebarView.subviews.forEach { $0.removeFromSuperview() }

    titleLabel.alignment = .center
    titlebarView.addSubview(titleLabel)

    segmentedControl.segmentStyle = .texturedRounded
    segmentedControl.setSelected(true, with: UserDefaults.standard.detailTab)
    titlebarView.addSubview(segmentedControl)

    layoutConstraints.append(contentsOf: [
      segmentedControl.centerXAnchor.constraint(equalTo: titlebarView.centerXAnchor),
      segmentedControl.centerYAnchor.constraint(equalTo: titlebarView.centerYAnchor),
      titleLabel.leadingAnchor.constraint(equalTo: titlebarView.leadingAnchor, constant: 10),
      titleLabel.trailingAnchor.constraint(equalTo: titlebarView.trailingAnchor, constant: -10),
      titleLabel.centerYAnchor.constraint(equalTo: titlebarView.centerYAnchor)
      ])

    containerViewController.actionsViewController.delegate = self

    NSLayoutConstraint.constrain(layoutConstraints)
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

  @objc func changeTab(_ segmentedControl: NSSegmentedControl) {
    guard let label = segmentedControl.label(forSegment: segmentedControl.selectedSegment),
      let tab = Tab(rawValue: label) else { return }
    UserDefaults.standard.detailTab = tab
    guard let application = application else { return }
    render(.single(application))
  }

  // MARK: - ApplicationDetailInfoViewControllerDelegate

  func applicationActionsViewController(_ controller: ApplicationActionsViewController,
                                        didTapBackup backupButton: NSButton,
                                        on application: Application) {
    guard let syncaliciousUrl = UserDefaults.standard.syncaliciousUrl else { return }
    try? backupController.runBackup(for: [application], to: syncaliciousUrl)
    render(.single(application))
    refreshApplicationList()
  }

  func applicationActionsViewController(_ controller: ApplicationActionsViewController,
                                        didTapSync syncButton: NSButton,
                                        on application: Application) {
    try? syncController.enableSync(for: application, on: machineController.machine)
    render(.single(application))
    refreshApplicationList()
  }

  func applicationActionsViewController(_ controller: ApplicationActionsViewController,
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

  // MARK: - ApplicationKeyboardActionsViewControllerDelegate

  func applicationKeyboardActionsViewController(_ controller: ApplicationKeyboardActionsViewController,
                                                didClickSaveButton button: NSButton) {

  }

  func applicationKeyboardActionsViewController(_ controller: ApplicationKeyboardActionsViewController,
                                                didClickDiscardButton button: NSButton) {
    guard let application = application else { return }
    keyboardController.discardKeyboardShortcuts(for: application)
    render(.single(application))
  }
}
