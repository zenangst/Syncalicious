import Cocoa

protocol ApplicationSearchViewControllerDelegate: class {
  func applicationSearchViewController(_ controller: ApplicationSearchViewController,
                                       didStartSearch searchField: NSSearchField)
  func applicationSearchViewController(_ controller: ApplicationSearchViewController,
                                       didEndSearch searchField: NSSearchField)
}

class ApplicationSearchViewController: ViewController, NSSearchFieldDelegate {
  private var layoutConstraints = [NSLayoutConstraint]()
  private lazy var searchField = NSSearchField()
  weak var delegate: ApplicationSearchViewControllerDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()

    view.subviews.forEach { $0.removeFromSuperview() }

    searchField.delegate = self
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
    delegate?.applicationSearchViewController(self, didStartSearch: searchField)
  }

  func searchFieldDidStartSearching(_ sender: NSSearchField) {
    delegate?.applicationSearchViewController(self, didStartSearch: sender)
  }

  func searchFieldDidEndSearching(_ sender: NSSearchField) {
    delegate?.applicationSearchViewController(self, didEndSearch: sender)
  }
}
