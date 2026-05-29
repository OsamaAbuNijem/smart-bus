import Flutter
import UIKit
import UserNotifications
import FirebaseCore
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    // Firebase's auto-swizzling for the APNs callback is unreliable under
    // the UIScene lifecycle on iOS 26 — request the token ourselves and
    // hand it to FirebaseMessaging in `didRegisterForRemoteNotifications…`.
    application.registerForRemoteNotifications()
    // Own the UNUserNotificationCenter delegate so the foreground
    // presentation override below runs. firebase_messaging's
    // setForegroundNotificationPresentationOptions doesn't reliably
    // bind in iOS 26; setting the delegate from native is the
    // dependable path.
    UNUserNotificationCenter.current().delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
  }

  /// Show banner + sound + badge when a notification arrives while the
  /// app is foregrounded. Without this iOS silently suppresses
  /// notifications for active apps — the message lands in the inbox
  /// (via FCM data path) but no visible alert.
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .list, .sound, .badge])
    } else {
      completionHandler([.alert, .sound, .badge])
    }
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
