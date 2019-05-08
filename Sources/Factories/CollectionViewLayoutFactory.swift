import Blueprints
import Cocoa

class CollectionViewLayoutFactory {
  func createApplicationsLayout() -> NSCollectionViewFlowLayout {
    let layout = VerticalBlueprintLayout(itemsPerRow: 4,
                                         height: 96,
                                         minimumInteritemSpacing: 15,
                                         minimumLineSpacing: 30,
                                         sectionInset: .init(top: 25, left: 5, bottom: 5, right: 5))
    return layout
  }

  func createComputerLayout() -> NSCollectionViewFlowLayout {
    let layout = HorizontalBlueprintLayout(itemsPerRow: 2,
                                           height: 212,
                                           minimumInteritemSpacing: 10,
                                           minimumLineSpacing: 10,
                                           sectionInset: .init(top: 0, left: 20, bottom: 5, right: 20))
    return layout
  }

  func createKeyboardShortcutLayout() -> NSCollectionViewFlowLayout {
    let layout = VerticalBlueprintLayout(itemsPerRow: 1,
                                         height: 48,
                                         minimumInteritemSpacing: 0,
                                         minimumLineSpacing: 5,
                                         sectionInset: .init(top: 5, left: 20, bottom: 20, right: 20))
    return layout
  }

  func createApplicationListLayout() -> NSCollectionViewFlowLayout {
    let layout = VerticalBlueprintLayout(itemsPerRow: 1,
                                         height: 48,
                                         minimumInteritemSpacing: 0,
                                         minimumLineSpacing: 5,
                                         sectionInset: .init(top: 5, left: 5, bottom: 5, right: 5))
    return layout
  }
}
