import Foundation

protocol MachineControllerDelegate: class {
  func machineController(_ controller: MachineController,
                         didChangeState state: Machine.State)
  func machineController(_ controller: MachineController,
                         didUpdateOtherMachines machines: [Machine])
}

enum MachineError: Error {
  case resolveNameFailed
  case resolveLocalizedNameFailed
  case machineEncodingFailed
}

class MachineController {
  weak var delegate: MachineControllerDelegate?

  let decoder = JSONDecoder()
  let encoder = JSONEncoder()
  let fileManager: FileManager
  let iconController: IconController
  private(set) var machine: Machine
  var otherMachines = [Machine]()
  var threshold: Double = 60
  var timer: Timer?

  public init(fileManager: FileManager = .default,
              host: Host,
              iconController: IconController) throws {
    self.fileManager = fileManager
    self.iconController = iconController
    guard let name = host.name else {
      throw MachineError.resolveNameFailed
    }

    guard let localizedName = host.localizedName else {
      throw MachineError.resolveLocalizedNameFailed
    }

    self.machine = Machine(name: name, localizedName: localizedName, state: .active)

    let timer = Timer.init(timeInterval: 30.0, repeats: true, block: { [weak self] _ in
      guard self?.checkIdleState() == .active else { return }
      try? self?.refreshMachines()
    })
    RunLoop.current.add(timer, forMode: .common)
    self.timer = timer
  }

  // MARK: - Public methods

  func createMachineInfoDestination(at destination: URL) throws {
    let infoDestination = machineInfoDestination(for: destination)
    let computerInfoUrl = machineInfoDestination(for: destination, fileName: "Computer.plist")
    let iconUrl = machineInfoDestination(for: destination, fileName: "Computer.tiff")
    let computerIcon = iconController.computerIcon()

    try fileManager.createFolderAtUrlIfNeeded(infoDestination)
    try iconController.saveImage(computerIcon, to: iconUrl)
    try updateMachineInfoPlist(to: computerInfoUrl)
  }

  func updateMachineInfoPlist(to url: URL) throws {
    let data = try encoder.encode(machine)
    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
    guard let dictionary = json as? NSDictionary else {
      throw MachineError.machineEncodingFailed
    }
    try dictionary.write(to: url)
  }

  func applicationWillTerminate() {
    guard let syncaliciousUrl = UserDefaults.standard.syncaliciousUrl else {
      return
    }
    let computerInfoUrl = machineInfoDestination(for: syncaliciousUrl, fileName: "Computer.plist")
    machine.state = .turnedOff
    try? updateMachineInfoPlist(to: computerInfoUrl)
  }

  func createMachineBackupDestinationIfNeeded(at destination: URL) throws {
    let url = machineBackupDestination(for: destination, on: machine)
    if !FileManager.default.fileExists(atPath: url.path) {
      try FileManager.default.createDirectory(at: url,
                                              withIntermediateDirectories: true,
                                              attributes: nil)
    }
  }

  func machineInfoDestination(for destination: URL, fileName: String? = nil) -> URL {
    let url = machineBackupDestination(for: destination, on: machine).appendingPathComponent("Info")
    if let fileName = fileName {
      return url.appendingPathComponent(fileName)
    }
    return url
  }

  func machineBackupDestination(for destination: URL, on machine: Machine) -> URL {
    return destination.appendingPathComponent(machine.name)
  }

  func refreshMachines() throws {
    guard let syncaliciousUrl = UserDefaults.standard.syncaliciousUrl else {
      return
    }

    let folders = try fileManager.contentsOfDirectory(at: syncaliciousUrl,
                                                      includingPropertiesForKeys: [.isDirectoryKey],
                                                      options: [.skipsHiddenFiles])
    var machines = [Machine]()
    for folder in folders {
      let plistUrl = folder.appendingPathComponent("Info")
        .appendingPathComponent("Computer.plist")

      guard fileManager.fileExists(atPath: plistUrl.path) else { continue }
      guard let dictionary = NSDictionary.init(contentsOf: plistUrl) else { continue }
      guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: .sortedKeys) else { continue }
      guard let machine = try? decoder.decode(Machine.self, from: data) else { continue }

      if self.machine.name != machine.name {
        machines.append(machine)
      }
    }

    otherMachines = machines
    delegate?.machineController(self, didUpdateOtherMachines: otherMachines)
  }

  // MARK: - Private methods

  // Implementation is based of this gist.
  // https://gist.github.com/darrarski/c586ce379d3e7e91a57d89ed557192ec
  private func systemIdleTime() -> Double? {
    var iterator: io_iterator_t = 0
    defer { IOObjectRelease(iterator) }
    guard IOServiceGetMatchingServices(kIOMasterPortDefault,
                                       IOServiceMatching("IOHIDSystem"),
                                       &iterator) == KERN_SUCCESS else {
      return nil
    }

    let entry: io_registry_entry_t = IOIteratorNext(iterator)
    defer { IOObjectRelease(entry) }
    guard entry != 0 else {
      return nil
    }

    var unmanagedDict: Unmanaged<CFMutableDictionary>?
    defer { unmanagedDict?.release() }
    guard IORegistryEntryCreateCFProperties(entry, &unmanagedDict, kCFAllocatorDefault, 0) == KERN_SUCCESS,
      let dict = unmanagedDict?.takeUnretainedValue() else {
        return nil
    }

    let key: CFString = "HIDIdleTime" as CFString
    let value = CFDictionaryGetValue(dict, Unmanaged.passUnretained(key).toOpaque())
    let number: CFNumber = unsafeBitCast(value, to: CFNumber.self)
    var nanoseconds: Int64 = 0

    guard CFNumberGetValue(number, CFNumberType.sInt64Type, &nanoseconds) else {
      return nil
    }

    return Double(nanoseconds) / Double(NSEC_PER_SEC)
  }

  @discardableResult
  private func checkIdleState() -> Machine.State {
    let idleTime = systemIdleTime() ?? 0
    let state: Machine.State = idleTime > threshold ? .idle : .active

    if let syncaliciousUrl = UserDefaults.standard.syncaliciousUrl, machine.state != state {
      machine.state = state
      try? updateMachineInfoPlist(to: syncaliciousUrl)
      delegate?.machineController(self, didChangeState: state)
    }

    return state
  }
}
