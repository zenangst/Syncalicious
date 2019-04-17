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

  override func viewDidLoad() {
    super.viewDidLoad()

    let segmentControl = NSSegmentedControl(labels: SortKind.allCases.compactMap({ $0.rawValue }),
                                            trackingMode: .selectOne,
                                            target: self,
                                            action: #selector(didChangeSort(_:)))
    segmentControl.translatesAutoresizingMaskIntoConstraints = false

    if let sortKind = UserDefaults.standard.listSort,
      let index = ApplicationListSortViewController.SortKind.allCases.firstIndex(of: sortKind) {
      segmentControl.setSelected(true, forSegment: index)
    } else {
      segmentControl.setSelected(true, forSegment: 0)
    }

    view.addSubview(segmentControl)

    NSLayoutConstraint.deactivate(layoutConstraints)
    layoutConstraints = [
      segmentControl.topAnchor.constraint(equalTo: view.topAnchor),
      segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      segmentControl.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ]
    NSLayoutConstraint.activate(layoutConstraints)

    view.frame.size.height = 28
  }

  @objc func didChangeSort(_ segmentControl: NSSegmentedControl) {
    guard let label = segmentControl.label(forSegment: segmentControl.selectedSegment),
      let kind = SortKind.init(rawValue: label) else { return }
    UserDefaults.standard.listSort = kind
    delegate?.applicationListSortViewController(self, didChangeSort: kind)
  }
}
