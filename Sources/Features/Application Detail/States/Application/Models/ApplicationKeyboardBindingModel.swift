import Foundation

struct ApplicationKeyboardBindingModel: Hashable {
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

  func copy(_ handler: (ApplicationKeyboardBindingModel) -> ApplicationKeyboardBindingModel) -> ApplicationKeyboardBindingModel {
    return handler(self)
  }
}
