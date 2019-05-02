import Foundation

public extension OperationQueue {
  convenience init(maxConcurrentOperationCount: Int = OperationQueue.defaultMaxConcurrentOperationCount) {
    self.init()
    self.maxConcurrentOperationCount = maxConcurrentOperationCount
  }
}
