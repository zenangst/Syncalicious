import Cocoa
import Differific

class KeyboardBindingDataSource: NSObject, NSCollectionViewDataSource {
  private var title: String?
  private(set) var models = [KeyboardBindingModel]()
  private(set) var originalModels = [KeyboardBindingModel]()
  private(set) var iconController: IconController
  lazy var keyHolderController = KeyHolderController()

  var isModified: Bool {
    return models != originalModels
  }

  init(title: String? = nil,
       models: [KeyboardBindingModel] = [],
       iconController: IconController) {
    self.title = title
    self.models = models
    self.originalModels = models
    self.iconController = iconController
    super.init()
  }

  // MARK: - Public API

  func modify(_ model: KeyboardBindingModel, at indexPath: IndexPath) {
    if indexPath.item < models.count {
      models[indexPath.item] = model
    } else {
      models.append(model)
    }
  }

  func model(at indexPath: IndexPath) -> KeyboardBindingModel {
    return models[indexPath.item]
  }

  func reload(_ collectionView: NSCollectionView,
              withAnimations animations: Bool = false,
              updateOriginals: Bool = true,
              with models: [KeyboardBindingModel],
              then handler: (() -> Void)? = nil) {
    let old = self.models
    let new = models
    let changes = DiffManager().diff(old, new)
    collectionView.reload(with: changes,
                          animations: animations,
                          updateDataSource: { [weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.models = new
                            if updateOriginals { strongSelf.originalModels = new }
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

    if let view = item as? KeyboardBindingItem {
      view.menuTitleLabel.stringValue = !model.placeholder ? model.menuTitle : ""
      view.removeButton.isHidden = model.placeholder
      view.stackView.layer?.backgroundColor = model.placeholder
        ? NSColor(named: "Corn Silk")?.blended(withFraction: 0.5, of: .white)?.cgColor
        : NSColor.white.cgColor

      if models.count == 1 {
        view.roundCorners(corners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner,
          .layerMinXMinYCorner, .layerMaxXMinYCorner])
      } else if indexPath.item == 0 {
        view.roundCorners(corners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
      } else if indexPath.item == models.count - 1 {
        view.roundCorners(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
      } else {
        view.roundCorners(corners: [])
      }

      if let keyCombo = keyHolderController.keyComboFromString(model.keyboardShortcut) {
        view.recorderView.keyCombo = keyCombo
      } else {
        view.recorderView.clear()
      }
    }

    return item
  }
}
