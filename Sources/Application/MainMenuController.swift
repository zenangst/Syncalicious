import Cocoa

class MainMenuController: NSObject {
  weak var dependencyContainer: DependencyContainer?

  // MARK: - Actions

  @IBAction func selectBackupDestination(_ sender: Any?) {
    dependencyContainer?.backupController.chooseDestination()
  }

  @IBAction func performBackup(_ sender: Any?) {
    guard let backupDestination = UserDefaults.standard.backupDestination else {
      // TODO: Make this string localizable.
      let alert = createAlert(with: "You need to pick a backup destination before you can make a backup.")
      alert.runModal()
      return
    }
    dependencyContainer?.backupController.backup(to: backupDestination)
  }

  // MARK: - Private methods

  private func createAlert(with text: String) -> NSAlert {
    let alert = NSAlert()
    alert.alertStyle = .warning
    alert.addButton(withTitle: "Ok")
    alert.messageText = text
    return alert
  }
}
