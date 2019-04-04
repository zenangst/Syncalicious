// Generated using Sourcery 0.16.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Cocoa

class ApplicationItemViewController: NSViewController, Component {
  private let layout: NSCollectionViewFlowLayout
  private let dataSource: ApplicationItemDataSource
  let collectionView: NSCollectionView

  init(title: String? = nil,
  layout: NSCollectionViewFlowLayout,
  iconStore: IconStore,
  collectionView: NSCollectionView? = nil) {
    self.layout = layout
    self.dataSource = ApplicationItemDataSource(title: title, iconStore: iconStore)
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
    let scrollView = NSScrollView()
    self.view = scrollView
    scrollView.documentView = collectionView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.dataSource = dataSource
    let itemIdentifier = NSUserInterfaceItemIdentifier.init("ApplicationItem")
    collectionView.register(ApplicationItem.self, forItemWithIdentifier: itemIdentifier)

    if title != nil {
      layout.headerReferenceSize.height = 60
    }
  }

  // MARK: - Public API

  func indexPath(for item: NSCollectionViewItem) -> IndexPath? {
    return collectionView.indexPath(for: item)
  }

  func model(at indexPath: IndexPath) -> ApplicationItemModel {
    return dataSource.model(at: indexPath)
  }

  func reload(with models: [ApplicationItemModel], completion: (() -> Void)? = nil) {
    dataSource.reload(collectionView, with: models, then: completion)
  }
}

class ApplicationItemDataSource: NSObject, NSCollectionViewDataSource {

  private var title: String?
  private var models = [ApplicationItemModel]()
  private let iconStore: IconStore

  init(title: String? = nil,
  models: [ApplicationItemModel] = [],
  iconStore: IconStore) {
    self.title = title
    self.models = models
    self.iconStore = iconStore
    super.init()
  }

  // MARK: - Public API

  func model(at indexPath: IndexPath) -> ApplicationItemModel {
    return models[indexPath.item]
  }

  func reload(_ collectionView: NSCollectionView,
  with models: [ApplicationItemModel],
  then handler: (() -> Void)? = nil) {
    self.models = models
    collectionView.reloadData()
    handler?()
  }

  // MARK: - NSCollectionViewDataSource

  func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
    return models.count
  }

  func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
    let identifier = NSUserInterfaceItemIdentifier.init("ApplicationItem")
    let item = collectionView.makeItem(withIdentifier: identifier, for: indexPath)
    let model = self.model(at: indexPath)

    if let view = item as? ApplicationItem {
      iconStore.loadIcon(at: model.path, for: model.bundleIdentifier) { image in view.iconView.image = image }
      view.titleLabel.stringValue = model.title
      view.subtitleLabel.stringValue = model.subtitle
    }

    return item
  }
}

struct ApplicationItemModel: Hashable {
  let title: String
  let subtitle: String
  let bundleIdentifier: String
  let path: URL
}

