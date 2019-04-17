import Cocoa

protocol IdleControllerDelegate: class {
  func idleController(_ controller: IdleController, didChangeState state: IdleController.State)
}

class IdleController {
  weak var delegate: IdleControllerDelegate?

  enum State {
    case active
    case idle
  }

  let shellController = ShellController()
  var threshold: Float = 5
  var timer: Timer?

  init() {
    let timer = Timer.init(timeInterval: 5.0, repeats: true, block: { [weak self] _ in
      self?.checkIdleState()
    })
    RunLoop.current.add(timer, forMode: .common)
    self.timer = timer
  }

  private func checkIdleState() {
    let command = """
  ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print $NF/1000000000; exit}'
"""

    guard let output = Float(shellController.execute(command: command)) else { return }
    let state: State = output > threshold ? .idle : .active
    delegate?.idleController(self, didChangeState: state)
  }
}
