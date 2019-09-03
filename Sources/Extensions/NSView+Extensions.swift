import Cocoa

extension NSView {
  func horizontalCompressionResistance(_ priority: NSLayoutConstraint.Priority) -> Self {
    setContentCompressionResistancePriority(priority, for: .horizontal)
    return self
  }

  func horizontalContentHugging(_ priority: NSLayoutConstraint.Priority) -> Self {
    setContentHuggingPriority(priority, for: .horizontal)
    return self
  }

  func verticalCompressionResistance(_ priority: NSLayoutConstraint.Priority) -> Self {
    setContentCompressionResistancePriority(priority, for: .vertical)
    return self
  }

  func verticalContentHugging(_ priority: NSLayoutConstraint.Priority) -> Self {
    setContentHuggingPriority(priority, for: .vertical)
    return self
  }
}
