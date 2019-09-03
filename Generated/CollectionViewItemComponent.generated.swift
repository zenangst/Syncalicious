// Generated using Sourcery 0.16.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Cocoa
import Differific

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
  }

  // MARK: - Public API

  func indexPath(for item: NSCollectionViewItem) -> IndexPath? {
    return collectionView.indexPath(for: item)
  }

  func model(at indexPath: IndexPath) -> ApplicationDetailItemModel {
    return dataSource.model(at: indexPath)
  }

  func reload(with models: [ApplicationDetailItemModel], completion: (() -> Void)? = nil) {
    layout.headerReferenceSize.height = title != nil && !models.isEmpty ? 40 : 0
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
    collectionView.animator().reload(with: changes,
                                     animations: true,
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
  }

  // MARK: - Public API

  func indexPath(for item: NSCollectionViewItem) -> IndexPath? {
    return collectionView.indexPath(for: item)
  }

  func model(at indexPath: IndexPath) -> ApplicationListItemModel {
    return dataSource.model(at: indexPath)
  }

  func reload(with models: [ApplicationListItemModel], completion: (() -> Void)? = nil) {
    layout.headerReferenceSize.height = title != nil && !models.isEmpty ? 40 : 0
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
    collectionView.animator().reload(with: changes,
                                     animations: true,
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

class ComputerDetailItemViewController: NSViewController, Component {
  private let layout: NSCollectionViewFlowLayout
  private let dataSource: ComputerDetailItemDataSource
  lazy var scrollView = NSScrollView()
  let collectionView: NSCollectionView

  init(title: String? = nil,
       layout: NSCollectionViewFlowLayout,
       iconController: IconController,
       collectionView: NSCollectionView? = nil) {
    self.layout = layout
    self.dataSource = ComputerDetailItemDataSource(title: title, iconController: iconController)
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
    let headerIdentifier = NSUserInterfaceItemIdentifier.init("ComputerDetailItemHeader")
    collectionView.register(CollectionViewHeader.self,
                            forSupplementaryViewOfKind: NSCollectionView.elementKindSectionHeader,
                            withIdentifier: headerIdentifier)
    let itemIdentifier = NSUserInterfaceItemIdentifier.init("ComputerDetailItem")
    collectionView.register(ComputerDetailItem.self, forItemWithIdentifier: itemIdentifier)
  }

  // MARK: - Public API

  func indexPath(for item: NSCollectionViewItem) -> IndexPath? {
    return collectionView.indexPath(for: item)
  }

  func model(at indexPath: IndexPath) -> ComputerDetailItemModel {
    return dataSource.model(at: indexPath)
  }

  func reload(with models: [ComputerDetailItemModel], completion: (() -> Void)? = nil) {
    layout.headerReferenceSize.height = title != nil && !models.isEmpty ? 40 : 0
    dataSource.reload(collectionView, with: models, then: completion)
  }
}

class ComputerDetailItemDataSource: NSObject, NSCollectionViewDataSource {

  private var title: String?
  private var models = [ComputerDetailItemModel]()
  private(set) var iconController: IconController

  init(title: String? = nil,
       models: [ComputerDetailItemModel] = [],
       iconController: IconController) {
    self.title = title
    self.models = models
    self.iconController = iconController
    super.init()
  }

  // MARK: - Public API

  func model(at indexPath: IndexPath) -> ComputerDetailItemModel {
    return models[indexPath.item]
  }

  func reload(_ collectionView: NSCollectionView,
              with models: [ComputerDetailItemModel],
              then handler: (() -> Void)? = nil) {
    let old = self.models
    let new = models
    let changes = DiffManager().diff(old, new)
    collectionView.animator().reload(with: changes,
                                     animations: true,
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
    let identifier = NSUserInterfaceItemIdentifier.init("ComputerDetailItemHeader")
    let item = collectionView.makeSupplementaryView(ofKind: NSCollectionView.elementKindSectionHeader,
                                                    withIdentifier: identifier, for: indexPath)

    if let title = title, let header = item as? CollectionViewHeader {
      header.setText(title)
    }

    return item
  }

  func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
    let identifier = NSUserInterfaceItemIdentifier.init("ComputerDetailItem")
    let item = collectionView.makeItem(withIdentifier: identifier, for: indexPath)
    let model = self.model(at: indexPath)

    if let view = item as? ComputerDetailItem {
      iconController.loadIcon(at: model.image, identifier: model.machine.name) { image in view.iconView.image = image }
      view.titleLabel.stringValue = model.title
      view.subtitleLabel.stringValue = model.subtitle
      view.backupIconView.isHidden = model.backupDate == nil
      view.syncIconView.isHidden = !model.synced
    }

    return item
  }
}

struct ComputerDetailItemModel: Hashable {
  let title: String
  let subtitle: String
  let backupDate: Date?
  let image: URL
  let machine: Machine
  let synced: Bool
}

