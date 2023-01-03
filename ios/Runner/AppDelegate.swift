import UIKit
import Flutter
import UserNotifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
      
      let channelName = "msufcu.digital_transformation_of_member_data/pushNotifications"
      
      let pushNotificationChannel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)
      
      pushNotificationChannel.setMethodCallHandler({(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
          // This method is invoked on the UI thread.
          // Handle push notifications
          if (call.method == "sendPushNotification")
          {
              sendPushNotification(notificationData: call.arguments as! [String])
          }
          else if (call.method == "createNotificationChannel")
          {
              registerPushNotifications()
          }
      })
    registerPushNotifications()
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

private func registerPushNotifications() {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        
        // Enable or disable features based on the authorization.
    }
}

private func sendPushNotification(notificationData: [String]) {
    let center = UNUserNotificationCenter.current()
    center.getNotificationSettings { settings in
        guard (settings.authorizationStatus == .authorized) ||
              (settings.authorizationStatus == .provisional) else { return }

        if settings.alertSetting == .enabled {
            createNotification(notificationTitle: notificationData[0], notificationContent: notificationData[1])
        } else {
            createNotification(notificationTitle: notificationData[0], notificationContent: notificationData[1])
        }
    }
}

private func createNotification(notificationTitle: String, notificationContent: String) {
    let content = UNMutableNotificationContent()
    content.title = notificationTitle
    content.body = notificationContent
    
    var dateComponents = DateComponents()
    dateComponents.calendar = Calendar.current
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    
    // Create the request
    let uuidString = UUID().uuidString
    let request = UNNotificationRequest(identifier: uuidString,
                                        content: content, trigger: trigger)

    // Schedule the request with the system.
    let notificationCenter = UNUserNotificationCenter.current()
    notificationCenter.add(request) { (error) in
       if error != nil {
          // Handle any errors.
       }
    }
}
