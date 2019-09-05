import Foundation

public class OperationController: CoreOperationDelegate {
  public typealias OperationManagerCompletion = (() -> Void)?
  private let _operationQueue: OperationQueue
  private let _lock = NSLock()
  private var _isLocked: Bool = false
  private var _operations = [CoreOperation]()
  public var isExecuting: Bool { return !_operationQueue
    .operations.filter({ !$0.isCancelled }).isEmpty }

  public init(operationQueue: OperationQueue = .init()) {
    self._operationQueue = operationQueue
  }

  public func cancelAllOperations() {
    guard !_operations.isEmpty, !_isLocked else { return }
    _isLocked = true
    _lock.lock()
    _operationQueue.isSuspended = true
    _operationQueue.cancelAllOperations()
    _operationQueue.isSuspended = false
    _lock.unlock()
    _isLocked = false
  }

  @discardableResult
  public func add(_ operations: DispatchOperation ...) -> OperationController {
    for operation in operations {
      if !_operations.contains(operation) {
        _operations.append(operation)
      }
      operation.delegate = self
    }
    return self
  }

  public func execute(_ completion: OperationManagerCompletion = nil) {
    _operations.forEach { $0.delegate = self }
    if _operations.isEmpty {
      DispatchQueue.main.execute(completion)
    } else {
      if let lastOperation = _operations.last {
        lastOperation.completionBlock = {
          completion?()
        }
        execute(_operations)
      }
    }
  }

  public func execute(_ operations: [CoreOperation]) {
    let validOperations = operations.filter({ operation in
        !operation.isFinished &&
        !operation.isCancelled &&
        !operation.isExecuting
    })

    _operationQueue.addOperations(validOperations, waitUntilFinished: false)
  }

  public func execute(_ operations: CoreOperation ...) {
    execute(operations)
  }

  // MARK: - CoreOperationDelegate

  func coreOperation(_ operation: CoreOperation, didCancel flag: Bool) {
    _lock.lock()
    if let indexOf = _operations.firstIndex(of: operation) {
      _operations.remove(at: indexOf)
    }
    _lock.unlock()
  }

  func coreOperation(_ operation: CoreOperation, didComplete flag: Bool) {
    _lock.lock()
    if let indexOf = _operations.firstIndex(of: operation) {
      _operations.remove(at: indexOf)
    }
    _lock.unlock()
  }
}
