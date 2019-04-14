import Cocoa

class SyncController: NSObject {
  let destination: URL
  let shellController = ShellController()
  let machine: Machine
  let fileManager: FileManager
  let workspace: NSWorkspace

  var applications = [Application]()
  var pendingApplications = Set<Application>()
  var observation: NSKeyValueObservation?

  init(destination: URL,
       fileManager: FileManager = .default,
       machine: Machine,
       workspace: NSWorkspace = .shared) {
    self.destination = destination
    self.fileManager = fileManager
    self.machine = machine
    self.workspace = workspace
    super.init()
    self.observation = workspace.observe(\.frontmostApplication, options: [.initial, .new]) { [weak self] _, _ in
      self?.frontmostApplicationDidChange()
    }
  }

  func applicationIsSynced(_ application: Application, on machine: Machine) -> Bool {
    let backup = destination
      .appendingPathComponent(machine.name)
      .appendingPathComponent("Backup")
      .appendingPathComponent(application.preferences.fileName)

    var isDirectory = ObjCBool(false)
    return fileManager.fileExists(atPath: backup.path, isDirectory: &isDirectory)
  }

  func enableSync(for application: Application, on machine: Machine) throws {
    try createMachineFolders(for: application, on: machine)
  }

  func disableSync(for application: Application, on machine: Machine) throws {
    let backup = destination
      .appendingPathComponent(machine.name)
      .appendingPathComponent("Backup")
      .appendingPathComponent(application.preferences.fileName)

    try fileManager.removeItem(at: backup)
  }

  private  func frontmostApplicationDidChange() {
    guard let runningApplication = workspace.frontmostApplication else { return }
    guard let application = applications
      .first(where: { $0.propertyList.bundleIdentifier == runningApplication.bundleIdentifier }) else {
      return
    }

    let backup = destination
      .appendingPathComponent("Sync")
      .appendingPathComponent(machine.name)
      .appendingPathComponent("Backup")
      .appendingPathComponent(application.preferences.fileName)

    var isDirectory = ObjCBool(false)
    let isSynced = FileManager.default.fileExists(atPath: backup.path, isDirectory: &isDirectory)

    if isSynced { pendingApplications.insert(application) }
    checkPendingApplications()
  }

  private func checkPendingApplications() {
    let runningApplications = NSWorkspace.shared.runningApplications
    let bundleIdentifiers = runningApplications.compactMap({ $0.bundleIdentifier })
    for application in pendingApplications where !bundleIdentifiers.contains(application.propertyList.bundleIdentifier) {
      try? checkSync(for: application)
    }

    try? checkPendingFolder()
  }

  private func checkSync(for application: Application) throws {
    let backup = destination.appendingPathComponent("Sync")
    let folders = try fileManager.contentsOfDirectory(at: backup,
                                                       includingPropertiesForKeys: [.isDirectoryKey],
                                                       options: [.skipsHiddenFiles])
      .filter({ !$0.absoluteString.contains( machine.name.lowercased() ) })

    for folder in folders {
      let pendingPath = folder.appendingPathComponent("Pending")
      try fileManager.createFolderAtUrlIfNeeded(pendingPath)
      let filePath = pendingPath.appendingPathComponent(application.preferences.fileName)
      try copyItemIfNeeded(from: application.preferences.path, to: filePath)
    }
  }

  // swiftlint:disable identifier_name
  private func copyItemIfNeeded(from: URL, to: URL) throws {
    if let lhs = NSDictionary.init(contentsOf: from),
      let rhs = NSDictionary.init(contentsOf: to) {
      if lhs !== rhs {
        try fileManager.removeItem(at: to)
        try fileManager.copyItem(at: from, to: to)
      }
    } else {
      try fileManager.copyItem(at: from, to: to)
    }
  }

  private func checkPendingFolder() throws {
    let runningApplications = workspace.runningApplications
    let bundleIdentifiers = runningApplications.compactMap({ $0.bundleIdentifier })
    let pending = destination
      .appendingPathComponent("Sync")
      .appendingPathComponent(machine.name)
      .appendingPathComponent("Pending")
    let files = try fileManager.contentsOfDirectory(at: pending,
                                                    includingPropertiesForKeys: [.isRegularFileKey],
                                                    options: [.skipsHiddenFiles])
    for file in files {
      guard let application = applications
        .first(where: { $0.preferences.fileName == file.lastPathComponent }),
        !bundleIdentifiers.contains(application.propertyList.bundleIdentifier)
      else {
          continue
      }

      let command = """
      defaults import \(application.preferences.path.path) "\(file.path)"
      """
      shellController.execute(command: command)
      try? fileManager.removeItem(at: file)
    }
  }

  private func createMachineFolders(for application: Application, on machine: Machine) throws {
    try createSyncBackup(for: application, on: machine)
    try createPendingFolder(for: application, on: machine)
  }

  private func createPendingFolder(for application: Application, on machine: Machine) throws  {
    let folder = destination
      .appendingPathComponent(machine.name)
      .appendingPathComponent("Pending")
    try fileManager.createFolderAtUrlIfNeeded(folder)
  }

  private func createSyncBackup(for application: Application, on machine: Machine) throws {
    var from = application.preferences.path
    from.resolveSymlinksInPath()

    let folder = destination
      .appendingPathComponent(machine.name)
      .appendingPathComponent("Backup")

    try fileManager.createFolderAtUrlIfNeeded(folder)
    let toDestination = folder
      .appendingPathComponent(from.lastPathComponent)

    // This should probably not be optional?
    try? fileManager.copyItem(at: from, to: toDestination)
  }
}
