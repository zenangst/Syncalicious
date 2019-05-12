import Foundation

open class CoreOperation: Operation {
  override open var isExecuting: Bool { return _executing }
  private var _executing = false {
    willSet { willChangeValue(forKey: "isExecuting") }
    didSet { didChangeValue(forKey: "isExecuting") }
  }

  private var _finished = false {
    willSet { willChangeValue(forKey: "isFinished") }
    didSet { didChangeValue(forKey: "isFinished") }
  }

  override open var isFinished: Bool {
    return _finished
  }

  @objc public func execute() {
    _executing = true
  }

  @objc public func complete() {
    _finished = true
  }
}
