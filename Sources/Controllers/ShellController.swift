import Foundation

class ShellController {
  @discardableResult func execute(command: String,
                                  arguments: [String] = [],
                                  at path: String = ".") -> String {
    let process = Process()
    let path = path.replacingOccurrences(of: " ", with: "\\ ")
    let arguments = arguments.joined(separator: " ")
    let command = "cd \(path) && \(command) \(arguments)"
    return process.shell(command: command)
  }
}

extension Process {
  public func shell(command: String) -> String {
    let outputPipe = Pipe()
    let errorPipe = Pipe()

    launchPath = "/bin/bash"
    arguments = ["-c", command]
    standardOutput = outputPipe
    standardError = errorPipe

    var result = Data()
    var error = Data()

    outputPipe.fileHandleForReading.readabilityHandler = { handler in
      result.append(handler.availableData)
    }

    errorPipe.fileHandleForReading.readabilityHandler = { handler in
      error.append(handler.availableData)
    }

    launch()
    waitUntilExit()

    outputPipe.fileHandleForReading.readabilityHandler = nil
    errorPipe.fileHandleForReading.readabilityHandler = nil

    return result.string()
  }
}

fileprivate extension Data {
  func string() -> String {
    guard let output = String(data: self, encoding: .utf8) else { return "" }

    guard !output.hasSuffix("\n") else {
      let endIndex = output.index(before: output.endIndex)
      return String(output[..<endIndex])
    }

    return output

  }
}
