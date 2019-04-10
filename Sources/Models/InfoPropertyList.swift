import Foundation

enum InfoPropertyListKey: String, Hashable {
  case buildVersion = "CFBundleVersion"
  case bundleIdentifier = "CFBundleIdentifier"
  case bundleName = "CFBundleName"
  case defaultsDomain = "SUDefaultsDomain"
  case executableName = "CFBundleExecutable"
  case iconFile = "CFBundleIconFile"
  case versionString = "CFBundleShortVersionString"
}

struct InfoPropertyList: Hashable {
  let buildVersion: String
  let bundleIdentifier: String
  let bundleName: String
  let defaultsDomain: String?
  let path: String
  let versionString: String
}
