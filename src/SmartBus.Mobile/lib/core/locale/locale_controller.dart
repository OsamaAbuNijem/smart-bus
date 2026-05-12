import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:smart_bus/core/storage/secure_storage.dart';

part 'locale_controller.g.dart';

/// Holds the user's chosen locale (`en` or `ar`). Arabic is the default
/// when no preference is stored. Persisted in [SecureStorage].
@Riverpod(keepAlive: true)
class LocaleController extends _$LocaleController {
  @override
  Future<Locale?> build() async {
    final raw = await ref.watch(secureStorageProvider).readLocale();
    if (raw == null || raw.isEmpty) return const Locale('ar');
    return Locale(raw);
  }

  Future<void> setLocale(String languageCode) async {
    await ref.read(secureStorageProvider).writeLocale(languageCode);
    state = AsyncValue.data(Locale(languageCode));
  }

  Future<void> toggleEnAr() async {
    final current = state.valueOrNull?.languageCode ?? 'ar';
    await setLocale(current == 'ar' ? 'en' : 'ar');
  }
}
