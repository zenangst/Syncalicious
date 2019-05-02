import Foundation

public extension DispatchQueue {
  typealias Closure = (() -> Void)

  func execute(_ closure: Closure? = nil) {
    wrap(closure)()
  }

  func wrap(_ closure: Closure? = nil) -> Closure {
    return { self.async { closure?() } }
  }
}
