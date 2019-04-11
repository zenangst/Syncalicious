import Foundation

class SyncController {
  let destination: URL
  let applicationController: ApplicationController
  let fileManager = FileManager.default

  init(applicationController: ApplicationController, destination: URL) {
    self.applicationController = applicationController
    self.destination = destination
  }

  // MARK: - Public methods

  func enableSync(for application: Application, on machine: Machine) throws {
    try createSyncBackup(for: application, on: machine)
    let storage = try createStorageFolderIfNeeded()
    let storageUrl = copyPropertyList(for: application, to: storage)
    try createSymlink(for: application, to: storageUrl)
  }

  func disableSync(for application: Application, on machine: Machine) throws {
    let backup = destination
      .appendingPathComponent(machine.name)
      .appendingPathComponent(application.preferences.path.lastPathComponent)
    try replaceSymlinkWithRegularFile(for: application, to: backup)
    try fileManager.removeItem(at: backup)
  }

  // MARK: - Private methods

  private func createSyncBackup(for application: Application, on machine: Machine) throws {
    var from = application.preferences.path
    from.resolveSymlinksInPath()

    let folder = destination
      .appendingPathComponent(machine.name)

    try fileManager.createDirectory(at: folder,
                                    withIntermediateDirectories: true,
                                    attributes: nil)

    let toDestination = folder.appendingPathComponent(from.lastPathComponent)

    try fileManager.copyItem(at: from, to: toDestination)
  }

  private func createStorageFolderIfNeeded() throws -> URL {
    let storageDestination = destination.appendingPathComponent("Storage")
    try fileManager.createDirectory(at: storageDestination,
                                    withIntermediateDirectories: true,
                                    attributes: nil)
    return storageDestination
  }

  private func copyPropertyList(for application: Application, to url: URL) -> URL {
    let destination = url.appendingPathComponent(application.preferences.path.lastPathComponent)
    try? fileManager.copyItem(at: application.preferences.path, to: destination)
    return destination
  }

  private func createSymlink(for application: Application, to url: URL) throws {
    try fileManager.removeItem(at: application.preferences.path)
    try fileManager.createSymbolicLink(at: application.preferences.path, withDestinationURL: url)
  }

  private func replaceSymlinkWithRegularFile(for application: Application, to url: URL) throws {
    try fileManager.removeItem(at: application.preferences.path)
    try fileManager.copyItem(at: url, to: application.preferences.path)
  }
}
