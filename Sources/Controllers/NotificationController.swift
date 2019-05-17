import Cocoa
import UserNotifications

class NotificationController: NSObject, UNUserNotificationCenterDelegate {
  private lazy var notificationCenter = UNUserNotificationCenter.current()
  let iconController: IconController

  init(iconController: IconController) {
    self.iconController = iconController
    super.init()
    self.notificationCenter.delegate = self
  }

  func post(application: Application, text: String) {
    let content = UNMutableNotificationContent()
    content.subtitle = application.propertyList.bundleName
    content.body = text
    let url = iconController.pathForApplicationImage(application, identifier: application.propertyList.bundleIdentifier)
    if let url = url,
      let attachment = try? UNNotificationAttachment(identifier: application.propertyList.bundleIdentifier + "-image", url: url, options: nil) {
      content.attachments = [attachment]
    }

    let request = UNNotificationRequest(identifier: application.propertyList.bundleIdentifier, content: content, trigger: nil)
    notificationCenter.add(request)
  }

  // MARK: - UNUserNotificationCenterDelegate

  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler(.alert)
  }
}
