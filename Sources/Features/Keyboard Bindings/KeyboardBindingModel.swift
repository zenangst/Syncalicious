import Foundation

struct KeyboardBindingModel: Hashable {
  let menuTitle: String
  let keyboardShortcut: String
  let placeholder: Bool

  init(menuTitle: String = "",
       keyboardShortcut: String = "",
       placeholder: Bool = false) {
    self.menuTitle = menuTitle
    self.keyboardShortcut = keyboardShortcut
    self.placeholder = placeholder
  }

  func copy(_ handler: (KeyboardBindingModel) -> KeyboardBindingModel) -> KeyboardBindingModel {
    return handler(self)
  }
}
