import Foundation

open class DispatchOperation: CoreOperation, Dispatchable {
  public typealias OperationClosure = (_ operation: DispatchOperation) -> Void
  internal var dispatchQueue: DispatchQueue
  let operationClosure: OperationClosure
  let waitUntilDone: Bool

  public init(_ operationClosure: @escaping OperationClosure) {
    self.waitUntilDone = true
    self.operationClosure = operationClosure
    self.dispatchQueue = DispatchQueue.global(qos: .utility)
    super.init()
  }

  override open func main() {
    execute()
    dispatchQueue.execute(run)
  }

  private func run() {
    guard !isCancelled else { return }
    operationClosure(self)
    if !waitUntilDone {
      self.complete()
    }
  }
}
