import Cocoa

protocol ListFeatureViewControllerDelegate: class {
  func listFeatureViewController(_ controller: ListFeatureViewController,
                                 didSelectApplications applications: [Application])
}

class ListFeatureViewController: NSViewController,
  SplitViewContainedController,
  ListSearchViewControllerDelegate,
  ListSortViewControllerDelegate,
  NSCollectionViewDelegate {

  weak var delegate: ListFeatureViewControllerDelegate?

  let titlebarView: NSView
  lazy var titleLabel = SmallLabel()

  let iconController: IconController
  let syncController: SyncController
  let machineController: MachineController
  let containerViewController: ListContainerViewController
  let titlebarVisualEffectView = NSVisualEffectView()

  var applications = [Application]()
  var sort: ListSortViewController.SortKind = UserDefaults.standard.listSort ?? .name

  private var layoutConstraints = [NSLayoutConstraint]()

  init(containerViewController: ListContainerViewController,
       iconController: IconController,
       machineController: MachineController,
       syncController: SyncController) {
    self.containerViewController = containerViewController
    self.iconController = iconController
    self.machineController = machineController
    self.syncController = syncController
    self.titlebarVisualEffectView.blendingMode = .withinWindow
    self.titlebarVisualEffectView.state = .followsWindowActiveState
    self.titlebarVisualEffectView.material = .titlebar
    self.titlebarView = titlebarVisualEffectView
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    view = containerViewController.view

    NotificationCenter.default.addObserver(self, selector: #selector(mainWindowDidResignKey),
                                           name: MainWindowNotification.didResign.notificationName,
                                           object: nil)

    NotificationCenter.default.addObserver(self, selector: #selector(mainWindowDidBecomeKey),
                                           name: MainWindowNotification.becomeKey.notificationName,
                                           object: nil)
  }

  // MARK: - View life cycle

  override func viewDidLoad() {
    super.viewDidLoad()
//    title =

    NSLayoutConstraint.deactivate(layoutConstraints)
    layoutConstraints = []

    titleLabel.alignment = .center
    titleLabel.translatesAutoresizingMaskIntoConstraints = false

    titlebarView.subviews.forEach { $0.removeFromSuperview() }
    titlebarView.wantsLayer = true
    titlebarView.addSubview(titleLabel)

    layoutConstraints.append(contentsOf: [
      titleLabel.leadingAnchor.constraint(equalTo: titlebarView.leadingAnchor, constant: 10),
      titleLabel.trailingAnchor.constraint(equalTo: titlebarView.trailingAnchor, constant: -10),
      titleLabel.centerYAnchor.constraint(equalTo: titlebarView.centerYAnchor)
      ])

    NSLayoutConstraint.activate(layoutConstraints)

    containerViewController.listViewController.collectionView.backgroundColors = [NSColor.clear]
    containerViewController.searchViewController.delegate = self
    containerViewController.sortViewController.delegate = self
  }

  override func viewWillLayout() {
    super.viewWillLayout()
    if view.window?.effectiveAppearance.name == .aqua {
      view.layer?.backgroundColor = NSColor.white.cgColor
      containerViewController.visualEffect.material = .underWindowBackground
    } else {
      view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
    }
  }

  @objc func mainWindowDidResignKey() { containerViewController.listViewController.collectionView.alphaValue = 0.8 }
  @objc func mainWindowDidBecomeKey() { containerViewController.listViewController.collectionView.alphaValue = 1.0 }

  func render(applications: [Application], sort: ListSortViewController.SortKind? = nil) {
    let sort = sort ?? self.sort
    let collectionView = containerViewController.listViewController.collectionView
    var selectedApplications = [Application]()
    for indexPath in collectionView.selectionIndexPaths {
      guard indexPath.item < self.applications.count else { return }
      let application = self.applications[indexPath.item]
      selectedApplications.append(application)
    }

    var models = applications

    switch sort {
    case .name:
      models = models.sorted(by: { $0.propertyList.bundleName.lowercased() < $1.propertyList.bundleName.lowercased() })
    case .synced:
      let synced = models.filter({ syncController.applicationIsSynced($0, on: machineController.machine) })
        .sorted(by: { $0.propertyList.bundleName.lowercased() < $1.propertyList.bundleName.lowercased() })
      let unsynced = models.filter({ !(syncController.applicationIsSynced($0, on: machineController.machine)) })
        .sorted(by: { $0.propertyList.bundleName.lowercased() < $1.propertyList.bundleName.lowercased() })

      models = (synced + unsynced)
    }

    var selectedIndexPaths = Set<IndexPath>()
    for (offset, application) in self.applications.enumerated() where selectedApplications.contains(application) {
      selectedIndexPaths.insert(IndexPath(item: offset, section: 0))
    }

    if selectedIndexPaths.isEmpty { selectedIndexPaths.insert(IndexPath(item: 0, section: 0)) }

    let searchViewController = containerViewController.searchViewController
    let searchField = containerViewController.searchViewController.searchField
    if !searchField.stringValue.isEmpty {
      listSearchViewController(searchViewController, didStartSearch: searchField)
    } else {
      containerViewController.listViewController.reload(with: models.compactMap(createViewModel))
    }

    if self.sort == sort {
      var scrollPosition: NSCollectionView.ScrollPosition = []
      if let firstSelectedIndexPath = selectedIndexPaths.first,
        let item = collectionView.item(at: firstSelectedIndexPath),
        let visibleRect = collectionView.enclosingScrollView?.visibleRect {
        let converted = collectionView.convert(item.view.frame, from: collectionView)

        if !converted.intersects(visibleRect) {
          scrollPosition.insert(.nearestHorizontalEdge)
        }
      }
      collectionView.selectItems(at: selectedIndexPaths, scrollPosition: scrollPosition)
    }

    collectionView.delegate?.collectionView?(collectionView, didSelectItemsAt: selectedIndexPaths)

    self.applications = models
    self.sort = sort
  }

  // MARK: - Private methods

  private func createSortedApplications(from indexPaths: [IndexPath]) -> [Application] {
    var applications = [Application]()
    indexPaths.forEach {
      applications.append(
        containerViewController.listViewController.model(at: $0).application)
    }

    applications.sort(by: { $0.propertyList.bundleName.lowercased() < $1.propertyList.bundleName.lowercased() })

    return applications
  }

  private func createViewModel(from application: Application) -> ApplicationListItemModel {
    var subtitle = "\(application.propertyList.versionString)"
    if !application.propertyList.buildVersion.isEmpty &&
      application.propertyList.versionString != application.propertyList.buildVersion {
      subtitle.append(" (\(application.propertyList.buildVersion))")
    }

    let isSynched = syncController.applicationIsSynced(application, on: machineController.machine)

    return ApplicationListItemModel(title: application.propertyList.bundleName,
                                    subtitle: subtitle,
                                    synced: isSynched,
                                    application: application)
  }

  // MARK: - ListSortViewControllerDelegate

  func listSortViewController(_ controller: ListSortViewController,
                              didChangeSort sort: ListSortViewController.SortKind) {
    render(applications: applications, sort: sort)
  }

  // MARK: - ListSearchViewControllerDelegate

  func listSearchViewController(_ controller: ListSearchViewController,
                                didStartSearch searchField: NSSearchField) {
    let query = searchField.stringValue.lowercased()
    let results = applications.filter({
      $0.propertyList.bundleName.lowercased().contains(query) ||
        $0.propertyList.bundleIdentifier.lowercased().contains(query)
    })
    let newModels = results.compactMap(createViewModel)

    containerViewController.listViewController.reload(with: newModels)

    guard !newModels.isEmpty else { return }

    let collectionView = containerViewController.listViewController.collectionView
    collectionView.selectItems(at: [IndexPath.init(item: 0, section: 0)], scrollPosition: [])
    collectionView.delegate?.collectionView?(collectionView, didSelectItemsAt: [IndexPath.init(item: 0, section: 0)])
  }

  func listSearchViewController(_ controller: ListSearchViewController,
                                didEndSearch searchField: NSSearchField) {
    containerViewController.listViewController.reload(with: applications.compactMap(createViewModel))
    let collectionView = containerViewController.listViewController.collectionView
    collectionView.deselectItems(at: collectionView.selectionIndexPaths)

    guard !applications.isEmpty else { return }

    collectionView.selectItems(at: [IndexPath.init(item: 0, section: 0)], scrollPosition: [])
    collectionView.delegate?.collectionView?(collectionView, didSelectItemsAt: [IndexPath.init(item: 0, section: 0)])
  }

  // MARK: - NSCollectionViewDelegate

  func collectionView(_ collectionView: NSCollectionView, willDisplay item: NSCollectionViewItem, forRepresentedObjectAt indexPath: IndexPath) {
    let model = containerViewController.listViewController.model(at: indexPath)
    let view = item as? ApplicationListItem

    guard let wrapperView = containerViewController.listViewController.collectionView.enclosingScrollView,
      let familyScrollView = wrapperView.enclosingScrollView else {
        return
    }

    if familyScrollView.documentVisibleRect.intersects(wrapperView.frame) {
      iconController.loadIcon(at: model.application.url,
                              identifier: model.application.propertyList.bundleIdentifier,
                              then: { view?.iconView.layer?.contents = $0 })
    }
  }

  func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
    let applications = createSortedApplications(from: Array(collectionView.selectionIndexPaths))
    delegate?.listFeatureViewController(self, didSelectApplications: applications)
  }

  func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
    let applications = createSortedApplications(from: Array(collectionView.selectionIndexPaths))
    delegate?.listFeatureViewController(self, didSelectApplications: applications)
  }
}
