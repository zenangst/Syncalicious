import Cocoa
import Family

class ApplicationListContainerViewController: FamilyViewController {
  let listViewController: ApplicationListItemViewController
  let searchViewController: ApplicationListSearchViewController
  let sortViewController: ApplicationListSortViewController

  init(listViewController: ApplicationListItemViewController,
       searchViewController: ApplicationListSearchViewController,
       sortViewController: ApplicationListSortViewController) {
    self.listViewController = listViewController
    self.searchViewController = searchViewController
    self.sortViewController = sortViewController
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    addChild(searchViewController, customInsets: .init(top: 10, left: 0, bottom: 0, right: 0))
    addChild(sortViewController, customInsets: .init(top: 10, left: 10, bottom: 0, right: 10))
    addChild(listViewController, view: { return $0.collectionView })
  }
}
