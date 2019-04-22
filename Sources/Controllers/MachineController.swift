import Foundation

protocol MachineControllerDelegate: class {
  func machineController(_ controller: MachineController,
                         didChangeState state: MachineController.State)
}

enum MachineError: Error {
  case unableToResolveName
  case unableToResolveLocalizedName
}

class MachineController {
  weak var delegate: MachineControllerDelegate?

  enum State {
    case active
    case idle
  }

  let machine: Machine
  var threshold: Double = 60
  var timer: Timer?
  private(set) var state: State = .active

  public init(host: Host) throws {
    guard let name = host.name else {
      throw MachineError.unableToResolveName
    }

    guard let localizedName = host.localizedName else {
      throw MachineError.unableToResolveLocalizedName
    }

    self.machine = Machine(name: name,
                           localizedName: localizedName)

    let timer = Timer.init(timeInterval: 30.0, repeats: true, block: { [weak self] _ in
      self?.checkIdleState()
    })
    RunLoop.current.add(timer, forMode: .common)
    self.timer = timer
  }

  func createMachineBackupDestinationIfNeeded(at destination: URL) throws {
    let url = machineBackupDestination(for: destination)
    if !FileManager.default.fileExists(atPath: url.path) {
      try FileManager.default.createDirectory(at: url,
                                              withIntermediateDirectories: true,
                                              attributes: nil)
    }
  }

  func machineBackupDestination(for destination: URL) -> URL {
    return destination.appendingPathComponent(machine.name)
  }

  // Implementation is based of this gist.
  // https://gist.github.com/darrarski/c586ce379d3e7e91a57d89ed557192ec
  private func systemIdleTime() -> Double? {
    var iterator: io_iterator_t = 0
    defer { IOObjectRelease(iterator) }
    guard IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching("IOHIDSystem"), &iterator) == KERN_SUCCESS else {
      return nil }

    let entry: io_registry_entry_t = IOIteratorNext(iterator)
    defer { IOObjectRelease(entry) }
    guard entry != 0 else { return nil }

    var unmanagedDict: Unmanaged<CFMutableDictionary>?
    defer { unmanagedDict?.release() }
    guard IORegistryEntryCreateCFProperties(entry, &unmanagedDict, kCFAllocatorDefault, 0) == KERN_SUCCESS,
      let dict = unmanagedDict?.takeUnretainedValue() else { return nil }

    let key: CFString = "HIDIdleTime" as CFString
    let value = CFDictionaryGetValue(dict, Unmanaged.passUnretained(key).toOpaque())
    let number: CFNumber = unsafeBitCast(value, to: CFNumber.self)
    var nanoseconds: Int64 = 0
    guard CFNumberGetValue(number, CFNumberType.sInt64Type, &nanoseconds) else { return nil }
    return Double(nanoseconds) / Double(NSEC_PER_SEC)
  }

  private func checkIdleState() {
    let idleTime = systemIdleTime() ?? 0
    let state: State = idleTime > threshold ? .idle : .active
    self.state = state
    delegate?.machineController(self, didChangeState: state)
  }
}
