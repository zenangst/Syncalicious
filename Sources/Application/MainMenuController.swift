import Cocoa

class MainMenuController: NSObject {
  weak var dependencyContainer: DependencyContainer?

  // MARK: - Actions

  @IBAction func selectBackupDestination(_ sender: Any?) {
    dependencyContainer?.backupController.chooseDestination()
  }

  @IBAction func performBackup(_ sender: Any?) {
    guard let windowFactory = dependencyContainer?.windowFactory else { return }

    guard let backupDestination = UserDefaults.standard.backupDestination else {
      let message = NSLocalizedString("You need to pick a backup destination before you can make a backup.",
                                      comment: "")
      let alert = windowFactory.createAlert(with: message)
      alert.runModal()
      return
    }
    do {
      try dependencyContainer?.backupController.initializeBackup(to: backupDestination)
    } catch let error {
      let alert = windowFactory.createAlert(error: error)
      alert.runModal()
    }
  }
}
