import Foundation

enum PreferenceKind: String, Hashable {
  case container = "Container/Preferences"
  case library = "Library/Preferences"
}

struct Preferences: Hashable {
  let fileName: String
  let kind: PreferenceKind
  let path: URL
}
