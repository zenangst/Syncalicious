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

// swiftlint:disable type_body_length
class SyncController: NSObject {
  let operationController: OperationController
  let destination: URL
  let applicationController: ApplicationController
  let shellController: ShellController
  let machineController: MachineController
  let operationFactory: OperationFactory
  let fileManager: FileManager
  let workspace: NSWorkspace
  let notificationController: NotificationController

  var applications = [Application]()
  var applicationHasBeenActive = Set<Application>()
  var pendingApplications = Set<Application>()
  var plistHashDictionary = [Application: NSDictionary]()
  var observation: NSKeyValueObservation?

  init(destination: URL,
       fileManager: FileManager = .default,
       applicationController: ApplicationController,
       machineController: MachineController,
       operationController: OperationController,
       operationFactory: OperationFactory,
       shellController: ShellController,
       notificationController: NotificationController,
       workspace: NSWorkspace = .shared) {
    self.applicationController = applicationController
    self.destination = destination
    self.fileManager = fileManager
    self.machineController = machineController
    self.operationController = operationController
    self.operationFactory = operationFactory
    self.shellController = shellController
    self.notificationController = notificationController
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

      let query: (NSRunningApplication) -> Bool = { $0.bundleIdentifier == application.propertyList.bundleIdentifier }
      let runningApplication = workspace.runningApplications.first(where: query)
      let syncOperation = operationFactory.createSyncOperation(for: application,
                                                               location: fileUrl,
                                                               then: { [weak self] in
                                                                self?.updateBadgeCounter()
                                                                self?.notificationController.post(application: application,
                                                                                                  text: "Application synced")
      })
      let readPropertyListOperation = operationFactory.createReadPropertyListOperation(for: application)

      if runningApplication != nil {
        let quitOperation = operationFactory.createQuitApplicationOperation(for: application) { [weak self] in
          self?.notificationController.post(application: application, text: "Quit \(application.propertyList.bundleName)")
        }
        let restartOperation = operationFactory.createLaunchApplicationOperation(for: application) { [weak self] in
          self?.notificationController.post(application: application, text: "Restarted \(application.propertyList.bundleName)")
        }

        syncOperation.addDependency(quitOperation)
        readPropertyListOperation.addDependency(syncOperation)
        restartOperation.addDependency(readPropertyListOperation)

        operationController.add(quitOperation)
        operationController.add(readPropertyListOperation)
        operationController.add(syncOperation)
        operationController.add(restartOperation)
      } else {
        readPropertyListOperation.addDependency(syncOperation)

        operationController.add(syncOperation)
        operationController.add(readPropertyListOperation)
      }
    }

    operationController.execute()
  }

  // MARK: - Observers

  @objc func mainWindowDidBecomeKey() {
    perform(#selector(updateBadgeCounter), with: nil, afterDelay: 1.0)
  }

  // MARK: - Private methods

  @objc private func updateBadgeCounter() {
    DispatchQueue.main.async { [weak self] in
      guard let strongSelf = self else { return }
      if let files = try? strongSelf.pendingFiles(), !files.isEmpty {
        NSApplication.shared.dockTile.badgeLabel = "\(files.count)"
      } else {
        NSApplication.shared.dockTile.badgeLabel = nil
      }
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

    var processedApplications = Set<Application>()

    for folder in folders {
      let backupPath = folder.appendingPathComponent("Backup")
        .appendingPathComponent(application.preferences.fileName)
      var isDictionary = ObjCBool(false)
      let shouldAddToPending = fileManager.fileExists(atPath: backupPath.path, isDirectory: &isDictionary)

      guard shouldAddToPending else { continue }

      let pendingPath = folder.appendingPathComponent("Pending")
      try fileManager.createFolderAtUrlIfNeeded(pendingPath)
      let filePath = pendingPath.appendingPathComponent(application.preferences.fileName)
      if let application = try copyApplicationIfNeeded(application, to: filePath, machineFolder: folder.lastPathComponent) {
        processedApplications.insert(application)
      }
    }

    for application in processedApplications {
      applicationHasBeenActive.remove(application)
    }
  }

  // swiftlint:disable identifier_name
  private func copyApplicationIfNeeded(_ application: Application, to: URL, machineFolder: String) throws -> Application? {
    guard applicationHasBeenActive.contains(application) && machineController.machine.state == .active else { return nil }

    let initialDictionary = plistHashDictionary[application]
    var applicationPath = application.preferences.url
    applicationPath.resolveSymlinksInPath()

    if let lhs = NSDictionary.init(contentsOf: application.preferences.url),
      let rhs = NSDictionary.init(contentsOf: to) {
      let listsAreEqual = lhs.isEqual(to: rhs)

      if !listsAreEqual {
        pendingApplications.remove(application)
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
    } else {
      debugPrint("🍫 Nothing changed \(application.propertyList.bundleName)")
    }

    return application
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

      let syncOperation = operationFactory.createSyncOperation(for: application,
                                                           location: file,
                                                           then: { [weak self] in
                                                            debugPrint("🍫 Synced \(application.propertyList.bundleName)")
                                                            self?.notificationController.post(application: application,
                                                                                              text: "Application synced")
                                                            self?.updateBadgeCounter()
      })
      let readPropertyListOperation = operationFactory.createReadPropertyListOperation(for: application)
      operationController.add(syncOperation, readPropertyListOperation)
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
