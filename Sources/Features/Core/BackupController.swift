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

  func doesBackupExists(for application: Application, on machine: Machine, at url: URL) -> Bool {
    var from = application.preferences.url
    from.resolveSymlinksInPath()
    let destination = machineController.machineBackupDestination(for: url, on: machine)
      .appendingPathComponent(application.preferences.kind.rawValue)
      .appendingPathComponent(from.lastPathComponent)

    return fileManager.fileExists(atPath: destination.path)
  }

  func runBackup(for applications: [Application], to url: URL) throws {
    try createFolderIfNeeded(at: machineController.machineBackupDestination(for: url, on: machineController.machine))
    for application in applications where application.preferences.url.isFileURL {
      var from = application.preferences.url
      from.resolveSymlinksInPath()
      let backupFolder = machineController.machineBackupDestination(for: url, on: machineController.machine)
        .appendingPathComponent(application.preferences.kind.rawValue)
      let destination = backupFolder.appendingPathComponent(from.lastPathComponent)

      try createFolderIfNeeded(at: backupFolder)

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
    let fileManager = FileManager.default
    var isDirectory = ObjCBool(true)

    guard !fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
      return
    }

    do {
      try fileManager.createDirectory(at: url,
                                      withIntermediateDirectories: true,
                                      attributes: nil)
      debugPrint("Created directory at: \(url.path)")
    } catch let error {
      throw BackupError.unableToCreateBackupFolder(error)
    }
  }
}
