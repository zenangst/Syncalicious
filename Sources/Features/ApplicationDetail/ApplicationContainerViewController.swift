import Cocoa
import Family

class ApplicationContainerViewController: FamilyViewController,
  SplitViewContainedController, NSCollectionViewDelegate {
  weak var listViewController: ApplicationItemViewController?

  lazy var titleLabel = SmallBoldLabel()
  lazy var titlebarView = NSView()

  private var layoutConstraints = [NSLayoutConstraint]()

  let applicationInfoViewController: ApplicationInfoViewController

  init(detailViewController: ApplicationInfoViewController) {
    self.applicationInfoViewController = detailViewController
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    addChild(applicationInfoViewController,
             customInsets: .init(top: 15, left: 15, bottom: 15, right: 15),
             height: 120)
    addChild(ApplicationActionsViewController(),
             customInsets: .init(top: 15, left: 105, bottom: 15, right: 105),
             height: 20)
  }

  // MARK: - Private methods

  private func render(_ application: Application) {
    applicationInfoViewController.render(application)
    NSLayoutConstraint.deactivate(layoutConstraints)
    layoutConstraints = []

    titlebarView.subviews.forEach { $0.removeFromSuperview() }
    titleLabel.stringValue = application.propertyList.bundleName
    titleLabel.alignment = .center
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titlebarView.wantsLayer = true
    titlebarView.addSubview(titleLabel)

    let button = NSButton(title: "Apply changes", target: nil, action: nil)
    button.translatesAutoresizingMaskIntoConstraints = false
    titlebarView.addSubview(button)

    layoutConstraints.append(contentsOf: [
      titleLabel.leadingAnchor.constraint(equalTo: titlebarView.leadingAnchor, constant: 10),
      titleLabel.trailingAnchor.constraint(equalTo: titlebarView.trailingAnchor, constant: -10),
      titleLabel.centerYAnchor.constraint(equalTo: titlebarView.centerYAnchor),
      button.centerYAnchor.constraint(equalTo: titlebarView.centerYAnchor),
      button.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
      ])

    NSLayoutConstraint.activate(layoutConstraints)
  }

  // MARK: - NSCollectionViewDelegate

  func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
    guard let indexPath = indexPaths.first else { return }
    guard let listViewController = listViewController else { return }
    guard let application = listViewController.model(at: indexPath).data["model"] as? Application else { return }

    render(application)
  }
}
