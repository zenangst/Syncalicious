import Foundation

enum InfoPropertyListKey: String {
  case buildVersion = "CFBundleVersion"
  case bundleIdentifier = "CFBundleIdentifier"
  case bundleName = "CFBundleName"
  case defaultsDomain = "SUDefaultsDomain"
  case executableName = "CFBundleExecutable"
  case iconFile = "CFBundleIconFile"
  case versionString = "CFBundleShortVersionString"
}

struct InfoPropertyList {
  let buildVersion: String
  let bundleIdentifier: String
  let bundleName: String
  let defaultsDomain: String?
  let path: String
  let versionString: String
}
