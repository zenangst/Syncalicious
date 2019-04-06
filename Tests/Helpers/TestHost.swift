import Foundation

class TestHost: Host {
  let machineName: String

  override var name: String { return machineName + ".local" }
  override var localizedName: String { return machineName }

  required init(machineName: String) {
    self.machineName = machineName
    super.init()
  }
}
