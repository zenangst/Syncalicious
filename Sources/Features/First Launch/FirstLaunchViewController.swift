import Cocoa

protocol FirstLaunchViewControllerDelegate: class {
  func firstLaunchViewController(_ controller: FirstLaunchViewController, didPressDoneButton button: NSButton)
}

class FirstLaunchViewController: NSViewController, WelcomeViewDelegate, DestinationViewDelegate, BackupControllerDelegate {
  weak var delegate: FirstLaunchViewControllerDelegate?

  lazy var gradientView = GradientView()
  lazy var welcomeView = WelcomeView()
  lazy var destinationView = DestinationView()

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

  // MARK: - BackupControllerDelegate

  func backupController(_ controller: BackupController, didSelectDestination destination: URL) {
    destinationView.directoryLabel.stringValue = destination.path

    if !destination.path.isEmpty {
      destinationView.doneButton.alphaValue = 1.0
    }
  }

  // MARK: - WelcomeViewDelegate

  func welcomeView(_ view: WelcomeView, didTapGetStarted button: NSButton) {
    welcomeView.animateOut {
      NSAnimationContext.current.duration = 1.0
      self.showDestinationView()
    }
  }

  // MARK: - DestinationViewDelegate

  func destinationView(_ view: DestinationView, didTapDirectoryButton button: NSButton) {
    backupController.chooseDestination()
  }

  func destinationView(_ view: DestinationView, didTapNextButton button: NSButton) {
    delegate?.firstLaunchViewController(self, didPressDoneButton: button)
  }
}
