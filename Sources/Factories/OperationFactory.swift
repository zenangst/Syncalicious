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

  func createQuitApplicationOperation(for application: Application) -> DispatchOperation {
    let operation = UIOperation({ [weak self] operation in
      guard let strongSelf = self else {
        operation.finish(true)
        return
      }
      strongSelf.workspace.runningApplication(for: application)?.terminate()
      operation.perform(#selector(CoreOperation.complete), with: nil, afterDelay: 0.5)
    })

    return operation
  }

  func createLaunchApplicationOperation(for application: Application) -> DispatchOperation {
    let operation = UIOperation({ [weak self] operation in
      guard let strongSelf = self else {
        operation.finish(true)
        return
      }
      strongSelf.workspace.launchApplication(withBundleIdentifier: application.propertyList.bundleIdentifier,
                                             options: [.withoutActivation],
                                             additionalEventParamDescriptor: nil,
                                             launchIdentifier: nil)
      operation.finish(true)
    })

    return operation
  }

  func createSyncOperation(for application: Application, location: URL,
                           runningApplication: NSRunningApplication?,
                           then handler: @escaping () -> Void) -> DispatchOperation {
    let operation = UtilityOperation({ [weak self] operation in
      guard let strongSelf = self else {
        operation.finish(true)
        return
      }

      runningApplication?.terminate()

      _ = try? strongSelf.fileManager.replaceItemAt(application.preferences.url, withItemAt: location)

      if runningApplication != nil {
        // Wait until the copy process is done.
        Thread.sleep(until: Date() + 1)
      }

      strongSelf.shellController.execute(command: "defaults read \(application.propertyList.bundleIdentifier)")
      try? strongSelf.fileManager.removeItem(at: location)
      handler()
      debugPrint("🍫 Synced \(application.propertyList.bundleName)")
      operation.finish(true)
    })
    return operation
  }
}
