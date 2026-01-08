import UserNotifications
import UIKit

final class NotificationSoundManager {
    static let shared = NotificationSoundManager()

    private init() {
        requestPermission()
    }

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            print("Notification permission: \(granted), error: \(String(describing: error))")
        }
    }

    func scheduleSound(identifier: String, sound: String, at date: Date, title: String = "", body: String = "") {
        let content = UNMutableNotificationContent()
        content.title = title.isEmpty ? " " : title  // Need some content for notification to fire
        content.body = body

        // Try different sound file extensions
        if sound == "bell" {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "bell.mp3"))
        } else {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "\(sound).m4a"))
        }

        let timeInterval = date.timeIntervalSinceNow
        guard timeInterval > 0 else {
            print("Skipping notification \(identifier) - time already passed")
            return
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification \(identifier): \(error)")
            } else {
                print("Scheduled notification \(identifier) for \(sound) in \(timeInterval)s")
            }
        }
    }

    func cancelAllScheduledSounds() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("Cancelled all scheduled notifications")
    }

    func cancelSound(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
