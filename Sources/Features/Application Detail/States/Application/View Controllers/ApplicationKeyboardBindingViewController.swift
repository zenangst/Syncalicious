import Cocoa
import Differific

class ApplicationKeyboardBindingViewController: NSViewController, Component {
  private let layout: NSCollectionViewFlowLayout
  private let dataSource: ApplicationKeyboardBindingDataSource
  lazy var scrollView = NSScrollView()
  let collectionView: NSCollectionView

  init(title: String? = nil,
       layout: NSCollectionViewFlowLayout,
       iconController: IconController,
       collectionView: NSCollectionView? = nil) {
    self.layout = layout
    self.dataSource = ApplicationKeyboardBindingDataSource(title: title, iconController: iconController)
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
    let headerIdentifier = NSUserInterfaceItemIdentifier.init("ApplicationKeyboardBindingItemHeader")
    collectionView.register(CollectionViewHeader.self,
                            forSupplementaryViewOfKind: NSCollectionView.elementKindSectionHeader,
                            withIdentifier: headerIdentifier)
    let itemIdentifier = NSUserInterfaceItemIdentifier.init("ApplicationKeyboardBindingItem")
    collectionView.register(ApplicationKeyboardBindingItem.self, forItemWithIdentifier: itemIdentifier)
  }

  // MARK: - Public API

  func indexPath(for item: NSCollectionViewItem) -> IndexPath? {
    return collectionView.indexPath(for: item)
  }

  func model(at indexPath: IndexPath) -> ApplicationKeyboardBindingModel {
    return dataSource.model(at: indexPath)
  }

  func reload(with models: [ApplicationKeyboardBindingModel], completion: (() -> Void)? = nil) {
    layout.headerReferenceSize.height = title != nil && !models.isEmpty ? 40 : 0
    dataSource.reload(collectionView, with: models, then: completion)
  }
}
