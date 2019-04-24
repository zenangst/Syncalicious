import Cocoa

class ApplicationListFeatureViewController: NSViewController,
  SplitViewContainedController,
  ApplicationListSearchViewControllerDelegate,
  ApplicationListSortViewControllerDelegate {

  let syncController: SyncController
  let machineController: MachineController
  let containerViewController: ApplicationListContainerViewController
  lazy var titlebarView = NSView()
  lazy var titleLabel = SmallLabel()
  var applications = [Application]()
  var sort: ApplicationListSortViewController.SortKind = UserDefaults.standard.listSort ?? .name
  private var layoutConstraints = [NSLayoutConstraint]()

  init(containerViewController: ApplicationListContainerViewController,
       machineController: MachineController,
       syncController: SyncController) {
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
    title = Bundle.main.infoDictionary?["CFBundleName"] as? String

    NSLayoutConstraint.deactivate(layoutConstraints)
    layoutConstraints = []

    titlebarView.subviews.forEach { $0.removeFromSuperview() }
    titleLabel.alignment = .center
    titleLabel.stringValue = title!
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
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

  func render(applications: [Application], sort: ApplicationListSortViewController.SortKind? = nil) {
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
      applicationDetailSearchViewController(searchViewController, didStartSearch: searchField)
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

  // MARK: - ApplicationListSortViewControllerDelegate

  func applicationListSortViewController(_ controller: ApplicationListSortViewController,
                                         didChangeSort sort: ApplicationListSortViewController.SortKind) {
    render(applications: applications, sort: sort)
  }

  // MARK: - ApplicationSearchViewControllerDelegate

  func applicationDetailSearchViewController(_ controller: ApplicationListSearchViewController,
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

  func applicationDetailSearchViewController(_ controller: ApplicationListSearchViewController,
                                             didEndSearch searchField: NSSearchField) {
    containerViewController.listViewController.reload(with: applications.compactMap(createViewModel))
    let collectionView = containerViewController.listViewController.collectionView
    collectionView.deselectItems(at: collectionView.selectionIndexPaths)

    guard !applications.isEmpty else { return }

    collectionView.selectItems(at: [IndexPath.init(item: 0, section: 0)], scrollPosition: [])
    collectionView.delegate?.collectionView?(collectionView, didSelectItemsAt: [IndexPath.init(item: 0, section: 0)])
  }
}
