import Cocoa

class CollectionViewLayoutFactory {
  func createApplicationListLayout() -> NSCollectionViewFlowLayout {
    let layout = NSCollectionViewFlowLayout()
    layout.sectionInset = .init(top: 10, left: 10, bottom: 10, right: 10)
    layout.minimumLineSpacing = 0
    layout.itemSize = .init(width: 250, height: 48)

    return layout
  }
}
