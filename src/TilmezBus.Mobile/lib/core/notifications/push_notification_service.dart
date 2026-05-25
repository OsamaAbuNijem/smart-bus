import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'push_notification_service.g.dart';

/// Background isolate handler for FCM messages received while the app is
/// terminated. Must be a top-level function. Keep it minimal — there's no
/// access to the Riverpod container here.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // The system tray notification is delivered automatically by Android via
  // the `notification` payload; data-only payloads would need manual display.
}

/// Initializes Firebase + FCM and exposes the device token / message stream.
class PushNotificationService {
  PushNotificationService(this._messaging, this._localNotifications);

  final FirebaseMessaging _messaging;
  final FlutterLocalNotifications _localNotifications;

  static const _channel = AndroidNotificationChannel(
    'smartbus_default',
    'TilmezBus Notifications',
    description: 'Trip updates, bus arrival, and absence replies.',
    importance: Importance.high,
  );

  /// Call once on app start (after Firebase.initializeApp).
  Future<void> initialize() async {
    // Foreground notification display channel.
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_channel);

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // iOS needs explicit init for the local-notifications plugin to be
        // able to present a banner via [_showForegroundNotification].
        // Defaults map to alert+badge+sound so a notification posted while
        // the app is foregrounded actually appears at the top of the
        // screen instead of being silently dropped.
        iOS: DarwinInitializationSettings(),
      ),
    );

    // iOS suppresses banners for foregrounded apps by default. Opt-in so
    // arrived-at-school / trip-ended pushes still surface visually while
    // the parent has the app open.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Show banners while the app is foregrounded.
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
  }

  /// Asks the OS for notification permission. On Android 13+ this is the
  /// runtime POST_NOTIFICATIONS prompt; on older Android it's a no-op.
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<String?> getDeviceToken() async {
    // On iOS, FirebaseMessaging.getToken() throws "APNS token has not been
    // set yet" if Apple hasn't returned the APNs device token in time.
    // Poll briefly so the FCM token request lands once iOS is ready.
    if (Platform.isIOS) {
      for (var i = 0; i < 20; i++) {
        final apns = await _messaging.getAPNSToken();
        if (apns != null) break;
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
    }
    return _messaging.getToken();
  }

  Stream<String> get tokenRefreshStream => _messaging.onTokenRefresh;

  /// Stream of FCM messages received while the app is foregrounded. Used by
  /// the notifications inbox to refresh itself live.
  Stream<RemoteMessage> get foregroundMessageStream =>
      FirebaseMessaging.onMessage;

  void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    if (kDebugMode) {
      // ignore: avoid_print
      print('[FCM] foreground message: title="${notification?.title}" '
          'body="${notification?.body}" data=${message.data}');
    }
    if (notification == null) return;
    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data.isEmpty ? null : message.data.toString(),
    );
  }
}

/// Local typedef so the long generic doesn't litter call sites.
typedef FlutterLocalNotifications = FlutterLocalNotificationsPlugin;

@Riverpod(keepAlive: true)
PushNotificationService pushNotificationService(Ref ref) {
  final svc = PushNotificationService(
    FirebaseMessaging.instance,
    FlutterLocalNotificationsPlugin(),
  );
  return svc;
}

/// Init lifecycle: request permission + return current FCM token.
/// Watching this provider triggers initialization once per app run.
@Riverpod(keepAlive: true)
Future<String?> fcmDeviceToken(Ref ref) async {
  final svc = ref.watch(pushNotificationServiceProvider);
  await svc.initialize();
  await svc.requestPermission();
  // Push the latest token whenever Firebase rotates it.
  ref.listen<AsyncValue<String?>>(
    fcmTokenStreamProvider,
    (_, next) {
      // Token-refresh registration with the API happens in the registrar
      // provider below; this listen is just to keep the stream alive.
    },
  );
  return svc.getDeviceToken();
}

@Riverpod(keepAlive: true)
Stream<String> fcmTokenStream(Ref ref) =>
    ref.watch(pushNotificationServiceProvider).tokenRefreshStream;

/// Stream of foreground FCM messages. Listeners use this to react to
/// incoming pushes (e.g. refresh the inbox).
@Riverpod(keepAlive: true)
Stream<RemoteMessage> fcmForegroundMessages(Ref ref) =>
    ref.watch(pushNotificationServiceProvider).foregroundMessageStream;

/// Background message handler must be registered before runApp(). Call from
/// main() before Firebase.initializeApp().
void registerFirebaseBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  if (kDebugMode) {
    // ignore: avoid_print
    print('[FCM] background handler registered');
  }
}
