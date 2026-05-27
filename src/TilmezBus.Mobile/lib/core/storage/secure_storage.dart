import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage.g.dart';

class SecureStorage {
  SecureStorage(this._storage);

  static const _kAccessToken = 'auth.access_token';
  static const _kRefreshToken = 'auth.refresh_token';
  static const _kTokenExpiresAt = 'auth.expires_at';
  static const _kFullName = 'auth.full_name';
  static const _kPhoneNumber = 'auth.phone_number';
  static const _kRole = 'auth.role';
  static const _kEntityId = 'auth.entity_id';
  static const _kLocale = 'pref.locale';
  static const _kOnboardingSeen = 'pref.onboarding_seen';

  final FlutterSecureStorage _storage;

  Future<String?> readAccessToken() => _storage.read(key: _kAccessToken);
  Future<void> writeAccessToken(String value) =>
      _storage.write(key: _kAccessToken, value: value);

  Future<String?> readRefreshToken() => _storage.read(key: _kRefreshToken);
  Future<void> writeRefreshToken(String value) =>
      _storage.write(key: _kRefreshToken, value: value);

  Future<DateTime?> readTokenExpiresAt() async {
    final raw = await _storage.read(key: _kTokenExpiresAt);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> writeTokenExpiresAt(DateTime value) =>
      _storage.write(key: _kTokenExpiresAt, value: value.toIso8601String());

  Future<String?> readFullName() => _storage.read(key: _kFullName);
  Future<void> writeFullName(String value) =>
      _storage.write(key: _kFullName, value: value);

  Future<String?> readPhoneNumber() => _storage.read(key: _kPhoneNumber);
  Future<void> writePhoneNumber(String value) =>
      _storage.write(key: _kPhoneNumber, value: value);

  Future<String?> readRole() => _storage.read(key: _kRole);
  Future<void> writeRole(String value) =>
      _storage.write(key: _kRole, value: value);

  Future<String?> readEntityId() => _storage.read(key: _kEntityId);
  Future<void> writeEntityId(String value) =>
      _storage.write(key: _kEntityId, value: value);

  Future<String?> readLocale() => _storage.read(key: _kLocale);
  Future<void> writeLocale(String value) =>
      _storage.write(key: _kLocale, value: value);

  Future<bool> readOnboardingSeen() async =>
      (await _storage.read(key: _kOnboardingSeen)) == '1';
  Future<void> writeOnboardingSeen() =>
      _storage.write(key: _kOnboardingSeen, value: '1');

  Future<void> clearAuth() async {
    await Future.wait([
      _storage.delete(key: _kAccessToken),
      _storage.delete(key: _kRefreshToken),
      _storage.delete(key: _kTokenExpiresAt),
      _storage.delete(key: _kFullName),
      _storage.delete(key: _kPhoneNumber),
      _storage.delete(key: _kRole),
      _storage.delete(key: _kEntityId),
    ]);
  }
}

@Riverpod(keepAlive: true)
SecureStorage secureStorage(Ref ref) =>
    SecureStorage(const FlutterSecureStorage());
