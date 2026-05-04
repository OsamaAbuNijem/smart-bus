import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smart_bus/app.dart';
import 'package:smart_bus/core/notifications/device_token_registrar.dart';
import 'package:smart_bus/core/notifications/push_notification_service.dart';

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

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const SmartBusApp(),
    ),
  );
}
