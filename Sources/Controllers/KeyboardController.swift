import Cocoa

class KeyboardController {
  private var keyboardStorage = [String: [KeyboardBindingModel]]()
  private let applicationController: ApplicationController
  private let fileManager: FileManager
  private let machineController: MachineController
  private let operationController: OperationController
  private let operationFactory: OperationFactory
  private let workspace: NSWorkspace

  init(applicationController: ApplicationController,
       fileManager: FileManager = .default,
       machineController: MachineController,
       operationController: OperationController,
       operationFactory: OperationFactory,
       workspace: NSWorkspace = .shared) {
    self.applicationController = applicationController
    self.fileManager = fileManager
    self.machineController = machineController
    self.operationController = operationController
    self.operationFactory = operationFactory
    self.workspace = workspace
  }

  func keyboardShortcuts(for application: Application) -> [KeyboardBindingModel] {
    var keyboardShortcuts = keyboardStorage[application.propertyList.bundleIdentifier] ?? []
    if keyboardShortcuts.isEmpty {
      if let keyboardContents = application.preferences.keyEquivalents {
        for (key, value) in keyboardContents {
          keyboardShortcuts.append(KeyboardBindingModel(menuTitle: key, keyboardShortcut: value))
        }
      }
      keyboardShortcuts.append(KeyboardBindingModel(placeholder: true))
    }
    return keyboardShortcuts.sorted(by: { $0.placeholder == false && $0.menuTitle < $1.menuTitle })
  }

  func addKeyboardShortcuts(_ keyboardShortcuts: [KeyboardBindingModel],
                            for application: Application) {
    keyboardStorage[application.propertyList.bundleIdentifier] = keyboardShortcuts
  }

  func discardKeyboardShortcuts(for application: Application) {
    keyboardStorage[application.propertyList.bundleIdentifier] = nil
  }

  func saveKeyboardShortcutsIfNeeded(for application: Application) {
    guard let destination = UserDefaults.standard.syncaliciousUrl else { return }

    guard let unsavedShortcuts = keyboardStorage[application.propertyList.bundleIdentifier] else {
      return
    }

    guard let contents = NSMutableDictionary(contentsOfFile: application.preferences.url.path) else {
      return
    }

    let newContents = contents
    var dictionary = [String: String]()

    for shortcut in unsavedShortcuts where !shortcut.menuTitle.isEmpty {
      dictionary[shortcut.menuTitle] = shortcut.keyboardShortcut
    }

    newContents.setValue(dictionary, forKey: PropertyListKey.keyEquivalents.rawValue)

    let customize = destination
      .appendingPathComponent(machineController.machine.name)
      .appendingPathComponent("Customize")

    do {
      try fileManager.createFolderAtUrlIfNeeded(customize)
      let filePath = customize.appendingPathComponent(application.preferences.fileName)

      newContents.write(to: filePath, atomically: true)

      let updateKeyboardShortcutsOperation = operationFactory.createSyncOperation(for: application,
                                                                                  location: filePath,
                                                                                  runningApplication: nil,
                                                                                  then: {})
      if workspace.applicationIsRunning(application) {
        applicationController.restart(application: application, operations: [
          updateKeyboardShortcutsOperation
          ])
      } else {
        operationController.execute(updateKeyboardShortcutsOperation)
      }

    } catch let error {
      debugPrint(error)
    }
  }
}
