import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui' show PlatformDispatcher;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:tilmez_bus/core/network/dio_client.dart';
import 'package:tilmez_bus/core/notifications/push_notification_service.dart';
import 'package:tilmez_bus/features/auth/presentation/providers/auth_controller.dart';

part 'device_token_registrar.g.dart';

/// Registers the current FCM token with the backend whenever the user is
/// authenticated. Idempotent — the API treats it as upsert. Re-registers on
/// token rotation (Firebase issues a fresh token periodically).
@Riverpod(keepAlive: true)
class DeviceTokenRegistrar extends _$DeviceTokenRegistrar {
  @override
  Future<void> build() async {
    final user = ref.watch(authControllerProvider).valueOrNull;
    if (user == null) return;

    final initialToken = await ref.watch(fcmDeviceTokenProvider.future);
    if (initialToken != null) {
      await _post(initialToken);
    }

    // Re-register on rotation. Note: ref.listen must run inside build().
    ref.listen<AsyncValue<String>>(fcmTokenStreamProvider, (_, next) {
      final token = next.valueOrNull;
      if (token != null) unawaited(_post(token));
    });
  }

  Future<void> _post(String token) async {
    try {
      final dio = ref.read(dioClientProvider);
      // Detect the device's preferred language so the server picks the
      // right notification template (Arabic vs English) when pushing
      // to this device. Falls back to "ar" if the locale is unset.
      final localeCode =
          PlatformDispatcher.instance.locale.languageCode.toLowerCase();
      final language = localeCode.isEmpty ? 'ar' : localeCode;
      await dio.post<void>(
        '/notifications/devices',
        data: {
          'token': token,
          'platform': Platform.isIOS ? 'ios' : 'android',
          'language': language,
        },
      );
      if (kDebugMode) {
        // ignore: avoid_print
        print('[FCM] token registered with API');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('[FCM] token registration failed: ${e.message}');
      }
    }
  }
}
