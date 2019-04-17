import Cocoa

protocol ApplicationListSortViewControllerDelegate: class {
  func applicationListSortViewController(_ controller: ApplicationListSortViewController,
                                         didChangeSort sort: ApplicationListSortViewController.SortKind)
}

class ApplicationListSortViewController: ViewController {
  enum SortKind: String, CaseIterable {
    case name = "Name", synced = "Synced"
  }

  weak var delegate: ApplicationListSortViewControllerDelegate?
  private var layoutConstraints = [NSLayoutConstraint]()
  lazy var segmentedControl = NSSegmentedControl(labels: SortKind.allCases.compactMap({ $0.rawValue }),
                                               trackingMode: .selectOne,
                                               target: self,
                                               action: #selector(didChangeSort(_:)))

  override func viewDidLoad() {
    super.viewDidLoad()

    segmentedControl.translatesAutoresizingMaskIntoConstraints = false

    if let sortKind = UserDefaults.standard.listSort,
      let index = ApplicationListSortViewController.SortKind.allCases.firstIndex(of: sortKind) {
      segmentedControl.setSelected(true, forSegment: index)
    } else {
      segmentedControl.setSelected(true, forSegment: 0)
    }

    view.addSubview(segmentedControl)

    NSLayoutConstraint.deactivate(layoutConstraints)
    layoutConstraints = [
      segmentedControl.topAnchor.constraint(equalTo: view.topAnchor),
      segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      segmentedControl.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ]
    NSLayoutConstraint.activate(layoutConstraints)

    view.frame.size.height = 28
  }

  @objc func didChangeSort(_ segmentedControl: NSSegmentedControl) {
    guard let label = segmentedControl.label(forSegment: segmentedControl.selectedSegment),
      let kind = SortKind.init(rawValue: label) else { return }
    UserDefaults.standard.listSort = kind
    delegate?.applicationListSortViewController(self, didChangeSort: kind)
  }
}
