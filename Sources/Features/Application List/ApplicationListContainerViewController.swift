import Cocoa
import Family

class ApplicationListContainerViewController: FamilyViewController {
  let listViewController: ApplicationListItemViewController
  let searchViewController: ApplicationListSearchViewController

  init(listViewController: ApplicationListItemViewController,
       searchViewController: ApplicationListSearchViewController) {
    self.listViewController = listViewController
    self.searchViewController = searchViewController
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    addChild(searchViewController, customInsets: .init(top: 10, left: 0, bottom: 0, right: 0))
    addChild(listViewController, view: { return $0.collectionView })
  }
}
