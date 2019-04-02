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

  func machineBackupDestination(for destination: URL) -> URL {
    return destination.appendingPathComponent(machine.name)
  }
}
