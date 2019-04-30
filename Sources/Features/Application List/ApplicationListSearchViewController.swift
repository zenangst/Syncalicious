import Cocoa

protocol ApplicationListSearchViewControllerDelegate: class {
  func applicationDetailSearchViewController(_ controller: ApplicationListSearchViewController,
                                             didStartSearch searchField: NSSearchField)
  func applicationDetailSearchViewController(_ controller: ApplicationListSearchViewController,
                                             didEndSearch searchField: NSSearchField)
}

class ApplicationListSearchViewController: ViewController, NSSearchFieldDelegate {
  private(set) lazy var searchField = SearchField()
  weak var delegate: ApplicationListSearchViewControllerDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()

    view.subviews.forEach { $0.removeFromSuperview() }

    searchField.delegate = self
    searchField.focusRingType = .none
    searchField.sendsSearchStringImmediately = true
    searchField.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(searchField)

    NSLayoutConstraint.deactivate(layoutConstraints)
    layoutConstraints = [
      searchField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      searchField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      searchField.widthAnchor.constraint(greaterThanOrEqualToConstant: 240)
    ]
    NSLayoutConstraint.activate(layoutConstraints)

    view.frame.size.height = 28
  }

  func controlTextDidChange(_ obj: Notification) {
    guard !searchField.stringValue.isEmpty else { return }
    delegate?.applicationDetailSearchViewController(self, didStartSearch: searchField)
  }

  func searchFieldDidStartSearching(_ sender: NSSearchField) {
    delegate?.applicationDetailSearchViewController(self, didStartSearch: sender)
  }

  func searchFieldDidEndSearching(_ sender: NSSearchField) {
    delegate?.applicationDetailSearchViewController(self, didEndSearch: sender)
  }
}
