import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, ApplicationDelegateControllerDelegate {

  var applicationDelegateController: ApplicationDelegateController!
  var statusItem: NSStatusItem?
  var dependencyContainer: DependencyContainer?
  @IBOutlet var statusMenu: NSMenu!
  @IBOutlet var mainMenuController: MainMenuController?

  // MARK: - NSApplicationDelegate

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    guard NSClassFromString("XCTestCase") == nil else { return }
    loadInjection()
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(mainWindowDidClose),
                                           name: MainWindowNotification.didClose.notificationName,
                                           object: nil)
    configureApplication()
  }

  func applicationDidResignActive(_ notification: Notification) {
    applicationDelegateController.applicationDidResignActive()
  }

  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    return applicationDelegateController.applicationShouldHandleReopen()
  }

  func applicationWillTerminate(_ notification: Notification) {
    applicationDelegateController.applicationWillTerminate()
  }

  // MARK: - Observers

  @objc func mainWindowDidClose() {
    applicationDelegateController.mainWindowDidClose()
  }

  // MARK: - Private methods

  private func loadInjection() {
    #if DEBUG
    if Bundle.main.bundlePath.hasPrefix("/Applications/") {
      return
    }

    Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/macOSInjection.bundle")?.load()
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(injected),
      name: NSNotification.Name(rawValue: "INJECTION_BUNDLE_NOTIFICATION"),
      object: nil
    )
    #endif
  }

  @objc func injected() {
    CATransaction.begin()
    NSApplication.shared.windows
      .compactMap({ $0 as? MainWindow })
      .forEach { $0.close() }
    configureApplication()
    CATransaction.commit()
  }

  private func configureApplication() {
    applicationDelegateController = ApplicationDelegateController()
    applicationDelegateController.delegate = self
    applicationDelegateController.appDelegate = self
    applicationDelegateController.applicationDidFinishLaunching(with: self)
    configureStatusMenu()
  }

  private func configureStatusMenu() {
    let statusBar = NSStatusBar.system
    let statusItem = statusBar.statusItem(withLength: statusBar.thickness)
    statusItem.button?.image = NSImage(named: "StatusMenu")
    statusItem.button?.toolTip = "Syncalicious"
    statusItem.button?.isEnabled = true
    statusItem.menu = statusMenu
    self.statusItem = statusItem
  }

  private func configureMainMenuController() {
    self.mainMenuController?.appDelegate = self
    self.mainMenuController?.dependencyContainer =  applicationDelegateController.dependencyContainer
    self.mainMenuController?.listContainerViewController = applicationDelegateController
      .listFeatureViewController?
      .containerViewController
    self.mainMenuController?.detailFeatureViewController = applicationDelegateController.detailFeatureViewController
  }

  // MARK: - ApplicationDelegateControllerDelegate

  func applicationDelegateController(_ controller: ApplicationDelegateController, didLoadApplication: Bool) {
    if didLoadApplication {
      configureMainMenuController()
    }
  }
}
