import Foundation

open class UtilityOperation: DispatchOperation {
  override init(waitUntilDone: Bool = false, _ operationClosure: @escaping OperationClosure) {
    super.init(waitUntilDone: waitUntilDone, operationClosure)
    self.dispatchQueue = DispatchQueue.main
  }
}
