import Cocoa
import Family

class DetailContainerViewController: FamilyViewController {
  let generalActionsViewController: GeneralActionsViewController
  let generalInfoViewController: GeneralInfoViewController
  let computersViewController: ComputerDetailItemViewController
  let applicationDetailViewController: ApplicationDetailItemViewController
  let keyboardShortcutViewController: KeyboardBindingViewController
  let keyboardShortcutActionsViewController: KeyboardActionsViewController

  init(generalActionsViewController: GeneralActionsViewController,
       generalInfoViewController: GeneralInfoViewController,
       computersViewController: ComputerDetailItemViewController,
       applicationsDetailViewController: ApplicationDetailItemViewController,
       keyboardShortcutViewController: KeyboardBindingViewController,
       keyboardShortcutActionsViewController: KeyboardActionsViewController) {
    self.generalActionsViewController = generalActionsViewController
    self.generalInfoViewController = generalInfoViewController
    self.computersViewController = computersViewController
    self.applicationDetailViewController = applicationsDetailViewController
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
    addChild(applicationDetailViewController,
             customInsets: .init(top: 0, left: 30, bottom: 15, right: 30)) {
              $0.collectionView }
    addChild(generalInfoViewController,
             customInsets: .init(top: 15, left: 30, bottom: 0, right: 30))
    addChild(generalActionsViewController)
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
