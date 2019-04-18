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
  let shellController: ShellController
  var threshold: Float = 5
  var timer: Timer?

  public init(host: Host, shellController: ShellController) throws {
    self.shellController = shellController
    guard let name = host.name else {
      throw MachineError.unableToResolveName
    }

    guard let localizedName = host.localizedName else {
      throw MachineError.unableToResolveLocalizedName
    }

    self.machine = Machine(name: name,
                           localizedName: localizedName)

    let timer = Timer.init(timeInterval: 5.0, repeats: true, block: { [weak self] _ in
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

  private func checkIdleState() {
    let command = """
  ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print $NF/1000000000; exit}'
"""

    guard let output = Float(shellController.execute(command: command)) else { return }
    let state: State = output > threshold ? .idle : .active

    delegate?.machineController(self, didChangeState: state)
  }
}
