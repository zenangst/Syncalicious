import Foundation

extension FileManager {
  func createFolderAtUrlIfNeeded(_ url: URL) throws {
    if !folderExists(atPath: url.path) {
      try createDirectory(at: url,
                          withIntermediateDirectories: true,
                          attributes: nil)
    }
  }

  func folderExists(atPath path: String) -> Bool {
    var isDirectory = ObjCBool(true)
    return fileExists(atPath: path, isDirectory: &isDirectory)
  }
}
