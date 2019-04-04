import Foundation

enum InfoPropertyListKey: String {
  case bundleIdentifier = "CFBundleIdentifier"
  case bundleName = "CFBundleName"
  case defaultsDomain = "SUDefaultsDomain"
  case executableName = "CFBundleExecutable"
  case iconFile = "CFBundleIconFile"
}

struct InfoPropertyList {
  let bundleIdentifier: String
  let bundleName: String
  let defaultsDomain: String?
  let path: String
}
