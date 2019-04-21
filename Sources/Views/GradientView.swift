import Cocoa

class GradientView: NSView {
  lazy var gradientLayer = CAGradientLayer()

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    loadView()
  }

  required init?(coder decoder: NSCoder) {
    super.init(coder: decoder)
    loadView()
  }

  @objc func loadView() {
    wantsLayer = true
    gradientLayer.startPoint = .init(x: 1.0, y: 0.0)
    gradientLayer.endPoint = .init(x: 0.25, y: 1.0)
    layer?.addSublayer(gradientLayer)
  }

  override func layout() {
    super.layout()
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    gradientLayer.frame = bounds
    CATransaction.commit()
  }
}
