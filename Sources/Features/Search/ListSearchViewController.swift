import Cocoa

protocol ListSearchViewControllerDelegate: class {
  func listSearchViewController(_ controller: ListSearchViewController,
                                didStartSearch searchField: NSSearchField)
  func listSearchViewController(_ controller: ListSearchViewController,
                                didEndSearch searchField: NSSearchField)
}

class ListSearchViewController: ViewController, NSSearchFieldDelegate {
  private(set) lazy var searchField = SearchField()
  weak var delegate: ListSearchViewControllerDelegate?

  override func loadView() {
    view = searchField
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    searchField.delegate = self
    searchField.focusRingType = .none
    searchField.sendsSearchStringImmediately = true
    view.frame.size.height = 24
  }

  func controlTextDidChange(_ obj: Notification) {
    guard !searchField.stringValue.isEmpty else { return }
    delegate?.listSearchViewController(self, didStartSearch: searchField)
  }

  func searchFieldDidStartSearching(_ sender: NSSearchField) {
    delegate?.listSearchViewController(self, didStartSearch: sender)
  }

  func searchFieldDidEndSearching(_ sender: NSSearchField) {
    delegate?.listSearchViewController(self, didEndSearch: sender)
  }
}
