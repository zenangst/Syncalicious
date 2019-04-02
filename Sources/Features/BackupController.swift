import Cocoa

enum BackupError: Error {
  case missingUrl
}

class BackupController {
  var openPanel: NSOpenPanel?

  func chooseDestination() {
    let panel = NSOpenPanel()
    panel.canChooseFiles = false
    panel.canChooseDirectories = true
    panel.canCreateDirectories = true
    panel.begin(completionHandler: { [weak self] in try? self?.handleDialogResponse($0) })
    openPanel = panel
  }

  func handleDialogResponse(_ response: NSApplication.ModalResponse) throws {
    guard response == NSApplication.ModalResponse.OK,
      let destination = openPanel?.urls.first else {
        throw BackupError.missingUrl
    }
    defer { openPanel = nil }
    UserDefaults.standard.backupDestination = destination
  }

  func backup(to destination: URL) {
    debugPrint("Backing up to destination: \(destination.path)")
  }
}
