import Cocoa

open class ViewController: NSViewController {
  var layoutConstraints = [NSLayoutConstraint]()

  open override func loadView() {
    view = OpaqueView()
    view.wantsLayer = true
  }

  open override func viewDidLoad() {
    super.viewDidLoad()
    view.subviews.forEach { $0.removeFromSuperview() }
    NSLayoutConstraint.deactivate(layoutConstraints)
  }
}
