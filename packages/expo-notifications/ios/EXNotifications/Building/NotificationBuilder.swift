//  Copyright © 2024 650 Industries. All rights reserved.

import ExpoModulesCore

@objc(EXNotificationBuilder)
public class NotificationBuilder: NSObject {
  @objc(notificationContentFromRequest:error:)
  public func content(_ request: [AnyHashable: Any]) throws -> UNMutableNotificationContent {
    let content = UNMutableNotificationContent()

    if let title: String = try? request.verifiedProperty("title", type: String.self) {
      content.title = title
    }

    if let subtitle: String = try? request.verifiedProperty("subtitle", type: String.self) {
      content.subtitle = subtitle
    }

    if let body: String = try? request.verifiedProperty("body", type: String.self) {
      content.body = body
    }

    if let launchImageName: String = try? request.verifiedProperty("launchImageName", type: String.self) {
      content.launchImageName = launchImageName
    }

    if let badge = try? request.verifiedProperty("badge", type: Int.self) {
      // swiftlint:disable:next legacy_objc_type
      content.badge = NSNumber.init(value: badge)
    }

    if let userInfo: [AnyHashable: Any] = try? request.verifiedProperty("userInfo", type: [AnyHashable: Any].self) {
      content.userInfo = userInfo
    }

    if let categoryIdentifier: String = try? request.verifiedProperty("categoryIdentifier", type: String.self) {
      content.categoryIdentifier = categoryIdentifier
    }

    if let sound = request["sound"] as? Bool {
      content.sound = sound ? .default : .none
    } else if let soundName = request["sound"] as? String {
      if soundName == "default" {
        content.sound = UNNotificationSound.default
      } else if soundName == "defaultCritical" {
        content.sound = UNNotificationSound.defaultCritical
      } else {
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundName))
      }
    }
    var attachments: [UNNotificationAttachment] = []
    if let attachmentsArray = request["attachments"] as? [[String: Any]] {
      for attachmentObject in attachmentsArray {
        if let attachment: UNNotificationAttachment = attachment(attachmentObject) {
          attachments.append(attachment)
        }
      }
    }
    content.attachments = attachments
    if let interruptionLevel = request["interruptionLevel"] as? String {
      content.interruptionLevel = deserializeInterruptionLevel(interruptionLevel)
    }

    return content
  }

  func attachment(_ request: [AnyHashable: Any]) -> UNNotificationAttachment? {
    let identifier = request["identifier"] as? String ?? ""
    let uri = request["uri"] as? String ?? ""
    do {
      if let url = URL(string: uri),
        let attachment: UNNotificationAttachment =
          try? UNNotificationAttachment(
            identifier: identifier,
            url: url,
            options: attachmentOptions(request)
          ) {
        return attachment
      }
      return nil
    }
  }

  func attachmentOptions(_ request: [AnyHashable: Any]) -> [AnyHashable: Any] {
    var options: [AnyHashable: Any] = [:]
    if let typeHint = request["typeHint"] as? String {
      options[UNNotificationAttachmentOptionsTypeHintKey] = typeHint
    }
    if let hideThumbnail = request["hideThumbnail"] as? Bool {
      options[UNNotificationAttachmentOptionsThumbnailHiddenKey] = hideThumbnail
    }
    if let thumbnailClipArea = request["thumbnailClipArea"] as? [String: Any] {
      let x = thumbnailClipArea["x"] as? Double
      let y = thumbnailClipArea["y"] as? Double
      let width = thumbnailClipArea["width"] as? Double
      let height = thumbnailClipArea["height"] as? Double
      if let x, let y, let width, let height {
        options[UNNotificationAttachmentOptionsThumbnailClippingRectKey] =
          CGRect(
            x: x,
            y: y,
            width: width,
            height: height
          )
      }
    }
    if let thumbnailTime = request["thumbnailTime"] as? TimeInterval {
      options[UNNotificationAttachmentOptionsThumbnailTimeKey] = thumbnailTime
    }
    return options
  }

  func deserializeInterruptionLevel(_ interruptionLevel: String) -> UNNotificationInterruptionLevel {
    switch interruptionLevel {
    case "passive": return .passive
    case "active": return .active
    case "timeSensitive": return .timeSensitive
    case "critical": return .critical
    default: return .passive
    }
  }
}
