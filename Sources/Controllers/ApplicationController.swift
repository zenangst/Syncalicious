import Cocoa

protocol ApplicationControllerDelegate: class {
  func applicationController(_ controller: ApplicationController, didLoadApplications applications: [Application])
}

class ApplicationController {
  weak var delegate: ApplicationControllerDelegate?

  private let preferencesController: PreferencesController
  private let shellController: ShellController
  private let infoPlistController: InfoPropertyListController
  private let operationController: OperationController
  private let operationFactory: OperationFactory
  let workspace: NSWorkspace
  let SIPIsEnabled: Bool
  var queue: DispatchQueue?

  init(queue: DispatchQueue? = nil,
       infoPlistController: InfoPropertyListController,
       operationController: OperationController,
       operationFactory: OperationFactory,
       preferencesController: PreferencesController,
       shellController: ShellController,
       workspace: NSWorkspace = .shared) {
    self.infoPlistController = infoPlistController
    self.operationController = operationController
    self.operationFactory = operationFactory
    self.preferencesController = preferencesController
    self.shellController = shellController
    self.SIPIsEnabled = shellController.execute(command: "csrutil status").contains("enabled")
    self.workspace = workspace
  }

  // MARK: - Public methods

  func loadApplications(at locations: [URL]) {
    dispatchIfNeeded(on: queue, handler: { [weak self] in self?.runAsync(locations) })
  }

  func applicationDirectories() throws -> [URL] {
    let userDirectory = try FileManager.default.url(for: .applicationDirectory,
                                                    in: .userDomainMask,
                                                    appropriateFor: nil,
                                                    create: false)
    let applicationDirectory = try FileManager.default.url(for: .allApplicationsDirectory,
                                                           in: .localDomainMask,
                                                           appropriateFor: nil,
                                                           create: false)

    return [userDirectory, applicationDirectory]
  }

  func restart(application: Application, operations: [DispatchOperation] = []) {
    let quitOperation = operationFactory.createQuitApplicationOperation(for: application)
    let launchOperation = operationFactory.createLaunchApplicationOperation(for: application)
    var collection = [DispatchOperation]()

    collection.append(quitOperation)
    collection.append(contentsOf: operations)
    collection.append(launchOperation)

    launchOperation.addDependency(quitOperation)
    operationController.execute(collection)
  }

  // MARK: - Private methods

  private func dispatchIfNeeded(on queue: DispatchQueue?, handler: @escaping () -> Void) {
    if let queue = queue {
      queue.async(execute: handler)
    } else {
      handler()
    }
  }

  private func dispatchToMainIfNeeded(_ handler: @escaping () -> Void) {
    if queue != nil {
      DispatchQueue.main.async(execute: handler)
    } else {
      handler()
    }
  }

  private func runAsync(_ locations: [URL]) {
    var applications = [Application]()
    for location in locations {
      let urls = recursiveApplicationParse(at: location)
      applications.append(contentsOf: loadApplications(urls))
    }

    dispatchToMainIfNeeded { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.delegate?.applicationController(strongSelf, didLoadApplications: applications)
    }
  }

  private func recursiveApplicationParse(at url: URL) -> [URL] {
    var result = [URL]()
    var isDirectory: ObjCBool = true
    guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory),
      let contents = try? FileManager.default.contentsOfDirectory(at: url,
                                                                  includingPropertiesForKeys: nil,
                                                                  options: .skipsHiddenFiles) else { return [] }
    for file in contents {
      var isDirectory: ObjCBool = true
      let isFolder = FileManager.default.fileExists(atPath: file.path, isDirectory: &isDirectory)
      if isFolder && file.pathExtension != "app" && url.path.contains("/Applications") {
        result.append(contentsOf: recursiveApplicationParse(at: file))
      } else {
        result.append(file)
      }
    }

    return result
  }

  private func loadApplications(_ urls: [URL]) -> [Application] {
    var applications = [Application]()
    var bundleIdentifiers = [String]()
    for path in urls {
      do {
        let application = try loadApplication(at: path)
        if !bundleIdentifiers.contains(application.propertyList.bundleIdentifier) {
          applications.append(application)
          bundleIdentifiers.append(application.propertyList.bundleIdentifier)
        }
      } catch {}
    }
    return applications
  }

  private func loadApplication(at url: URL) throws -> Application {
    let infoPath = url.appendingPathComponent("Contents/Info.plist")
    let propertyList = try infoPlistController.load(at: infoPath)
    let preferences = try preferencesController.load(propertyList)
    let needsFullDiskAccess = SIPIsEnabled &&
      FileManager.default.fileExists(atPath: preferences.url.path) &&
      NSDictionary.init(contentsOfFile: preferences.url.path) == nil

    let application = Application(url: url,
                                  propertyList: propertyList,
                                  preferences: preferences,
                                  needsFullDiskAccess: needsFullDiskAccess)
    return application
  }
}
