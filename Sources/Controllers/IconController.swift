import Cocoa

enum IconControllerError: Error {
  case tiffRepresentationFailed
  case bitmapImageRepFailed
  case representationUsingTiffFailed
  case saveImageToDestinationFailed(URL)
}

class IconController {
  let fileManager: FileManager
  let workspace: NSWorkspace
  let cache = NSCache<NSString, NSImage>()

  init(fileManager: FileManager = .default,
       workspace: NSWorkspace = .shared) {
    self.fileManager = fileManager
    self.workspace = workspace
  }

  // MARK: - Public methods

  func loadIcon(at path: URL, identifier: String,
                queue: DispatchQueue? = DispatchQueue.global(qos: .userInteractive),
                then handler: @escaping (NSImage?) -> Void) {
    if let queue = queue {
      queue.async { [weak self] in
        guard let strongSelf = self else { return }
        let image = strongSelf.icon(at: path, identifier: identifier)
        DispatchQueue.main.async { handler(image) }
      }
    } else {
      handler(icon(at: path, identifier: identifier))
    }
  }

  func icon(at url: URL, identifier: String) -> NSImage {
    if let image = cache.object(forKey: identifier as NSString) {
      return image
    }

    var image: NSImage
    if let cachedImage = loadImageFromDisk(withFilename: identifier) {
      image = cachedImage
    } else {
      let fileExtension = (url.path as NSString).pathExtension

      if fileExtension == "app" {
        image = NSWorkspace.shared.icon(forFile: url.path)
      } else {
        image = NSImage.init(byReferencing: url)
      }

      var imageRect: CGRect = .init(origin: .zero, size: CGSize(width: 128, height: 128))
      let imageRef = image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
      if let imageRef = imageRef {
        image = NSImage(cgImage: imageRef, size: imageRect.size)
      }
    }

    try? saveImageToDisk(image, withFilename: identifier)
    cache.setObject(image, forKey: identifier as NSString)
    return image
  }

  func computerIcon() -> NSImage {
    let icon = workspace.icon(forFileType: NSFileTypeForHFSTypeCode(OSType(kComputerIcon)))
    return icon
  }

  func saveImage(_ image: NSImage,
                 to destination: URL,
                 override: Bool = false) throws {
    let data = try tiffDataFromImage(image)
    do {
      if fileManager.fileExists(atPath: destination.path) {
        if override == false { return }
        try fileManager.removeItem(at: destination)
      }
      try data.write(to: destination)
    } catch {
      throw IconControllerError.saveImageToDestinationFailed(destination)
    }
  }

  func pathForApplicationImage(_ application: Application, identifier: String) -> URL? {
    if let applicationFile = try? applicationCacheDirectory()
      .appendingPathComponent("\(identifier).png") {
      if FileManager.default.fileExists(atPath: applicationFile.path) {
        return applicationFile
      }
    }

    return nil
  }

  // MARK: - Private methods

  private func tiffDataFromImage(_ image: NSImage) throws -> Data {
    guard let tiff = image.tiffRepresentation else { throw IconControllerError.tiffRepresentationFailed }
    guard let imgRep = NSBitmapImageRep(data: tiff) else { throw IconControllerError.bitmapImageRepFailed }
    guard let data = imgRep.representation(using: .png, properties: [:]) else { throw IconControllerError.representationUsingTiffFailed }

    return data
  }

  private func loadImageFromDisk(withFilename filename: String) -> NSImage? {
    if let applicationFile = try? applicationCacheDirectory()
      .appendingPathComponent("\(filename).png") {
      if FileManager.default.fileExists(atPath: applicationFile.path) {
        let image = NSImage.init(contentsOf: applicationFile)
        return image
      }
    }

    return nil
  }

  private func saveImageToDisk(_ image: NSImage, withFilename fileName: String) throws {
    let applicationFile = try applicationCacheDirectory()
      .appendingPathComponent("\(fileName).png")
    try saveImage(image, to: applicationFile)
  }

  private func applicationCacheDirectory() throws -> URL {
    let url = try FileManager.default.url(for: .cachesDirectory,
                                          in: .userDomainMask,
                                          appropriateFor: nil,
                                          create: true)
      .appendingPathComponent(Bundle.main.bundleIdentifier!)
      .appendingPathComponent("IconCache")

    if !FileManager.default.fileExists(atPath: url.path) {
      try FileManager.default.createDirectory(at: url,
                                              withIntermediateDirectories: true,
                                              attributes: nil)
    }

    return url
  }
}
