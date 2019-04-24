import Cocoa

protocol FirstLaunchViewControllerDelegate: class {
  func firstLaunchViewController(_ controller: FirstLaunchViewController, didPressDoneButton button: NSButton)
}

class FirstLaunchViewController: NSViewController, WelcomeViewControllerDelegate, DestinationViewControllerDelegate,
  PermissionViewControllerDelegate, BackupControllerDelegate {
  weak var delegate: FirstLaunchViewControllerDelegate?

  lazy var gradientView = GradientView()
  lazy var destinationViewController = DestinationViewController()
  lazy var welcomeViewController = WelcomeViewController()
  lazy var permissionViewController = PermissionViewController()

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
    welcomeViewController.delegate = self
    destinationViewController.delegate = self
    permissionViewController.delegate = self

    addViewController(welcomeViewController)

    view.frame.size = CGSize(width: 800, height: 480)
  }

  func showDestinationView() {
    removeViewController(welcomeViewController)
    addViewController(destinationViewController)
    gradientView.gradientLayer.colors = [
      NSColor.windowBackgroundColor.withSystemEffect(.pressed).cgColor,
      NSColor.windowBackgroundColor.cgColor
    ]
  }

  func showPermissionView() {
    removeViewController(destinationViewController)
    addViewController(permissionViewController)
    gradientView.gradientLayer.colors = [
      NSColor(named: "Corn Silk")!.withSystemEffect(.pressed).cgColor,
      NSColor(named: "Corn Silk")!.cgColor
    ]
  }

  private func addViewController(_ viewController: NSViewController) {
    addChild(viewController)
    view.addSubview(viewController.view)
    configureConstraintsForViewController(viewController)
  }

  private func removeViewController(_ viewController: NSViewController) {
    destinationViewController.removeFromParent()
    destinationViewController.view.removeFromSuperview()
  }

  private func configureConstraintsForViewController(_ viewController: NSViewController) {
    NSLayoutConstraint.deactivate(layoutConstraints)
    layoutConstraints = [
      viewController.view.topAnchor.constraint(equalTo: view.topAnchor),
      viewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      viewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ]
    NSLayoutConstraint.constrain(layoutConstraints)
  }

  // MARK: - BackupControllerDelegate

  func backupController(_ controller: BackupController, didSelectDestination destination: URL) {
    destinationViewController.directoryLabel.stringValue = destination.path
    if !destination.path.isEmpty {
      destinationViewController.nextButton.animator().alphaValue = 1.0
    }
  }

  // MARK: - WelcomeViewDelegate

  func welcomeViewController(_ controller: WelcomeViewController, didTapGetStarted button: NSButton) {
    controller.animateOut {
      self.showDestinationView()
    }
  }

  // MARK: - DestinationViewDelegate

  func destinationViewController(_ controller: DestinationViewController, didTapDirectoryButton button: NSButton) {
    backupController.chooseDestination()
  }

  func destinationViewController(_ controller: DestinationViewController, didTapNextButton button: NSButton) {
    controller.animateOut {
      self.showPermissionView()
    }
  }

  // MARK: - PermissionViewDelegate

  func permissionViewController(_ controller: PermissionViewController, didTapPermissions button: NSButton) {
    let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!
    NSWorkspace.shared.open(url)
  }

  func permissionViewController(_ controller: PermissionViewController, didTapDoneButton button: NSButton) {
    delegate?.firstLaunchViewController(self, didPressDoneButton: button)
  }

}
