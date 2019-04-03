import Cocoa

class MainMenuController: NSObject {
  weak var dependencyContainer: DependencyContainer?

  // MARK: - Actions

  @IBAction func selectBackupDestination(_ sender: Any?) {
    dependencyContainer?.backupController.chooseDestination()
  }

  @IBAction func performBackup(_ sender: Any?) {
    guard let backupDestination = UserDefaults.standard.backupDestination else {
      let message = NSLocalizedString("You need to pick a backup destination before you can make a backup.", comment: "")
      let alert = createAlert(with: message)
      alert.runModal()
      return
    }
    do {
      try dependencyContainer?.backupController.initializeBackup(to: backupDestination)
    } catch let error {
      let alert = createAlert(error: error)
      alert.runModal()
    }
  }

  // MARK: - Private methods

  private func createAlert(with text: String = "", error: Error? = nil) -> NSAlert {
    let alert: NSAlert
    if let error = error {
      alert = NSAlert(error: error)
    } else {
      alert = NSAlert()
      alert.messageText = text
    }

    alert.alertStyle = .warning
    alert.addButton(withTitle: "Ok")

    return alert
  }
}
