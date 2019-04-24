import Cocoa

public extension NSLayoutConstraint {
  /// Add layout constraints to a view.
  ///
  /// - Parameters:
  ///   - activate: Indicates if the constraints should be activated or not.
  ///   - constraints: The constraints that should be applied.
  /// - Returns: The constraints that was applied to the view.
  @discardableResult static func constrain(_ constraints: [NSLayoutConstraint?]) -> [NSLayoutConstraint] {
    for constraint in constraints {
      (constraint?.firstItem as? NSView)?.translatesAutoresizingMaskIntoConstraints = false
    }

    NSLayoutConstraint.activate(constraints.compactMap { $0 })

    return constraints.compactMap { $0 }
  }
}
