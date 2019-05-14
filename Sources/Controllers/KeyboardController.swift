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

  func saveKeyboardShortcutsIfNeeded(for application: Application, then handler: @escaping () -> Void) {
    guard let unsavedShortcuts = keyboardStorage[application.propertyList.bundleIdentifier] else {
      return
    }

    var dictionary = [String: String]()
    var operations = [DispatchOperation]()
    for shortcut in unsavedShortcuts where !shortcut.menuTitle.isEmpty {
      dictionary[shortcut.menuTitle] = shortcut.keyboardShortcut
    }

    operations.append(operationFactory.createKeyboardShortcutSync(for: application,
                                                                  machine: machineController.machine,
                                                                  dictionary: dictionary))
    operations.append(operationFactory.createReadPropertyListOperation(for: application))
    operations.append(UIOperation { handler(); $0.complete() })
    operations.append(UtilityOperation { [weak self] in
      self?.keyboardStorage[application.propertyList.bundleIdentifier] = nil
      $0.complete()
      })

    if workspace.applicationIsRunning(application) {
      applicationController.restart(application: application, operations: operations)
    } else {
      operationController.execute(operations)
    }
  }
}
