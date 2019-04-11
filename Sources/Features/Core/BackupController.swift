import Cocoa

enum BackupError: Error {
  case missingUrl
  case noBackupDestination
  case unableToCreateBackupFolder(Error)
}

protocol BackupControllerDelegate: class {
  func backupController(_ controller: BackupController, didSelectDestination destination: URL)
}

class BackupController {
  weak var delegate: BackupControllerDelegate?
  var applications = [Application]()
  var openPanel: NSOpenPanel?
  let machineController: MachineController
  let fileManager = FileManager.default

  init(machineController: MachineController) {
    self.machineController = machineController
  }

  // MARK: - Public methods

  func chooseDestination() {
    let panel = NSOpenPanel()
    panel.canChooseFiles = false
    panel.canChooseDirectories = true
    panel.canCreateDirectories = true
    panel.begin(completionHandler: { [weak self] in try? self?.handleDialogResponse($0) })
    openPanel = panel
  }

  func initializeBackup(to destination: URL) throws {
    guard !applications.isEmpty else {
      // Show error message if there are no applications.
      return
    }

    try createFolderIfNeeded(at: destination)
    try runBackup(for: applications, to: destination)
    debugPrint("Backing up to destination: \(destination.path)")
  }

  func doesBackupExists(for application: Application, at url: URL) -> Bool {
    var from = application.preferences.path
    from.resolveSymlinksInPath()
    let destination = machineController.machineBackupDestination(for: url)
      .appendingPathComponent(from.lastPathComponent)

    return fileManager.fileExists(atPath: destination.path)
  }

  func runBackup(for applications: [Application], to url: URL) throws {
    try createFolderIfNeeded(at: url)
    for application in applications where application.preferences.path.isFileURL {
      var from = application.preferences.path
      from.resolveSymlinksInPath()
      let destination = machineController.machineBackupDestination(for: url)
        .appendingPathComponent(from.lastPathComponent)
      do {
        try fileManager.copyItem(at: from, to: destination)
      } catch let error {
        debugPrint(error)
      }
    }
  }

  // MARK: - Private methods

  private func handleDialogResponse(_ response: NSApplication.ModalResponse) throws {
    guard response == NSApplication.ModalResponse.OK,
      let destination = openPanel?.urls.first else {
        throw BackupError.missingUrl
    }

    delegate?.backupController(self, didSelectDestination: destination)
    openPanel = nil
  }

  private func createFolderIfNeeded(at url: URL) throws {
    let backupLocation = machineController.machineBackupDestination(for: url)
    let fileManager = FileManager.default
    var isDirectory = ObjCBool(true)

    guard !fileManager.fileExists(atPath: backupLocation.path, isDirectory: &isDirectory) else {
      return
    }

    do {
      try fileManager.createDirectory(at: backupLocation,
                                      withIntermediateDirectories: true,
                                      attributes: nil)
      debugPrint("Created directory at: \(backupLocation.path)")
    } catch let error {
      throw BackupError.unableToCreateBackupFolder(error)
    }
  }
}
