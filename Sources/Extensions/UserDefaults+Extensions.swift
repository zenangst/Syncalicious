import Foundation

extension UserDefaults {
  var backupDestination: URL? {
    get { return url(forKey: #function) }
    set { set(newValue, forKey: #function) }
  }
}
