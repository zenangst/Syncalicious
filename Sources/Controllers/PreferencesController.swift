import Foundation

enum PreferencesControllerError: Error {
  case unableToFindPreferenceFile
}

class PreferencesController {
  func load(_ infoPlist: InfoPropertyList) throws -> Preferences {
    let libraryDirectory = try FileManager.default.url(for: .libraryDirectory,
                                                       in: .userDomainMask,
                                                       appropriateFor: nil,
                                                       create: false)

    let suffix = "Preferences/\(infoPlist.bundleIdentifier).plist"
    let applicationPreference = libraryDirectory.appendingPathComponent(suffix)
    let containerPreferenceUrl = libraryDirectory
      .appendingPathComponent("Containers/\(infoPlist.bundleIdentifier)/Data/Library/\(suffix)")

    var defaultsDomainContainerUrl: URL?
    var defaultsDomainLibraryUrl: URL?

    if let defaultsDomain = infoPlist.defaultsDomain {
      let suffix = "Preferences/\(defaultsDomain).plist"
      defaultsDomainContainerUrl = libraryDirectory
        .appendingPathComponent("Containers/\(infoPlist.bundleIdentifier)/Data/Library/\(suffix)")
      defaultsDomainLibraryUrl = libraryDirectory.appendingPathComponent(suffix)
    }

    if let defaultsDomainUrl = defaultsDomainContainerUrl,
      FileManager.default.fileExists(atPath: defaultsDomainUrl.path) {
      return Preferences(path: defaultsDomainUrl)
    } else if let defaultsDomainUrl = defaultsDomainLibraryUrl,
      FileManager.default.fileExists(atPath: defaultsDomainUrl.path) {
      return Preferences(path: defaultsDomainUrl)
    } else if FileManager.default.fileExists(atPath: containerPreferenceUrl.path) {
      return Preferences(path: containerPreferenceUrl)
    } else if FileManager.default.fileExists(atPath: applicationPreference.path) {
      return Preferences(path: applicationPreference)
    }

    throw PreferencesControllerError.unableToFindPreferenceFile
  }
}
