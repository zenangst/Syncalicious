import Foundation

open class DispatchOperation: CoreOperation, Dispatchable {
  public typealias OperationClosure = (_ operation: DispatchOperation) -> Void
  internal var dispatchQueue: DispatchQueue
  let operationClosure: OperationClosure
  let waitUntilDone: Bool

  public init(waitUntilDone: Bool = false, _ operationClosure: @escaping OperationClosure) {
    self.waitUntilDone = waitUntilDone
    self.operationClosure = operationClosure
    self.dispatchQueue = DispatchQueue.global(qos: .utility)
    super.init()
  }

  override open func main() {
    executing(true)
    dispatchQueue.execute(run)
  }

  private func run() {
    operationClosure(self)
    if !waitUntilDone {
      self.finish(true)
    }
  }
}
