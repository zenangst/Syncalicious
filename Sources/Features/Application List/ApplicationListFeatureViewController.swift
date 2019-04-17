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
  var sort: ApplicationListSortViewController.SortKind = .name
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

  func render(applications: [Application]) {
    var models = applications

    switch sort {
    case .name:
      models = models.sorted(by: { $0.propertyList.bundleName.lowercased() < $1.propertyList.bundleName.lowercased() })
    case .synced:
      models = models
        .sorted(by: { $0.propertyList.bundleName.lowercased() > $1.propertyList.bundleName.lowercased() })
        .sorted(by: { lhs, rhs in syncController.applicationIsSynced(lhs, on: machineController.machine)
      })
    }

    self.applications = models

    let collectionView = containerViewController.listViewController.collectionView
    var indexPaths = collectionView.selectionIndexPaths

    containerViewController.listViewController.reload(with: models.compactMap(createViewModel))

    if indexPaths.isEmpty {
      indexPaths = [IndexPath.init(item: 0, section: 0)]
    }

    collectionView.selectItems(at: indexPaths, scrollPosition: .centeredHorizontally)
    collectionView.delegate?.collectionView?(collectionView, didSelectItemsAt: indexPaths)
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
                                    application: application,
                                    bundleIdentifier: application.propertyList.bundleIdentifier,
                                    path: application.url)
  }

  // MARK: - ApplicationListSortViewControllerDelegate

  func applicationListSortViewController(_ controller: ApplicationListSortViewController,

                                         didChangeSort sort: ApplicationListSortViewController.SortKind) {
    self.sort = sort
    let collectionView = containerViewController.listViewController.collectionView
    collectionView.deselectItems(at: collectionView.selectionIndexPaths)
    render(applications: applications)
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

    guard !applications.isEmpty else { return }

    let collectionView = containerViewController.listViewController.collectionView
    collectionView.selectItems(at: [IndexPath.init(item: 0, section: 0)], scrollPosition: [])
    collectionView.delegate?.collectionView?(collectionView, didSelectItemsAt: [IndexPath.init(item: 0, section: 0)])
  }
}
