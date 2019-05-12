import Foundation

open class UtilityOperation: DispatchOperation {
  override init(_ operationClosure: @escaping OperationClosure) {
    super.init(operationClosure)
    self.dispatchQueue = DispatchQueue.global(qos: .utility)
  }
}
