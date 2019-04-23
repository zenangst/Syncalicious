import Cocoa

class SplitViewController: NSSplitViewController {
  private var layoutConstraints = [NSLayoutConstraint]()

  override func viewDidLoad() {
    super.viewDidLoad()
    configureViews()
    NotificationCenter.default.addObserver(self, selector: #selector(mainWindowDidResignKey),
                                           name: MainWindowNotification.didResign.notificationName,
                                           object: nil)

    NotificationCenter.default.addObserver(self, selector: #selector(mainWindowDidBecomeKey),
                                           name: MainWindowNotification.becomeKey.notificationName,
                                           object: nil)
  }

  override func viewWillLayout() {
    super.viewWillLayout()
    let dividers = view.subviews.compactMap({ $0 as? DividerView })
    let lightDividers = view.subviews.compactMap({ $0 as? LightDividerView })
    let backgrounds = view.subviews.compactMap({ $0 as? BackgroundView })

    if view.effectiveAppearance.name == .aqua {
      dividers.forEach { $0.layer?.backgroundColor = NSColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 1.00).cgColor }
      backgrounds.forEach { $0.layer?.backgroundColor = $0.belongsToView?.layer?.backgroundColor }
      lightDividers.forEach { $0.layer?.backgroundColor = NSColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.00).cgColor }
    } else {
      dividers.forEach { $0.layer?.backgroundColor = NSColor.black.cgColor }
      backgrounds.forEach { $0.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor }
      lightDividers.forEach { $0.layer?.backgroundColor = NSColor.darkGray.cgColor }
    }
  }

  @objc func mainWindowDidResignKey() {
    for item in splitViewItems {
      let viewController = item.viewController
      let containedViewController = viewController as? SplitViewContainedController
      containedViewController?.titlebarView.alphaValue = 0.75
    }
  }

  @objc func mainWindowDidBecomeKey() {
    for item in splitViewItems {
      let viewController = item.viewController
      let containedViewController = viewController as? SplitViewContainedController
      containedViewController?.titlebarView.alphaValue = 1.0
    }
  }

  private func configureViews() {
    let decorationViews = view.subviews.compactMap({ $0 as? DecorationView })
    decorationViews.forEach { $0.removeFromSuperview() }
    NSLayoutConstraint.deactivate(layoutConstraints)
    splitView.translatesAutoresizingMaskIntoConstraints = false
    layoutConstraints = [
      splitView.topAnchor.constraint(equalTo: view.topAnchor, constant: 38),
      splitView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      splitView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      splitView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ]

    for item in splitViewItems {
      let viewController = item.viewController
      let view = viewController.view

      let toolbarBackground = BackgroundView(cgColor: view.layer?.backgroundColor)
      toolbarBackground.belongsToView = view
      self.view.addSubview(toolbarBackground, positioned: .below, relativeTo: splitView)

      let contentBackgroundView = BackgroundView(cgColor: view.layer?.backgroundColor)
      contentBackgroundView.belongsToView = view
      self.view.addSubview(contentBackgroundView, positioned: .below, relativeTo: splitView)

      let horizontalDivider = DividerView(cgColor: NSColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 1.00).cgColor)
      horizontalDivider.belongsToView = view
      self.view.addSubview(horizontalDivider, positioned: .above, relativeTo: splitView)

      let verticalDividerLight = LightDividerView(cgColor: NSColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.00).cgColor)
      verticalDividerLight.wantsLayer = view.layer?.backgroundColor?.components?.first == 1 ? false : true
      verticalDividerLight.belongsToView = view
      self.view.addSubview(verticalDividerLight)

      if let containedViewController = viewController as? SplitViewContainedController {
        containedViewController.titlebarView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(containedViewController.titlebarView)
        layoutConstraints.append(contentsOf: [
          containedViewController.titlebarView.topAnchor.constraint(equalTo: toolbarBackground.topAnchor),
          containedViewController.titlebarView.leadingAnchor.constraint(equalTo: toolbarBackground.leadingAnchor),
          containedViewController.titlebarView.trailingAnchor.constraint(equalTo: toolbarBackground.trailingAnchor),
          containedViewController.titlebarView.bottomAnchor.constraint(equalTo: toolbarBackground.bottomAnchor)
          ])
      } else {
        let label = SmallLabel()
        label.textColor = NSColor.windowFrameTextColor
        label.stringValue = viewController.title ?? ""
        label.alignment = .center
        label.belongsToView = view
        self.view.addSubview(label)

        layoutConstraints.append(contentsOf: [
          label.centerYAnchor.constraint(equalTo: toolbarBackground.centerYAnchor),
          label.centerXAnchor.constraint(equalTo: toolbarBackground.centerXAnchor)
          ])
      }

      layoutConstraints.append(contentsOf: [
        toolbarBackground.topAnchor.constraint(equalTo: self.view.topAnchor),
        toolbarBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        toolbarBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        toolbarBackground.heightAnchor.constraint(equalToConstant: 38),

        contentBackgroundView.topAnchor.constraint(equalTo: self.view.topAnchor),
        contentBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        contentBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        contentBackgroundView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

        verticalDividerLight.heightAnchor.constraint(equalToConstant: 1),
        verticalDividerLight.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        verticalDividerLight.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        verticalDividerLight.topAnchor.constraint(equalTo: toolbarBackground.bottomAnchor, constant: -1),

        horizontalDivider.widthAnchor.constraint(equalToConstant: 1),
        horizontalDivider.heightAnchor.constraint(equalTo: self.view.heightAnchor),
        horizontalDivider.centerXAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.5)
        ])
    }

    NSLayoutConstraint.activate(layoutConstraints)
  }

  override func splitView(_ splitView: NSSplitView, shouldHideDividerAt dividerIndex: Int) -> Bool {
    let result = super.splitView(splitView, shouldHideDividerAt: dividerIndex)
    let item = splitViewItems[dividerIndex]
    let decorationViews = view.subviews.compactMap({ $0 as? DecorationView })
      .filter({ $0.belongsToView == item.viewController.view })

    decorationViews.forEach {
      $0.isHidden = item.isCollapsed
    }

    return result
  }
}
