import Cocoa
import Family

class ApplicationDetailContainerViewController: FamilyViewController {
  let actionsViewController: ApplicationActionsViewController
  let infoViewController: ApplicationInfoViewController
  let computersViewController: ApplicationComputerDetailItemViewController
  let detailViewController: ApplicationDetailItemViewController
  let keyboardShortcutViewController: ApplicationKeyboardBindingViewController
  let keyboardShortcutActionsViewController: ApplicationKeyboardActionsViewController

  init(actionsViewController: ApplicationActionsViewController,
       applicationInfoViewController: ApplicationInfoViewController,
       applicationComputersViewController: ApplicationComputerDetailItemViewController,
       applicationsDetailViewController: ApplicationDetailItemViewController,
       keyboardShortcutViewController: ApplicationKeyboardBindingViewController,
       keyboardShortcutActionsViewController: ApplicationKeyboardActionsViewController) {
    self.actionsViewController = actionsViewController
    self.infoViewController = applicationInfoViewController
    self.computersViewController = applicationComputersViewController
    self.detailViewController = applicationsDetailViewController
    self.keyboardShortcutViewController = keyboardShortcutViewController
    self.keyboardShortcutActionsViewController = keyboardShortcutActionsViewController
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    addChild(detailViewController,
             customInsets: .init(top: 0, left: 30, bottom: 15, right: 30)) {
              $0.collectionView }
    addChild(infoViewController,
             customInsets: .init(top: 15, left: 30, bottom: 0, right: 30))
    addChild(actionsViewController)
    addChild(computersViewController) { $0.collectionView }
    addChild(keyboardShortcutViewController,
             customInsets: .init(top: 15, left: 0, bottom: 0, right: 0)) {
              $0.collectionView }
    addChild(keyboardShortcutActionsViewController,
             customInsets: .init(top: 0, left: 0, bottom: 0, right: 0))

    computersViewController.collectionView.backgroundColors = [NSColor.windowBackgroundColor]
    keyboardShortcutViewController.collectionView.backgroundColors = [NSColor.windowBackgroundColor]
    keyboardShortcutActionsViewController.view.wantsLayer = true
    keyboardShortcutActionsViewController.view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
  }
}
