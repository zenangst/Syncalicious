// Generated using Sourcery 0.16.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Cocoa
import Differific

class ApplicationComputerDetailItemViewController: NSViewController, Component {
  private let layout: NSCollectionViewFlowLayout
  private let dataSource: ApplicationComputerDetailItemDataSource
  lazy var scrollView = NSScrollView()
  let collectionView: NSCollectionView

  init(title: String? = nil,
       layout: NSCollectionViewFlowLayout,
       iconController: IconController,
       collectionView: NSCollectionView? = nil) {
    self.layout = layout
    self.dataSource = ApplicationComputerDetailItemDataSource(title: title, iconController: iconController)
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
    collectionView.allowsMultipleSelection = true
    collectionView.allowsEmptySelection = false
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.dataSource = dataSource
    let headerIdentifier = NSUserInterfaceItemIdentifier.init("ApplicationComputerDetailItemHeader")
    collectionView.register(CollectionViewHeader.self,
                            forSupplementaryViewOfKind: NSCollectionView.elementKindSectionHeader,
                            withIdentifier: headerIdentifier)
    let itemIdentifier = NSUserInterfaceItemIdentifier.init("ApplicationComputerDetailItem")
    collectionView.register(ApplicationComputerDetailItem.self, forItemWithIdentifier: itemIdentifier)

    if title != nil {
      layout.headerReferenceSize.height = 40
    }
  }

  // MARK: - Public API

  func indexPath(for item: NSCollectionViewItem) -> IndexPath? {
    return collectionView.indexPath(for: item)
  }

  func model(at indexPath: IndexPath) -> ApplicationComputerDetailItemModel {
    return dataSource.model(at: indexPath)
  }

  func reload(with models: [ApplicationComputerDetailItemModel], completion: (() -> Void)? = nil) {
    dataSource.reload(collectionView, with: models, then: completion)
  }
}

class ApplicationComputerDetailItemDataSource: NSObject, NSCollectionViewDataSource {

  private var title: String?
  private var models = [ApplicationComputerDetailItemModel]()
  private(set) var iconController: IconController

  init(title: String? = nil,
       models: [ApplicationComputerDetailItemModel] = [],
       iconController: IconController) {
    self.title = title
    self.models = models
    self.iconController = iconController
    super.init()
  }

  // MARK: - Public API

  func model(at indexPath: IndexPath) -> ApplicationComputerDetailItemModel {
    return models[indexPath.item]
  }

  func reload(_ collectionView: NSCollectionView,
              with models: [ApplicationComputerDetailItemModel],
              then handler: (() -> Void)? = nil) {
    let old = self.models
    let new = models
    let changes = DiffManager().diff(old, new)
    collectionView.reload(with: changes,
                          animations: false,
                          updateDataSource: { [weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.models = new
                          }, completion: handler)
  }

  // MARK: - NSCollectionViewDataSource

  func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
    return models.count
  }

  func collectionView(_ collectionView: NSCollectionView,
                      viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind,
                      at indexPath: IndexPath) -> NSView {
    let identifier = NSUserInterfaceItemIdentifier.init("ApplicationComputerDetailItemHeader")
    let item = collectionView.makeSupplementaryView(ofKind: NSCollectionView.elementKindSectionHeader,
                                                    withIdentifier: identifier, for: indexPath)

    if let title = title, let header = item as? CollectionViewHeader {
      header.setText(title)
    }

    return item
  }

  func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
    let identifier = NSUserInterfaceItemIdentifier.init("ApplicationComputerDetailItem")
    let item = collectionView.makeItem(withIdentifier: identifier, for: indexPath)
    let model = self.model(at: indexPath)

    if let view = item as? ApplicationComputerDetailItem {
      iconController.loadIcon(at: model.image, identifier: model.machine.name) { image in view.iconView.image = image }
      view.titleLabel.stringValue = model.title
      view.subtitleLabel.stringValue = model.subtitle
      view.backupIconView.isHidden = !model.backuped
      view.syncIconView.isHidden = !model.synced
    }

    return item
  }
}

struct ApplicationComputerDetailItemModel: Hashable {
  let title: String
  let subtitle: String
  let backuped: Bool
  let image: URL
  let machine: Machine
  let synced: Bool
}

class ApplicationDetailItemViewController: NSViewController, Component {
  private let layout: NSCollectionViewFlowLayout
  private let dataSource: ApplicationDetailItemDataSource
  lazy var scrollView = NSScrollView()
  let collectionView: NSCollectionView

  init(title: String? = nil,
       layout: NSCollectionViewFlowLayout,
       iconController: IconController,
       collectionView: NSCollectionView? = nil) {
    self.layout = layout
    self.dataSource = ApplicationDetailItemDataSource(title: title, iconController: iconController)
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
    collectionView.allowsMultipleSelection = true
    collectionView.allowsEmptySelection = false
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.dataSource = dataSource
    let headerIdentifier = NSUserInterfaceItemIdentifier.init("ApplicationDetailItemHeader")
    collectionView.register(CollectionViewHeader.self,
                            forSupplementaryViewOfKind: NSCollectionView.elementKindSectionHeader,
                            withIdentifier: headerIdentifier)
    let itemIdentifier = NSUserInterfaceItemIdentifier.init("ApplicationDetailItem")
    collectionView.register(ApplicationDetailItem.self, forItemWithIdentifier: itemIdentifier)

    if title != nil {
      layout.headerReferenceSize.height = 40
    }
  }

  // MARK: - Public API

  func indexPath(for item: NSCollectionViewItem) -> IndexPath? {
    return collectionView.indexPath(for: item)
  }

  func model(at indexPath: IndexPath) -> ApplicationDetailItemModel {
    return dataSource.model(at: indexPath)
  }

  func reload(with models: [ApplicationDetailItemModel], completion: (() -> Void)? = nil) {
    dataSource.reload(collectionView, with: models, then: completion)
  }
}

class ApplicationDetailItemDataSource: NSObject, NSCollectionViewDataSource {

  private var title: String?
  private var models = [ApplicationDetailItemModel]()
  private(set) var iconController: IconController

  init(title: String? = nil,
       models: [ApplicationDetailItemModel] = [],
       iconController: IconController) {
    self.title = title
    self.models = models
    self.iconController = iconController
    super.init()
  }

  // MARK: - Public API

  func model(at indexPath: IndexPath) -> ApplicationDetailItemModel {
    return models[indexPath.item]
  }

  func reload(_ collectionView: NSCollectionView,
              with models: [ApplicationDetailItemModel],
              then handler: (() -> Void)? = nil) {
    let old = self.models
    let new = models
    let changes = DiffManager().diff(old, new)
    collectionView.reload(with: changes,
                          animations: false,
                          updateDataSource: { [weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.models = new
                          }, completion: handler)
  }

  // MARK: - NSCollectionViewDataSource

  func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
    return models.count
  }

  func collectionView(_ collectionView: NSCollectionView,
                      viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind,
                      at indexPath: IndexPath) -> NSView {
    let identifier = NSUserInterfaceItemIdentifier.init("ApplicationDetailItemHeader")
    let item = collectionView.makeSupplementaryView(ofKind: NSCollectionView.elementKindSectionHeader,
                                                    withIdentifier: identifier, for: indexPath)

    if let title = title, let header = item as? CollectionViewHeader {
      header.setText(title)
    }

    return item
  }

  func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
    let identifier = NSUserInterfaceItemIdentifier.init("ApplicationDetailItem")
    let item = collectionView.makeItem(withIdentifier: identifier, for: indexPath)
    let model = self.model(at: indexPath)

    if let view = item as? ApplicationDetailItem {
      iconController.loadIcon(at: model.application.url, identifier: model.application.propertyList.bundleIdentifier) { image in view.iconView.image = image }
      view.titleLabel.stringValue = model.title
    }

    return item
  }
}

struct ApplicationDetailItemModel: Hashable {
  let title: String
  let application: Application
}

class ApplicationListItemViewController: NSViewController, Component {
  private let layout: NSCollectionViewFlowLayout
  private let dataSource: ApplicationListItemDataSource
  lazy var scrollView = NSScrollView()
  let collectionView: NSCollectionView

  init(title: String? = nil,
       layout: NSCollectionViewFlowLayout,
       iconController: IconController,
       collectionView: NSCollectionView? = nil) {
    self.layout = layout
    self.dataSource = ApplicationListItemDataSource(title: title, iconController: iconController)
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
    collectionView.allowsMultipleSelection = true
    collectionView.allowsEmptySelection = false
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.dataSource = dataSource
    let headerIdentifier = NSUserInterfaceItemIdentifier.init("ApplicationListItemHeader")
    collectionView.register(CollectionViewHeader.self,
                            forSupplementaryViewOfKind: NSCollectionView.elementKindSectionHeader,
                            withIdentifier: headerIdentifier)
    let itemIdentifier = NSUserInterfaceItemIdentifier.init("ApplicationListItem")
    collectionView.register(ApplicationListItem.self, forItemWithIdentifier: itemIdentifier)

    if title != nil {
      layout.headerReferenceSize.height = 40
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
  private(set) var iconController: IconController

  init(title: String? = nil,
       models: [ApplicationListItemModel] = [],
       iconController: IconController) {
    self.title = title
    self.models = models
    self.iconController = iconController
    super.init()
  }

  // MARK: - Public API

  func model(at indexPath: IndexPath) -> ApplicationListItemModel {
    return models[indexPath.item]
  }

  func reload(_ collectionView: NSCollectionView,
              with models: [ApplicationListItemModel],
              then handler: (() -> Void)? = nil) {
    let old = self.models
    let new = models
    let changes = DiffManager().diff(old, new)
    collectionView.reload(with: changes,
                          animations: false,
                          updateDataSource: { [weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.models = new
                          }, completion: handler)
  }

  // MARK: - NSCollectionViewDataSource

  func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
    return models.count
  }

  func collectionView(_ collectionView: NSCollectionView,
                      viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind,
                      at indexPath: IndexPath) -> NSView {
    let identifier = NSUserInterfaceItemIdentifier.init("ApplicationListItemHeader")
    let item = collectionView.makeSupplementaryView(ofKind: NSCollectionView.elementKindSectionHeader,
                                                    withIdentifier: identifier, for: indexPath)

    if let title = title, let header = item as? CollectionViewHeader {
      header.setText(title)
    }

    return item
  }

  func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
    let identifier = NSUserInterfaceItemIdentifier.init("ApplicationListItem")
    let item = collectionView.makeItem(withIdentifier: identifier, for: indexPath)
    let model = self.model(at: indexPath)

    if let view = item as? ApplicationListItem {
      iconController.loadIcon(at: model.application.url, identifier: model.application.propertyList.bundleIdentifier) { view.iconView.image = $0 }
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
}

