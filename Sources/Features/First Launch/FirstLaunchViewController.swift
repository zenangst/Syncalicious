import Cocoa

protocol FirstLaunchViewControllerDelegate: class {
  func firstLaunchViewController(_ controller: FirstLaunchViewController, didPressDoneButton button: NSButton)
}

class FirstLaunchViewController: NSViewController, WelcomeViewDelegate, DestinationViewDelegate,
  PermissionViewDelegate, BackupControllerDelegate {
  weak var delegate: FirstLaunchViewControllerDelegate?

  lazy var gradientView = GradientView()
  lazy var welcomeView = WelcomeView()
  lazy var destinationView = DestinationView()
  lazy var permissionView = PermissionView()

  let backupController: BackupController

  private var layoutConstraints = [NSLayoutConstraint]()

  init(backupController: BackupController) {
    self.backupController = backupController
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    gradientView.gradientLayer.colors = [
      NSColor(red: 1.00, green: 0.82, blue: 0.75, alpha: 1.00).cgColor,
      NSColor(red: 1.00, green: 0.92, blue: 0.88, alpha: 1.00).cgColor
    ]
    view = gradientView
    welcomeView.delegate = self
    destinationView.delegate = self
    permissionView.delegate = self
    welcomeView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(welcomeView)

    NSLayoutConstraint.deactivate(layoutConstraints)
    layoutConstraints = [
      welcomeView.topAnchor.constraint(equalTo: view.topAnchor),
      welcomeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      welcomeView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      welcomeView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ]
    NSLayoutConstraint.activate(layoutConstraints)
  }

  override func viewWillAppear() {
    super.viewWillAppear()
    welcomeView.reset()
  }

  override func viewDidAppear() {
    super.viewDidAppear()
    welcomeView.animateIn()
  }

  func showDestinationView() {
    welcomeView.removeFromSuperview()
    destinationView.translatesAutoresizingMaskIntoConstraints = false
    destinationView.reset()
    destinationView.animateIn()
    view.addSubview(destinationView)
    NSLayoutConstraint.deactivate(layoutConstraints)
    layoutConstraints = [
      destinationView.topAnchor.constraint(equalTo: view.topAnchor),
      destinationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      destinationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      destinationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ]
    NSLayoutConstraint.activate(layoutConstraints)

    gradientView.gradientLayer.colors = [
      NSColor.windowBackgroundColor.withSystemEffect(.pressed).cgColor,
      NSColor.windowBackgroundColor.cgColor
    ]
  }

  func showPermissionView() {
    destinationView.removeFromSuperview()
    permissionView.translatesAutoresizingMaskIntoConstraints = false
    permissionView.reset()
    permissionView.animateIn()
    view.addSubview(permissionView)
    NSLayoutConstraint.deactivate(layoutConstraints)
    layoutConstraints = [
      permissionView.topAnchor.constraint(equalTo: view.topAnchor),
      permissionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      permissionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      permissionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ]
    NSLayoutConstraint.activate(layoutConstraints)

    gradientView.gradientLayer.colors = [
      NSColor(named: "Corn Silk")?.withSystemEffect(.pressed).cgColor,
      NSColor(named: "Corn Silk")?.cgColor
    ]
  }

  // MARK: - BackupControllerDelegate

  func backupController(_ controller: BackupController, didSelectDestination destination: URL) {
    destinationView.directoryLabel.stringValue = destination.path

    if !destination.path.isEmpty {
      destinationView.nextButton.alphaValue = 1.0
    }
  }

  // MARK: - WelcomeViewDelegate

  func welcomeView(_ view: WelcomeView, didTapGetStarted button: NSButton) {
    view.animateOut {
      NSAnimationContext.current.duration = 1.0
      self.showDestinationView()
    }
  }

  // MARK: - DestinationViewDelegate

  func destinationView(_ view: DestinationView, didTapDirectoryButton button: NSButton) {
    backupController.chooseDestination()
  }

  func destinationView(_ view: DestinationView, didTapNextButton button: NSButton) {
    view.animateOut {
      NSAnimationContext.current.duration = 1.0
      self.showPermissionView()
    }
//    delegate?.firstLaunchViewController(self, didPressDoneButton: button)
  }

  // MARK: - PermissionViewDelegate

  func permissionView(_ view: PermissionView, didTapPermissions button: NSButton) {
    let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!
    NSWorkspace.shared.open(url)
  }

  func permissionView(_ view: PermissionView, didTapDoneButton button: NSButton) {
    delegate?.firstLaunchViewController(self, didPressDoneButton: button)
  }

}
