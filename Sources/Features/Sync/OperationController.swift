import Foundation

public class OperationController<T: Operation> {
  public typealias OperationManagerCompletion = (() -> Void)?
  private let _operationQueue: OperationQueue
  private let _lock = NSLock()
  private var _isLocked: Bool = false
  private var _operations = [T]()
  public var isExecuting: Bool { return !_operationQueue.operations.isEmpty }

  public init(operationQueue: OperationQueue = .init(maxConcurrentOperationCount: 1) ) {
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
  public func add(_ operations: T ...) -> OperationController {
    for operation in operations as [Operation] {
      operation.completionBlock = removeOperationClosure(operation: operation)
    }
    _operations.append(contentsOf: operations)
    return self
  }

  public func execute(_ completion: OperationManagerCompletion = nil) {
    if _operations.isEmpty {
      DispatchQueue.main.execute(completion)
    } else {
      if let lastOperation = _operations.last {
        lastOperation.completionBlock = { [weak self] in
          guard let strongSelf = self else { return }
          strongSelf.removeOperationClosure(operation: lastOperation)()
          DispatchQueue.main.execute(completion)
        }
        execute(_operations)
      }
    }
  }

  public func execute(_ operations: [T], waitUntilFinished: Bool = false) {
    Swift.print(_operations.count)
    _operationQueue.addOperations(operations, waitUntilFinished: waitUntilFinished)
  }

  public func execute(waitUntilFinished: Bool = false, _ operations: T ...) {
    execute(operations, waitUntilFinished: waitUntilFinished)
  }

  private func removeOperationClosure(operation: Operation) -> (() -> Void) {
    return { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf._lock.lock()
      let operations = strongSelf._operations as [Operation]
      if let indexOf = operations.firstIndex(of: operation) {
        strongSelf._operations.remove(at: indexOf)
      }
      strongSelf._lock.unlock()
    }
  }
}
