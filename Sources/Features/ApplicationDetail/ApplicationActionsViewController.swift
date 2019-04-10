import Cocoa

class ApplicationActionsViewController: ViewController {
  private var layoutConstraints = [NSLayoutConstraint]()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.subviews.forEach { $0.removeFromSuperview() }

    NSLayoutConstraint.deactivate(layoutConstraints)
    layoutConstraints = []
    NSLayoutConstraint.activate(layoutConstraints)
  }
}
