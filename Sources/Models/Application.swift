import Foundation

struct Application: Hashable {
  let url: URL
  let propertyList: ApplicationPropertyList
  let preferences: Preferences
  let needsFullDiskAccess: Bool
}
