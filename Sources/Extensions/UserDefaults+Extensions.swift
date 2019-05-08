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

  var detailTab: ApplicationDetailFeatureViewController.Tab {
    get {
      if let string = string(forKey: #function),
        let tab = ApplicationDetailFeatureViewController.Tab.init(rawValue: string) {
        return tab
      }
      return .general
    }
    set {
      set(newValue.rawValue, forKey: #function)
    }
  }

  var listSort: ApplicationListSortViewController.SortKind? {
    get {
      if let string = string(forKey: #function) {
        return ApplicationListSortViewController.SortKind.init(rawValue: string)
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
