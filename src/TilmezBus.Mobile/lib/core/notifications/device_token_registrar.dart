import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:tilmez_bus/core/locale/locale_controller.dart';
import 'package:tilmez_bus/core/network/dio_client.dart';
import 'package:tilmez_bus/core/notifications/push_notification_service.dart';
import 'package:tilmez_bus/features/auth/presentation/providers/auth_controller.dart';

part 'device_token_registrar.g.dart';

/// Registers the current FCM token with the backend whenever the user is
/// authenticated. Idempotent — the API treats it as upsert. Re-registers on
/// FCM token rotation AND on in-app locale changes so the server has the
/// up-to-date `language` to render notification templates against.
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

    // Re-register on FCM token rotation. Note: ref.listen must run
    // inside build() so the subscription is bound to this provider's
    // lifetime.
    ref.listen<AsyncValue<String>>(fcmTokenStreamProvider, (_, next) {
      final token = next.valueOrNull;
      if (token != null) unawaited(_post(token));
    });

    // Re-register on locale change so the next push lands in whatever
    // language the user just picked from settings. Without this the
    // backend keeps the language captured at cold-start until the next
    // launch.
    ref.listen<AsyncValue<Locale?>>(localeControllerProvider, (prev, next) {
      final prevCode = prev?.valueOrNull?.languageCode;
      final newCode  = next.valueOrNull?.languageCode;
      if (prevCode == newCode) return;
      final token = ref.read(fcmDeviceTokenProvider).valueOrNull;
      if (token != null) unawaited(_post(token));
    });
  }

  Future<void> _post(String token) async {
    try {
      final dio = ref.read(dioClientProvider);
      // Prefer the in-app locale (from LocaleController, persisted to
      // SecureStorage) so a manual language switch from settings
      // immediately influences the server-side template language.
      // Falls back to the OS locale, then "ar".
      final inAppLocale =
          ref.read(localeControllerProvider).valueOrNull?.languageCode;
      final osLocale =
          PlatformDispatcher.instance.locale.languageCode.toLowerCase();
      final language = (inAppLocale != null && inAppLocale.isNotEmpty)
          ? inAppLocale.toLowerCase()
          : (osLocale.isEmpty ? 'ar' : osLocale);
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
        print('[FCM] token registered with API (lang=$language)');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('[FCM] token registration failed: ${e.message}');
      }
    }
  }
}
