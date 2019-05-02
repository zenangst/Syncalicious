import Foundation

open class CoreOperation: Operation {
  override open var isExecuting: Bool { return _executing }

  private var _executing = false {
    willSet { willChangeValue(forKey: "isExecuting") }
    didSet  { didChangeValue(forKey: "isExecuting") }
  }

  private var _finished = false {
    willSet { willChangeValue(forKey: "isFinished") }
    didSet  { didChangeValue(forKey: "isFinished") }
  }

  override open var isFinished: Bool {
    return _finished
  }

  public func executing(_ executing: Bool) {
    _executing = executing
  }

  public func finish(_ finished: Bool) {
    _finished = finished
  }
}
