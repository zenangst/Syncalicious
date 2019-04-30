import Cocoa
import Family

class ApplicationDetailContainerViewController: FamilyViewController {
  let infoViewController: ApplicationDetailInfoViewController
  let computersViewController: ApplicationComputerDetailItemViewController
  let detailViewController: ApplicationDetailItemViewController

  init(applicationInfoViewController: ApplicationDetailInfoViewController,
       applicationComputersViewController: ApplicationComputerDetailItemViewController,
       applicationsDetailViewController: ApplicationDetailItemViewController) {
    self.infoViewController = applicationInfoViewController
    self.computersViewController = applicationComputersViewController
    self.detailViewController = applicationsDetailViewController
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    addChild(detailViewController,
             customInsets: .init(top: 0, left: 30, bottom: 15, right: 30),
             view: { $0.collectionView })
    addChild(infoViewController,
             customInsets: .init(top: 15, left: 30, bottom: 15, right: 30))
    addChild(computersViewController,
             customInsets: .init(top: 15, left: 0, bottom: 0, right: 0),
             view: { $0.collectionView })
    computersViewController.collectionView.backgroundColors = [NSColor.windowBackgroundColor]
  }
}
