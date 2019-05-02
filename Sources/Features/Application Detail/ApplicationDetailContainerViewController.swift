import Cocoa
import Family

class ApplicationDetailContainerViewController: FamilyViewController {
  let infoViewController: ApplicationDetailInfoViewController
  let computersViewController: ApplicationComputerDetailItemViewController
  let detailViewController: ApplicationDetailItemViewController
  let keyboardShortcutViewController: ApplicationKeyboardBindingItemViewController

  init(applicationInfoViewController: ApplicationDetailInfoViewController,
       applicationComputersViewController: ApplicationComputerDetailItemViewController,
       applicationsDetailViewController: ApplicationDetailItemViewController,
       keyboardShortcutViewController: ApplicationKeyboardBindingItemViewController) {
    self.infoViewController = applicationInfoViewController
    self.computersViewController = applicationComputersViewController
    self.detailViewController = applicationsDetailViewController
    self.keyboardShortcutViewController = keyboardShortcutViewController
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
    addChild(keyboardShortcutViewController,
             customInsets: .init(top: 0, left: 0, bottom: 0, right: 0),
             view: { $0.collectionView })
    computersViewController.collectionView.backgroundColors = [NSColor.windowBackgroundColor]
  }
}
