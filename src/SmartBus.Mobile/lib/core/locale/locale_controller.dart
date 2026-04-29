import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:smart_bus/core/storage/secure_storage.dart';

part 'locale_controller.g.dart';

/// Holds the user's chosen locale (`en` or `ar`). `null` means follow the
/// system locale. Persisted in [SecureStorage].
@Riverpod(keepAlive: true)
class LocaleController extends _$LocaleController {
  @override
  Future<Locale?> build() async {
    final raw = await ref.watch(secureStorageProvider).readLocale();
    if (raw == null || raw.isEmpty) return null;
    return Locale(raw);
  }

  Future<void> setLocale(String languageCode) async {
    await ref.read(secureStorageProvider).writeLocale(languageCode);
    state = AsyncValue.data(Locale(languageCode));
  }

  Future<void> toggleEnAr() async {
    final current = state.valueOrNull?.languageCode ?? 'en';
    await setLocale(current == 'ar' ? 'en' : 'ar');
  }
}
