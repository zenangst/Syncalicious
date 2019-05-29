import Cocoa

class OperationFactory {
  let fileManager: FileManager
  let shellController: ShellController
  let workspace: NSWorkspace

  init(fileManager: FileManager = .default,
       shellController: ShellController,
       workspace: NSWorkspace = .shared) {
    self.fileManager = fileManager
    self.shellController = shellController
    self.workspace = workspace
  }

  func createQuitApplicationOperation(for application: Application, then handler: @escaping () -> Void) -> DispatchOperation {
    let operation = UIOperation({ [weak self] operation in
      guard let strongSelf = self else {
        operation.complete()
        return
      }
      strongSelf.workspace.runningApplication(for: application)?.terminate()
      let delay: TimeInterval = application.preferences.kind == .container ? 6.0 : 1.0

      DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
        guard strongSelf.workspace.runningApplication(for: application) == nil else {
          operation.cancelChildren()
          operation.cancel()
          return
        }
        operation.perform(#selector(CoreOperation.complete), with: nil, afterDelay: delay)
        operation.completionBlock = handler
      })
    })

    return operation
  }

  func createLaunchApplicationOperation(for application: Application, then handler: @escaping () -> Void) -> DispatchOperation {
    let operation = UIOperation({ [weak self] operation in
      guard let strongSelf = self else {
        operation.complete()
        return
      }
      strongSelf.workspace.launchApplication(withBundleIdentifier: application.propertyList.bundleIdentifier,
                                             options: [.withoutActivation],
                                             additionalEventParamDescriptor: nil,
                                             launchIdentifier: nil)
      operation.completionBlock = handler
      operation.complete()
    })

    return operation
  }

  func createKeyboardShortcutSync(for application: Application, machine: Machine,
                                  dictionary: [String: Any]?) -> DispatchOperation {
    return UtilityOperation { [weak self] operation in
      guard let strongSelf = self,
        let contents = NSMutableDictionary(contentsOfFile: application.preferences.url.path) else {
        operation.complete()
        return
      }
      contents.setValue(dictionary, forKey: PropertyListKey.keyEquivalents.rawValue)

      let customize = UserDefaults.standard.syncaliciousUrl!
        .appendingPathComponent(machine.name)
        .appendingPathComponent("Customize")
      try? strongSelf.fileManager.createFolderAtUrlIfNeeded(customize)
      let filePath = customize.appendingPathComponent(application.preferences.fileName)
      contents.write(to: filePath, atomically: true)
      Thread.sleep(until: Date() + 0.5)
      _ = try? strongSelf.fileManager.replaceItemAt(application.preferences.url, withItemAt: filePath)
      Thread.sleep(until: Date() + 0.5)
      operation.complete()
    }
  }

  func createReadPropertyListOperation(for application: Application) -> DispatchOperation {
    return UtilityOperation { [weak self] in
      self?.shellController.execute(command: "defaults read \(application.propertyList.bundleIdentifier)")
      $0.complete()
    }
  }

  func createSyncOperation(for application: Application, location: URL,
                           delay: TimeInterval = 1,
                           then handler: @escaping () -> Void) -> DispatchOperation {
    let operation = UtilityOperation({ [weak self] operation in
      guard let strongSelf = self else {
        operation.complete()
        return
      }

      _ = try? strongSelf.fileManager.replaceItemAt(application.preferences.url, withItemAt: location)
      try? strongSelf.fileManager.removeItem(at: location)
      operation.completionBlock = handler

      if delay > 0 {
        Thread.sleep(until: Date() + delay)
      }

      operation.complete()
    })
    return operation
  }
}
