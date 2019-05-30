import Foundation

protocol CoreOperationDelegate: class {
  func coreOperation(_ operation: CoreOperation, didCancel flag: Bool)
  func coreOperation(_ operation: CoreOperation, didComplete flag: Bool)
}

open class CoreOperation: Operation {
  weak var delegate: CoreOperationDelegate?
  private let lock = NSLock()
  var children = [CoreOperation]()

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

  open func addDependency(_ operation: CoreOperation) {
    super.addDependency(operation)
    operation.children.append(self)
  }

  open override func cancel() {
    completionBlock = nil
    super.cancel()
    execute()
    _finished = true
    delegate?.coreOperation(self, didCancel: true)
  }

  @objc public func execute() {
    _executing = true
  }

  @objc public func complete() {
    _finished = true
    delegate?.coreOperation(self, didComplete: true)
  }

  @objc public func cancelChildren() {
    lock.lock()
    childrenRecursive().forEach {
      $0.cancel()
      $0.complete()
    }
    lock.unlock()
  }

  func childrenRecursive() -> [CoreOperation] {
    return children + children.flatMap { $0.childrenRecursive() }
  }
}
