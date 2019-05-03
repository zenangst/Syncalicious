import Carbon
import Cocoa
import KeyHolder
import Magnet

enum ModifierKey: String, CaseIterable {
  case shift = "$"
  case control = "^"
  case option = "~"
  case command = "@"

  var eventModifierFlag: NSEvent.ModifierFlags {
    switch self {
    case .shift:
      return .shift
    case .control:
      return .control
    case .option:
      return .option
    case .command:
      return .command
    }
  }
}

class ApplicationKeyboardBindingItem: CollectionViewItem, CollectionViewItemComponent {
  // sourcery: let menuTitle: String = "menuTitleLabel.stringValue = model.menuTitle"
  lazy var menuTitleLabel = NSTextField()
  // sourcery: let keyboardShortcut: String = "configureWithString(model.keyboardShortcut)"
  lazy var recorderView = RecordView()

  override func viewDidLoad() {
    super.viewDidLoad()

    let containerView = NSView()
    containerView.addSubview(menuTitleLabel)
    containerView.addSubview(recorderView)
    view.addSubview(containerView)

    layoutConstraints = [
      containerView.topAnchor.constraint(equalTo: view.topAnchor),
      containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

      menuTitleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
      menuTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      menuTitleLabel.trailingAnchor.constraint(equalTo: recorderView.leadingAnchor, constant: -20),

      recorderView.widthAnchor.constraint(equalToConstant: 160),
      recorderView.heightAnchor.constraint(equalToConstant: 32),
      recorderView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
      recorderView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
    ]
    NSLayoutConstraint.constrain(layoutConstraints)
  }

  func configureWithString(_ string: String) {
    let keyCodeString = string.replacingOccurrences(of: ModifierKey.allCases.compactMap({ $0.rawValue }))
    let currentModifier = ModifierKey.allCases.filter({ string.contains($0.rawValue) })
      .reduce(0, { $0 + $1.eventModifierFlag.rawValue })
    let modifiers = NSEvent.ModifierFlags.init(rawValue: currentModifier)

    var dictionary = [String: Int]()

    for offset in 0..<128 {
      guard let keyName = keyName(scanCode: UInt16(offset)) else { continue }
      dictionary[keyName] = offset
    }

    guard let keyCode = dictionary[keyCodeString] else { return }
    let keyCombo = KeyCombo.init(keyCode: keyCode, cocoaModifiers: modifiers)
    recorderView.keyCombo = keyCombo
  }

  func keyName(scanCode: UInt16) -> String? {
    let maxNameLength = 4
    let modifierKeys: UInt32  = 0
    let nameBuffer = UnsafeMutablePointer<UniChar>.allocate(capacity: maxNameLength)
    let nameLength = UnsafeMutablePointer<Int>.allocate(capacity: 1)
    let deadKeys   = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
    deadKeys[0] = 0x00000000

    let source = TISGetInputSourceProperty(TISCopyCurrentKeyboardLayoutInputSource().takeRetainedValue(),
                                           kTISPropertyUnicodeKeyLayoutData)
    let keyboardLayout = unsafeBitCast(CFDataGetBytePtr(unsafeBitCast(source, to: CFData.self)),
                                       to: UnsafePointer <UCKeyboardLayout>.self)
    let keyboardType = UInt32(LMGetKbdType())
    let osStatus  = UCKeyTranslate (keyboardLayout, scanCode, UInt16 (kUCKeyActionDown),
                                    modifierKeys, keyboardType, UInt32 (kUCKeyTranslateNoDeadKeysMask),
                                    deadKeys, maxNameLength, nameLength, nameBuffer)
    switch  osStatus {
    case  0:
      return  String.init (utf16CodeUnits: nameBuffer, count: nameLength[0])
    default:
      NSLog ("Code: 0x%04X  Status: %+i", scanCode, osStatus)
      return  nil
    }
  }
}

fileprivate extension String {
  func replacingOccurrences(of array: [StringLiteralType]) -> String {
    var newString = self
    for occurrence in array {
      newString = newString.replacingOccurrences(of: occurrence, with: "")
    }
    return newString
  }
}
