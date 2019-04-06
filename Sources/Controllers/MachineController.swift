import Foundation

enum MachineError: Error {
  case unableToResolveName
  case unableToResolveLocalizedName
}

class MachineController {
  let machine: Machine

  public init(host: Host) throws {
    guard let name = host.name else {
      throw MachineError.unableToResolveName
    }

    guard let localizedName = host.localizedName else {
      throw MachineError.unableToResolveLocalizedName
    }

    self.machine = Machine(name: name,
                           localizedName: localizedName)
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
}
