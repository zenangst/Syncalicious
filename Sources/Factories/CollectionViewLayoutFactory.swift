import Blueprints
import Cocoa

class CollectionViewLayoutFactory {
  func createApplicationListLayout() -> NSCollectionViewFlowLayout {
    let layout = VerticalBlueprintLayout(itemsPerRow: 1,
                                         height: 48,
                                         minimumInteritemSpacing: 0,
                                         minimumLineSpacing: 0,
                                         sectionInset: .init(top: 10, left: 10, bottom: 10, right: 10),
                                         stickyHeaders: false,
                                         stickyFooters: false)
    return layout
  }
}
