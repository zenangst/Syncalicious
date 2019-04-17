import Cocoa

class ApplicationListFeatureViewController: NSViewController, ApplicationListSearchViewControllerDelegate {
  let containerViewController: ApplicationListContainerViewController
  var applications = [Application]()

  init(containerViewController: ApplicationListContainerViewController) {
    self.containerViewController = containerViewController
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
    containerViewController.listViewController.collectionView.backgroundColors = [NSColor.clear]
    containerViewController.searchViewController.delegate = self
  }

  func render(applications: [Application]) {
    let models = applications
      .sorted(by: { $0.propertyList.bundleName.lowercased() < $1.propertyList.bundleName.lowercased() })
    self.applications = models

    containerViewController.listViewController.reload(with: models.compactMap(createViewModel))

    let collectionView = containerViewController.listViewController.collectionView
    collectionView.selectItems(at: [IndexPath.init(item: 0, section: 0)], scrollPosition: .centeredHorizontally)
    collectionView.delegate?.collectionView?(collectionView, didSelectItemsAt: [IndexPath.init(item: 0, section: 0)])
  }

  // MARK: - Private methods

  private func createViewModel(from application: Application) -> ApplicationListItemModel {
    var subtitle = "\(application.propertyList.versionString)"
    if !application.propertyList.buildVersion.isEmpty &&
      application.propertyList.versionString != application.propertyList.buildVersion {
      subtitle.append(" (\(application.propertyList.buildVersion))")
    }

    return ApplicationListItemModel(data: [
      "title": application.propertyList.bundleName,
      "subtitle": subtitle,
      "bundleIdentifier": application.propertyList.bundleIdentifier,
      "path": application.url,
      "enabled": true,
      "model": application
      ])
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
