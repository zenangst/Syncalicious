import Foundation

extension NSDictionary {
  func value(forPropertyListKey key: PropertyListKey) -> String? {
    return value(forKey: key.rawValue) as? String
  }

  func value<T>(forPropertyListKey key: PropertyListKey, ofType: T.Type) -> T? {
    return value(forKey: key.rawValue) as? T
  }
}
