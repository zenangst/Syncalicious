import Cocoa

class TargetApplication: NSObject {
  let application: Application
  let pendingUrl: URL
  let runningApplication: NSRunningApplication

  init(application: Application,
       pendingUrl: URL,
       runningApplication: NSRunningApplication) {
    self.application = application
    self.pendingUrl = pendingUrl
    self.runningApplication = runningApplication
    super.init()
  }
}

class SyncController: NSObject {
  let operationController = OperationController<DispatchOperation>()
  let destination: URL
  let shellController: ShellController
  let machineController: MachineController
  let fileManager: FileManager
  let workspace: NSWorkspace

  var applications = [Application]()
  var applicationHasBeenActive = Set<Application>()
  var pendingApplications = Set<Application>()
  var plistHashDictionary = [Application: NSDictionary]()
  var observation: NSKeyValueObservation?

  init(destination: URL,
       fileManager: FileManager = .default,
       machineController: MachineController,
       shellController: ShellController,
       workspace: NSWorkspace = .shared) {
    self.destination = destination
    self.fileManager = fileManager
    self.machineController = machineController
    self.shellController = shellController
    self.workspace = workspace
    super.init()
    self.observation = workspace.observe(\.frontmostApplication, options: [.initial, .new]) { [weak self] _, _ in
      self?.frontmostApplicationDidChange()
    }

    NotificationCenter.default.addObserver(self,
                                           selector: #selector(mainWindowDidBecomeKey),
                                           name: MainWindowNotification.becomeKey.notificationName,
                                           object: nil)
  }

  // MARK: - Public methods

  func applicationIsSynced(_ application: Application, on machine: Machine) -> Bool {
    let backup = destination
      .appendingPathComponent(machine.name)
      .appendingPathComponent("Backup")
      .appendingPathComponent(application.preferences.fileName)

    var isDirectory = ObjCBool(false)
    return fileManager.fileExists(atPath: backup.path, isDirectory: &isDirectory)
  }

  func applicationLastSynced(_ application: Application) -> Date? {
    var from = application.preferences.url
    from.resolveSymlinksInPath()

    var isDirectory = ObjCBool(false)
    guard fileManager.fileExists(atPath: from.path, isDirectory: &isDirectory) else {
      return nil
    }

    let dictionary = try? fileManager.attributesOfItem(atPath: from.path) as NSDictionary
    return dictionary?.fileModificationDate()
  }

  func enableSync(for application: Application, on machine: Machine) throws {
    try createMachineFolders(for: application, on: machine)
    pendingApplications.insert(application)
  }

  func disableSync(for application: Application, on machine: Machine) throws {
    let backup = destination
      .appendingPathComponent(machineController.machine.name)
      .appendingPathComponent("Backup")
      .appendingPathComponent(application.preferences.fileName)
    try fileManager.removeItem(at: backup)
    pendingApplications.remove(application)
  }

  func machineDidChangeState(newState state: Machine.State) {
    guard state == .idle, !operationController.isExecuting else { return }

    let pending = destination
      .appendingPathComponent(machineController.machine.name)
      .appendingPathComponent("Pending")
    guard let files = try? fileManager.contentsOfDirectory(at: pending,
                                                           includingPropertiesForKeys: [.isRegularFileKey],
                                                           options: [.skipsHiddenFiles]) else {
                                                            return
    }

    for fileUrl in files {
      guard let application = applications.first(where: { $0.preferences.fileName == fileUrl.lastPathComponent }) else {
        continue
      }

      let query: (NSRunningApplication) -> Bool = {
        return $0.bundleIdentifier == application.propertyList.bundleIdentifier
      }

      let runningApplication = workspace.runningApplications.first(where: query)
      let syncOperation = createSyncOperation(for: application,
                                          location: fileUrl,
                                          runningApplication: runningApplication)
      if runningApplication != nil {
        let restartOperation = createRestartOperation(for: application)
        restartOperation.addDependency(syncOperation)
        operationController.add(restartOperation)
      }

      operationController.add(syncOperation)
    }

    operationController.execute()
  }

  // MARK: - Observers

  @objc func mainWindowDidBecomeKey() {
    perform(#selector(updateBadgeCounter), with: nil, afterDelay: 1.0)
  }

  // MARK: - Private methods

  func createRestartOperation(for application: Application) -> DispatchOperation {
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

  func createSyncOperation(for application: Application,
                           location: URL,
                           runningApplication: NSRunningApplication?) -> DispatchOperation {
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
      strongSelf.updateBadgeCounter()
      debugPrint("🍫 Synced \(application.propertyList.bundleName)")
      operation.finish(true)
    })
    return operation
  }

  @objc private func updateBadgeCounter() {
    if let files = try? pendingFiles(), !files.isEmpty {
      NSApplication.shared.dockTile.badgeLabel = "\(files.count)"
    } else {
      NSApplication.shared.dockTile.badgeLabel = nil
    }
  }

  private func frontmostApplicationDidChange() {
    guard let runningApplication = workspace.frontmostApplication else { return }
    guard let application = applications
      .first(where: { $0.propertyList.bundleIdentifier == runningApplication.bundleIdentifier }) else {
      return
    }

    let backup = destination
      .appendingPathComponent(machineController.machine.name)
      .appendingPathComponent("Backup")
      .appendingPathComponent(application.preferences.fileName)

    checkSyncedApplication(application, backupDestination: backup)
    checkSyncAndPendingFolder()
  }

  private func checkSyncedApplication(_ application: Application, backupDestination: URL) {
    var isDirectory = ObjCBool(false)
    let isSynced = FileManager.default.fileExists(atPath: backupDestination.path, isDirectory: &isDirectory)

    if isSynced {
      if let dictionary = NSDictionary.init(contentsOf: application.preferences.url) {
        plistHashDictionary[application] = dictionary
      }
      pendingApplications.insert(application)
    }
  }

  private func checkSyncAndPendingFolder() {
    for application in pendingApplications {
      if application.propertyList.bundleIdentifier == workspace.frontmostApplication?.bundleIdentifier {
        applicationHasBeenActive.insert(application)
      } else {
        try? checkSync(for: application)
      }
    }

    try? checkPendingFolder()
  }

  private func checkSync(for application: Application) throws {
    let folders = try fileManager.contentsOfDirectory(at: destination,
                                                       includingPropertiesForKeys: [.isDirectoryKey],
                                                       options: [.skipsHiddenFiles])
      .filter({ !$0.absoluteString.contains( machineController.machine.name.lowercased() ) })

    for folder in folders {
      let backupPath = folder.appendingPathComponent("Backup")
        .appendingPathComponent(application.preferences.fileName)
      var isDictionary = ObjCBool(false)
      let shouldAddToPending = fileManager.fileExists(atPath: backupPath.path, isDirectory: &isDictionary)

      guard shouldAddToPending else { continue }

      let pendingPath = folder.appendingPathComponent("Pending")
      try fileManager.createFolderAtUrlIfNeeded(pendingPath)
      let filePath = pendingPath.appendingPathComponent(application.preferences.fileName)
      try copyApplicationIfNeeded(application, to: filePath, machineFolder: folder.lastPathComponent)
    }
  }

  // swiftlint:disable identifier_name
  private func copyApplicationIfNeeded(_ application: Application, to: URL, machineFolder: String) throws {
    guard applicationHasBeenActive.contains(application) && machineController.machine.state == .active else { return }

    let initialDictionary = plistHashDictionary[application]
    var applicationPath = application.preferences.url
    applicationPath.resolveSymlinksInPath()

    if let lhs = NSDictionary.init(contentsOf: application.preferences.url),
      let rhs = NSDictionary.init(contentsOf: to) {
      let listsAreEqual = lhs.isEqual(to: rhs)

      if !listsAreEqual {
        try? fileManager.removeItem(at: to)
        try? fileManager.copyItem(at: applicationPath, to: to)
        debugPrint("🍫 Added \(application.propertyList.bundleName) to \(machineFolder) (pending).")
      }
    } else if let dictionary = NSDictionary.init(contentsOf: application.preferences.url),
      let initialDictionary = initialDictionary, initialDictionary !== dictionary {
      pendingApplications.remove(application)
      plistHashDictionary[application] = nil
      try? fileManager.copyItem(at: applicationPath, to: to)
      debugPrint("🍫 Added \(application.propertyList.bundleName) to \(machineFolder) (pending).")
    }

    applicationHasBeenActive.remove(application)
  }

  private func pendingFiles() throws -> [URL] {
    let pending = destination
      .appendingPathComponent(machineController.machine.name)
      .appendingPathComponent("Pending")

    let files = try fileManager.contentsOfDirectory(at: pending,
                                                    includingPropertiesForKeys: [.isRegularFileKey],
                                                    options: [.skipsHiddenFiles])
    return files
  }

  private func checkPendingFolder() throws {
    guard !operationController.isExecuting else { return }
    let runningApplications = workspace.runningApplications
    let bundleIdentifiers = runningApplications.compactMap({ $0.bundleIdentifier })
    let files = try pendingFiles()

    for file in files {
      guard let application = applications
        .first(where: { $0.preferences.fileName == file.lastPathComponent }),
        !bundleIdentifiers.contains(application.propertyList.bundleIdentifier)
      else {
          continue
      }

      let operation = createSyncOperation(for: application,
                                      location: file,
                                      runningApplication: nil)
      operationController.add(operation)
    }
    operationController.execute()
  }

  private func createMachineFolders(for application: Application, on machine: Machine) throws {
    try createSyncBackup(for: application, on: machine)
    try createPendingFolder(for: application, on: machine)
  }

  private func createPendingFolder(for application: Application, on machine: Machine) throws {
    let folder = destination
      .appendingPathComponent(machineController.machine.name)
      .appendingPathComponent("Pending")
    try fileManager.createFolderAtUrlIfNeeded(folder)
  }

  private func createSyncBackup(for application: Application, on machine: Machine) throws {
    var from = application.preferences.url
    from.resolveSymlinksInPath()

    let folder = destination
      .appendingPathComponent(machineController.machine.name)
      .appendingPathComponent("Backup")

    try fileManager.createFolderAtUrlIfNeeded(folder)
    let toDestination = folder
      .appendingPathComponent(from.lastPathComponent)

    // This should probably not be optional?
    try? fileManager.copyItem(at: from, to: toDestination)
  }
}
