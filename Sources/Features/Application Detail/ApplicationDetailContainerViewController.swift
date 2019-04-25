import Cocoa
import Family

class ApplicationDetailContainerViewController: FamilyViewController {
  let applicationInfoViewController: ApplicationDetailInfoViewController
  let applicationComputersViewController: ApplicationComputerDetailItemViewController
  let applicationsDetailViewController: ApplicationDetailItemViewController

  init(applicationInfoViewController: ApplicationDetailInfoViewController,
       applicationComputersViewController: ApplicationComputerDetailItemViewController,
       applicationsDetailViewController: ApplicationDetailItemViewController) {
    self.applicationInfoViewController = applicationInfoViewController
    self.applicationComputersViewController = applicationComputersViewController
    self.applicationsDetailViewController = applicationsDetailViewController
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    addChild(applicationsDetailViewController,
             customInsets: .init(top: 0, left: 30, bottom: 15, right: 30),
             view: { $0.collectionView })
    addChild(applicationInfoViewController,
             customInsets: .init(top: 15, left: 30, bottom: 15, right: 30))
    addChild(applicationComputersViewController,
             customInsets: .init(top: 15, left: 0, bottom: 0, right: 0),
             view: { $0.collectionView })
    applicationComputersViewController.collectionView.backgroundColors = [NSColor.windowBackgroundColor]
  }
}
