import Foundation

enum PreferencesControllerError: Error {
  case findPreferenceFileFailed
  case parseContentsFailed
}

class PreferencesController {

  let libraryDirectory: URL

  init(libraryDirectory: URL) {
    self.libraryDirectory = libraryDirectory
  }

  func load(_ infoPlist: ApplicationPropertyList) throws -> Preferences {
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

    let propertyListUrl: URL
    let preferenceKind: PreferenceKind

    if let defaultsDomainUrl = defaultsDomainContainerUrl,
      FileManager.default.fileExists(atPath: defaultsDomainUrl.path) {
      propertyListUrl = defaultsDomainUrl
      preferenceKind = .container
    } else if FileManager.default.fileExists(atPath: containerPreferenceUrl.path) {
      propertyListUrl = containerPreferenceUrl
      preferenceKind = .container
    } else if let defaultsDomainUrl = defaultsDomainLibraryUrl,
      FileManager.default.fileExists(atPath: defaultsDomainUrl.path) {
      propertyListUrl = defaultsDomainUrl
      preferenceKind = .library
    } else if FileManager.default.fileExists(atPath: applicationPreference.path) {
      propertyListUrl = applicationPreference
      preferenceKind = .library
    } else {
      throw PreferencesControllerError.findPreferenceFileFailed
    }

    guard let contents = NSDictionary.init(contentsOfFile: propertyListUrl.path) else {
      throw PreferencesControllerError.parseContentsFailed
    }

    let keyEquivalents = contents.value(forPropertyListKey: .keyEquivalents,
                                        ofType: [String: String].self)

    return Preferences(fileName: propertyListUrl.lastPathComponent,
                       keyEquivalents: keyEquivalents,
                       kind: preferenceKind, url: propertyListUrl)
  }
}
