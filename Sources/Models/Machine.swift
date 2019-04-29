import Foundation

struct Machine: Codable, Hashable {
  enum State: String, Codable, Hashable {
    case active
    case idle
    case turnedOff = "Turned off"
  }

  let name: String
  let localizedName: String
  var state: State

  init(name: String, localizedName: String, state: State) {
    self.name = name
    self.localizedName = localizedName
    self.state = state
  }
}
