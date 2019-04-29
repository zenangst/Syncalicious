import Foundation

extension UserDefaults {
  var syncaliciousUrl: URL? {
    get { return url(forKey: #function) }
    set { set(newValue, forKey: #function) }
  }

  var backupWhenIdle: Bool {
    get { return bool(forKey: #function) }
    set { set(newValue, forKey: #function) }
  }

  var listSort: ApplicationListSortViewController.SortKind? {
    get {
      if let string = string(forKey: #function),
        let sortKind = ApplicationListSortViewController.SortKind.init(rawValue: string) {
        return sortKind
      }
      return nil
    }
    set {
      if let newValue = newValue {
        set(newValue.rawValue, forKey: #function)
      }
    }
  }
}
