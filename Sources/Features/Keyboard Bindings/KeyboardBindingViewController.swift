import Cocoa
import Differific
import KeyHolder
import Magnet

class KeyboardBindingViewController: NSViewController,
  NSCollectionViewDelegate,
  KeyboardBindingItemDelegate {
  private let layout: NSCollectionViewFlowLayout
  private let dataSource: KeyboardBindingDataSource
  private let keyboardController: KeyboardController
  lazy var scrollView = NSScrollView()
  let collectionView: NSCollectionView
  var application: Application?

  init(title: String? = nil,
       layout: NSCollectionViewFlowLayout,
       iconController: IconController,
       keyboardController: KeyboardController,
       collectionView: NSCollectionView? = nil) {
    self.layout = layout
    self.keyboardController = keyboardController
    self.dataSource = KeyboardBindingDataSource(title: title, iconController: iconController)
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
    collectionView.delegate = self
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.dataSource = dataSource
    let headerIdentifier = NSUserInterfaceItemIdentifier.init("ApplicationKeyboardBindingItemHeader")
    collectionView.register(CollectionViewHeader.self,
                            forSupplementaryViewOfKind: NSCollectionView.elementKindSectionHeader,
                            withIdentifier: headerIdentifier)
    let itemIdentifier = NSUserInterfaceItemIdentifier.init("ApplicationKeyboardBindingItem")
    collectionView.register(KeyboardBindingItem.self, forItemWithIdentifier: itemIdentifier)
  }

  // MARK: - Public API

  func indexPath(for item: NSCollectionViewItem) -> IndexPath? {
    return collectionView.indexPath(for: item)
  }

  func model(at indexPath: IndexPath) -> KeyboardBindingModel {
    return dataSource.model(at: indexPath)
  }

  func reload(with models: [KeyboardBindingModel],
              withAnimations animations: Bool = false,
              completion: (() -> Void)? = nil) {
    layout.headerReferenceSize.height = title != nil && !models.isEmpty ? 40 : 0
    dataSource.reload(collectionView, withAnimations: animations, with: models, then: completion)
  }

  // MARK: - NSCollectionViewDelegate

  func collectionView(_ collectionView: NSCollectionView,
                      willDisplay item: NSCollectionViewItem,
                      forRepresentedObjectAt indexPath: IndexPath) {
    (item as? KeyboardBindingItem)?.delegate = self
  }

  // MARK: - KeyboardBindingItemDelegate

  func keyboardBindingItem(_ item: KeyboardBindingItem, menuTitleLabelDidChange textField: NSTextField) {
    guard let application = application else { return }

    let dataSourceCount = dataSource.models.count
    guard let indexPath = collectionView.indexPath(for: item),
      indexPath.item < dataSourceCount else { return }

    let collectionView = self.collectionView
    let isLastItem = indexPath.item == dataSourceCount - 1
    let model = dataSource.model(at: indexPath)
    let newModel = model.copy {
      let placeholder = textField.stringValue.isEmpty && isLastItem
      return KeyboardBindingModel(menuTitle: textField.stringValue,
                                             keyboardShortcut: $0.keyboardShortcut,
                                             placeholder: placeholder)
    }

    var newModels = dataSource.models

    switch newModel.placeholder {
    case true:
      item.removeButton.isHidden = true
    case false:
      item.removeButton.isHidden = false
      newModels[indexPath.item] = newModel
      dataSource.modify(newModel, at: indexPath)
      if isLastItem {
        newModels.append(KeyboardBindingModel(placeholder: true))
        dataSource.reload(collectionView, updateOriginals: false, with: newModels) {
          let item = (collectionView.item(at: indexPath) as? KeyboardBindingItem)
          item?.menuTitleLabel.becomeFirstResponder()
          item?.menuTitleLabel.currentEditor()?.selectedRange = .init(location: textField.stringValue.count,
                                                                      length: 0)
        }
      }
    }

    if dataSource.isModified {
      keyboardController.addKeyboardShortcuts(newModels, for: application)
    } else {
      keyboardController.discardKeyboardShortcuts(for: application)
    }
  }

  func keyboardBindingItem(_ item: KeyboardBindingItem, recorderViewDidChange recorderView: RecordView, keyCombo: KeyCombo?) {
    guard let application = application else { return }
    guard let indexPath = collectionView.indexPath(for: item),
      indexPath.item < dataSource.models.count else { return }

    var binding: String = ""
    if let keyCombo = recorderView.keyCombo {
      let modifierStrings = KeyTransformer.modifiersToString(keyCombo.modifiers)
      let modifierKeys = modifierStrings.compactMap({ ModifierKey.build(from: $0)?.rawValue })
      binding = modifierKeys.joined() + keyCombo.characters.lowercased()
    }

    let model = dataSource.model(at: indexPath)
    let newModel = model.copy { .init(menuTitle: $0.menuTitle, keyboardShortcut: binding, placeholder: false) }
    var newModels = dataSource.models
    newModels[indexPath.item] = newModel
    dataSource.reload(collectionView, updateOriginals: false, with: newModels)

    if dataSource.isModified {
      keyboardController.addKeyboardShortcuts(newModels, for: application)
    } else {
      keyboardController.discardKeyboardShortcuts(for: application)
    }
  }

  func keyboardBindingItem(_ item: KeyboardBindingItem, didClickRemoveButton button: NSButton) {
    guard let application = application else { return }
    guard let indexPath = collectionView.indexPath(for: item),
      indexPath.item < dataSource.models.count else { return }
    var newModels = dataSource.models
    newModels.remove(at: indexPath.item)
    dataSource.reload(collectionView, updateOriginals: false, with: newModels)

    if dataSource.isModified {
      keyboardController.addKeyboardShortcuts(newModels, for: application)
    } else {
      keyboardController.discardKeyboardShortcuts(for: application)
    }
  }
}
