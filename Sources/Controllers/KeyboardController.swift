import Cocoa

class KeyboardController {
  private var keyboardStorage = [String: [ApplicationKeyboardBindingModel]]()

  func keyboardShortcuts(for application: Application) -> [ApplicationKeyboardBindingModel] {
    return keyboardStorage[application.propertyList.bundleIdentifier] ?? []
  }

  func addKeyboardShortcuts(_ keyboardShortcuts: [ApplicationKeyboardBindingModel], for application: Application) {
    keyboardStorage[application.propertyList.bundleIdentifier] = keyboardShortcuts
  }

  func discardKeyboardShortcuts(for application: Application) {
    keyboardStorage[application.propertyList.bundleIdentifier] = nil
  }
}
