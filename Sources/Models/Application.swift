import Foundation

struct Application: Hashable {
  let url: URL
  let propertyList: InfoPropertyList
  let preferences: Preferences
  let needsFullDiskAccess: Bool
}
