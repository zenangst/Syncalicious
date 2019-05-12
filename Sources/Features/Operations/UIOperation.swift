import Foundation

open class UIOperation: DispatchOperation {
  override init(_ operationClosure: @escaping OperationClosure) {
    super.init(operationClosure)
    self.dispatchQueue = DispatchQueue.main
  }
}
