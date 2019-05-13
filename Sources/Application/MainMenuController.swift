import Cocoa

class MainMenuController: NSObject {
  weak var appDelegate: AppDelegate?
  weak var dependencyContainer: DependencyContainer?
  weak var splitViewController: SplitViewController?
  weak var listContainerViewController: ListContainerViewController?
  weak var detailFeatureViewController: DetailFeatureViewController?

  var sidebarSplitItem: NSSplitViewItem? {
    return splitViewController?.splitViewItems.first
  }

  // MARK: - Actions

  @IBAction func toggleSidebar(_ sender: Any?) {
    guard let splitItem = sidebarSplitItem else { return }
    toggleSplitItemSidebar(to: !splitItem.isCollapsed)
  }

  @IBAction func openWindow(_ sender: Any?) {
    NSApplication.shared.activate(ignoringOtherApps: true)
    try? appDelegate?.applicationDelegateController?.loadApplication()?.showWindow(nil)
  }

  @IBAction func selectBackupDestination(_ sender: Any?) {
    dependencyContainer?.backupController.chooseDestination()
  }

  @IBAction func viewGeneral(_ sender: Any?) {
    let tab = DetailFeatureViewController.Tab.general
    guard let segmentedControl = detailFeatureViewController?.segmentedControl else {
      return
    }
    if let index = DetailFeatureViewController.Tab.allCases.firstIndex(of: tab) {
      segmentedControl.setSelected(true, forSegment: index)
    } else {
      segmentedControl.setSelected(true, forSegment: 0)
    }
    detailFeatureViewController?.changeTab(segmentedControl)
  }

  @IBAction func viewCustomize(_ sender: Any?) {
    let tab = DetailFeatureViewController.Tab.customize
    guard let segmentedControl = detailFeatureViewController?.segmentedControl else {
      return
    }
    if let index = DetailFeatureViewController.Tab.allCases.firstIndex(of: tab) {
      segmentedControl.setSelected(true, forSegment: index)
    } else {
      segmentedControl.setSelected(true, forSegment: 0)
    }
    detailFeatureViewController?.changeTab(segmentedControl)
  }

  @IBAction func sortByName(_ sender: Any?) {
    guard let segmentControl = listContainerViewController?.sortViewController.segmentedControl else { return }
    if sidebarSplitItem?.isCollapsed == true { toggleSplitItemSidebar(to: false) }
    segmentControl.setSelected(true, forSegment: 0)
    listContainerViewController?.sortViewController.didChangeSort(segmentControl)
  }

  @IBAction func sortBySynced(_ sender: Any?) {
    guard let segmentControl = listContainerViewController?.sortViewController.segmentedControl else { return }
    if sidebarSplitItem?.isCollapsed == true { toggleSplitItemSidebar(to: false) }
    segmentControl.setSelected(true, forSegment: 1)
    listContainerViewController?.sortViewController.didChangeSort(segmentControl)
  }

  @IBAction func search(_ sender: Any?) {
    if sidebarSplitItem?.isCollapsed == true { toggleSplitItemSidebar(to: false) }
    listContainerViewController?.searchViewController.searchField.becomeFirstResponder()
  }

  @IBAction func performBackup(_ sender: Any?) {
    guard let windowFactory = dependencyContainer?.windowFactory else { return }

    guard let backupDestination = UserDefaults.standard.syncaliciousUrl else {
      let message = NSLocalizedString("You need to pick a backup destination before you can make a backup.",
                                      comment: "")
      let alert = windowFactory.createAlert(with: message)
      alert.runModal()
      return
    }
    do {
      try dependencyContainer?.backupController.initializeBackup(to: backupDestination)
    } catch let error {
      let alert = windowFactory.createAlert(error: error)
      alert.runModal()
    }
  }

  private func toggleSplitItemSidebar(to newValue: Bool) {
    sidebarSplitItem?.isCollapsed = newValue
    splitViewController?.splitViewItems.forEach {
      $0.viewController.view.needsLayout = true
      $0.viewController.view.layoutSubtreeIfNeeded()
    }
    NotificationCenter.default.post(Notification.init(name: NSSplitView.didResizeSubviewsNotification))
  }
}
