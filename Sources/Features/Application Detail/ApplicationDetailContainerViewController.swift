import Cocoa
import Family

class ApplicationDetailContainerViewController: FamilyViewController {
  let applicationInfoViewController: ApplicationDetailInfoViewController

  init(applicationInfoViewController: ApplicationDetailInfoViewController) {
    self.applicationInfoViewController = applicationInfoViewController
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    addChild(applicationInfoViewController, customInsets: .init(top: 15, left: 30, bottom: 15, right: 30))
  }
}
