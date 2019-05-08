import Cocoa
import Differific

class ApplicationKeyboardBindingDataSource: NSObject, NSCollectionViewDataSource {
  private var title: String?
  private var models = [ApplicationKeyboardBindingModel]()
  private(set) var iconController: IconController
  lazy var keyHolderController = KeyHolderController()

  init(title: String? = nil,
       models: [ApplicationKeyboardBindingModel] = [],
       iconController: IconController) {
    self.title = title
    self.models = models
    self.iconController = iconController
    super.init()
  }

  // MARK: - Public API

  func model(at indexPath: IndexPath) -> ApplicationKeyboardBindingModel {
    return models[indexPath.item]
  }

  func reload(_ collectionView: NSCollectionView,
              with models: [ApplicationKeyboardBindingModel],
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
    let identifier = NSUserInterfaceItemIdentifier.init("ApplicationKeyboardBindingItemHeader")
    let item = collectionView.makeSupplementaryView(ofKind: NSCollectionView.elementKindSectionHeader,
                                                    withIdentifier: identifier, for: indexPath)

    if let title = title, let header = item as? CollectionViewHeader {
      header.setText(title)
    }

    return item
  }

  func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
    let identifier = NSUserInterfaceItemIdentifier.init("ApplicationKeyboardBindingItem")
    let item = collectionView.makeItem(withIdentifier: identifier, for: indexPath)
    let model = self.model(at: indexPath)

    if let view = item as? ApplicationKeyboardBindingItem {
      view.menuTitleLabel.stringValue = !model.modified ? model.menuTitle : ""

      if let keyCombo = keyHolderController.keyComboFromString(model.keyboardShortcut) {
        view.recorderView.keyCombo = keyCombo
      } else {
        view.recorderView.clear()
      }
    }

    return item
  }
}
