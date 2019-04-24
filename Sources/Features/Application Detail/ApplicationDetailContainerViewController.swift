import Cocoa
import Family

class ApplicationDetailContainerViewController: FamilyViewController {
  let applicationInfoViewController: ApplicationDetailInfoViewController
  let applicationsDetailViewController: ApplicationDetailItemViewController

  init(applicationInfoViewController: ApplicationDetailInfoViewController,
       applicationsDetailViewController: ApplicationDetailItemViewController) {
    self.applicationInfoViewController = applicationInfoViewController
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
             customInsets: .init(top: 15, left: 30, bottom: 15, right: 30),
             view: { $0.collectionView })
    addChild(applicationInfoViewController, customInsets: .init(top: 15, left: 30, bottom: 15, right: 30))
  }
}
