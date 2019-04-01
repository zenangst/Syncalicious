import Foundation

enum InfoPropertyListKey: String {
  case bundleName = "CFBundleName"
  case executableName = "CFBundleExecutable"
  case iconFile = "CFBundleIconFile"
  case bundleIdentifier = "CFBundleIdentifier"
  case defaultsDomain = "SUDefaultsDomain"
}

struct InfoPropertyList {
  let bundleIdentifier: String
  let defaultsDomain: String?
  let path: String
}
