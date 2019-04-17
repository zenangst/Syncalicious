// Generated using Sourcery 0.16.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Cocoa
import Differific

class ApplicationListItemViewController: NSViewController, Component {
  private let layout: NSCollectionViewFlowLayout
  private let dataSource: ApplicationListItemDataSource
  lazy var scrollView = NSScrollView()
  let collectionView: NSCollectionView

  init(title: String? = nil,
  layout: NSCollectionViewFlowLayout,
  iconStore: IconStore,
  collectionView: NSCollectionView? = nil) {
    self.layout = layout
    self.dataSource = ApplicationListItemDataSource(title: title, iconStore: iconStore)
    if let collectionView = collectionView {
      self.collectionView = collectionView
    } else {
      self.collectionView = NSCollectionView()
    }
    self.collectionView.collectionViewLayout = layout
    super.init(nibName: nil, bundle: nil)
    self.title = title
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View lifecycle

  override func loadView() {
    self.view = scrollView
    scrollView.documentView = collectionView
    collectionView.isSelectable = true
    collectionView.allowsMultipleSelection = false
    collectionView.allowsEmptySelection = false
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.dataSource = dataSource
    let itemIdentifier = NSUserInterfaceItemIdentifier.init("ApplicationListItem")
    collectionView.register(ApplicationListItem.self, forItemWithIdentifier: itemIdentifier)

    if title != nil {
      layout.headerReferenceSize.height = 60
    }
  }

  // MARK: - Public API

  func indexPath(for item: NSCollectionViewItem) -> IndexPath? {
    return collectionView.indexPath(for: item)
  }

  func model(at indexPath: IndexPath) -> ApplicationListItemModel {
    return dataSource.model(at: indexPath)
  }

  func reload(with models: [ApplicationListItemModel], completion: (() -> Void)? = nil) {
    dataSource.reload(collectionView, with: models, then: completion)
  }
}

class ApplicationListItemDataSource: NSObject, NSCollectionViewDataSource {

  private var title: String?
  private var models = [ApplicationListItemModel]()
  private let iconStore: IconStore

  init(title: String? = nil,
  models: [ApplicationListItemModel] = [],
  iconStore: IconStore) {
    self.title = title
    self.models = models
    self.iconStore = iconStore
    super.init()
  }

  // MARK: - Public API

  func model(at indexPath: IndexPath) -> ApplicationListItemModel {
    return models[indexPath.item]
  }

  func reload(_ collectionView: NSCollectionView,
  with models: [ApplicationListItemModel],
  then handler: (() -> Void)? = nil) {
    let changes = DiffManager().diff(self.models, models)
    collectionView.reload(with: changes, updateDataSource: { self.models = models }, completion: handler)
  }

  // MARK: - NSCollectionViewDataSource

  func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
    return models.count
  }

  func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
    let identifier = NSUserInterfaceItemIdentifier.init("ApplicationListItem")
    let item = collectionView.makeItem(withIdentifier: identifier, for: indexPath)
    let model = self.model(at: indexPath)

    if let view = item as? ApplicationListItem {
      iconStore.loadIcon(at: model.path, for: model.bundleIdentifier) { image in view.iconView.image = image }
      view.titleLabel.stringValue = model.title
      view.subtitleLabel.stringValue = model.subtitle
      view.syncView.isHidden = !model.synced
    }

    return item
  }
}

struct ApplicationListItemModel: Hashable {
  let title: String
  let subtitle: String
  let synced: Bool
  let application: Application
  let bundleIdentifier: String
  let path: URL
}

