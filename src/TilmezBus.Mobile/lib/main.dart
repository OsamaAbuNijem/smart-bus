import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tilmez_bus/app.dart';
import 'package:tilmez_bus/core/notifications/device_token_registrar.dart';
import 'package:tilmez_bus/core/notifications/push_notification_service.dart';
import 'package:tilmez_bus/core/wakelock/wakelock_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  registerFirebaseBackgroundHandler();

  final container = ProviderContainer();
  // Subscribe to the device-token registrar so it stays active for the
  // lifetime of the app and rebuilds whenever the auth state changes.
  // A bare `read` would initialise it once but wouldn't react to login.
  container.listen<AsyncValue<void>>(
    deviceTokenRegistrarProvider,
    (_, __) {},
    fireImmediately: true,
  );
  // Same pattern: keep the wakelock controller subscribed so it flips
  // screen-on whenever a driver / assistant logs in or out.
  container.listen<void>(
    wakelockControllerProvider,
    (_, __) {},
    fireImmediately: true,
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const TilmezBusApp(),
    ),
  );
}
