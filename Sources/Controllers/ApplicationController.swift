import Cocoa

protocol ApplicationControllerDelegate: class {
  func applicationController(_ controller: ApplicationController, didLoadApplications applications: [Application])
}

class ApplicationController {
  weak var delegate: ApplicationControllerDelegate?

  private lazy var preferencesController = PreferencesController()
  private lazy var infoPlistController = InfoPropertyListController()
  private lazy var queue: DispatchQueue = { return DispatchQueue(label: String(describing: self),
                                                                 qos: .userInitiated) }()

  // MARK: - Public methods

  func loadApplications(at locations: [URL]) {
    queue.async(execute: { [weak self] in self?.runAsync(locations) })
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

  // MARK: - Private methods

  private func runAsync(_ locations: [URL]) {
    do {
      var applications = [Application]()
      for location in locations {
        let urls = recursiveApplicationParse(at: location)
        applications.append(contentsOf: loadApplications(urls))
      }
      DispatchQueue.main.async { [weak self] in
        guard let strongSelf = self else { return }
        strongSelf.delegate?.applicationController(strongSelf, didLoadApplications: applications)
      }
    } catch {}
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
    for path in urls {
      do {
        let application = try loadApplication(at: path)
        applications.append(application)
      } catch {}
    }
    return applications
  }

  private func loadApplication(at path: URL) throws -> Application {
    let infoPath = path.appendingPathComponent("Contents/Info.plist")
    let propertyList = try infoPlistController.load(at: infoPath)
    let preferences = try preferencesController.load(propertyList)
    let application = Application(path: path,
                                  propertyList: propertyList,
                                  preferences: preferences)
    return application
  }
}
