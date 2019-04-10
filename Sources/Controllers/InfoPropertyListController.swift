import Foundation

enum InfoPropertyListError: Error {
  case fileNotFound
  case unableToParseContents
  case unableToResolveBundleIdentifier
}

class InfoPropertyListController {
  func load(at url: URL) throws -> InfoPropertyList {
    let path = url.path
    let fileExists = FileManager.default.fileExists(atPath: path)

    if !fileExists { throw InfoPropertyListError.fileNotFound }

    guard let contents = NSDictionary.init(contentsOfFile: path) else {
      throw InfoPropertyListError.unableToParseContents
    }

    guard let bundleIdentifier = contents.value(forPropertyListKey: .bundleIdentifier) else {
      throw InfoPropertyListError.unableToResolveBundleIdentifier
    }

    let buildVersion = contents.value(forPropertyListKey: .buildVersion) ?? bundleIdentifier
    let bundleName = contents.value(forPropertyListKey: .bundleName) ?? bundleIdentifier
    let defaultsDomain = contents.value(forPropertyListKey: .defaultsDomain)
    let versionString = contents.value(forPropertyListKey: .versionString) ?? ""

    return InfoPropertyList(buildVersion: buildVersion,
                            bundleIdentifier: bundleIdentifier,
                            bundleName: bundleName,
                            defaultsDomain: defaultsDomain,
                            path: path,
                            versionString: versionString)
  }
}

fileprivate extension NSDictionary {
  func value(forPropertyListKey key: InfoPropertyListKey) -> String? {
    return value(forKey: key.rawValue) as? String
  }
}
