import Blueprints
import Cocoa

class CollectionViewLayoutFactory {
  func createApplicationListLayout() -> NSCollectionViewFlowLayout {
    let layout = VerticalBlueprintLayout(itemsPerRow: 1,
                                         height: 48,
                                         minimumInteritemSpacing: 0,
                                         minimumLineSpacing: 5,
                                         sectionInset: .init(top: 5, left: 5, bottom: 5, right: 5),
                                         stickyHeaders: false,
                                         stickyFooters: false)
    return layout
  }
}
