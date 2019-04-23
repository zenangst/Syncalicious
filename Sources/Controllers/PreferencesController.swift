import Foundation

enum PreferencesControllerError: Error {
  case unableToFindPreferenceFile
}

class PreferencesController {

  let libraryDirectory: URL

  init(libraryDirectory: URL) {
    self.libraryDirectory = libraryDirectory
  }

  func load(_ infoPlist: InfoPropertyList) throws -> Preferences {
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

    defaultsDomainContainerUrl?.resolveSymlinksInPath()
    defaultsDomainLibraryUrl?.resolveSymlinksInPath()

    if let defaultsDomainUrl = defaultsDomainContainerUrl,
      FileManager.default.fileExists(atPath: defaultsDomainUrl.path) {
      return Preferences(fileName: defaultsDomainUrl.lastPathComponent,
                         kind: .container, url: defaultsDomainUrl)
    } else if FileManager.default.fileExists(atPath: containerPreferenceUrl.path) {
      return Preferences(fileName: containerPreferenceUrl.lastPathComponent,
                         kind: .container, url: containerPreferenceUrl)
    } else if let defaultsDomainUrl = defaultsDomainLibraryUrl,
      FileManager.default.fileExists(atPath: defaultsDomainUrl.path) {
      return Preferences(fileName: defaultsDomainUrl.lastPathComponent,
                         kind: .library, url: defaultsDomainUrl)
    } else if FileManager.default.fileExists(atPath: applicationPreference.path) {
      return Preferences(fileName: applicationPreference.lastPathComponent,
                         kind: .library, url: applicationPreference)
    }

    throw PreferencesControllerError.unableToFindPreferenceFile
  }
}
