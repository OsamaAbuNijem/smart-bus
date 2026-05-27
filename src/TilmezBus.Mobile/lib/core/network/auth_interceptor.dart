import 'dart:async';

import 'package:dio/dio.dart';

import 'package:tilmez_bus/core/config/env.dart';
import 'package:tilmez_bus/core/storage/secure_storage.dart';

/// Attaches the JWT bearer token to every outgoing request and, on 401,
/// transparently exchanges the stored refresh token for a fresh pair via
/// `/auth/refresh` and retries the original request. When the refresh
/// itself fails (expired / revoked / network error), it clears auth
/// state and calls [onUnauthorized] so the router can send the user back
/// to the OTP screen.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage, {required this.onUnauthorized})
      : _refreshDio = Dio(
          BaseOptions(
            baseUrl: '${Env.apiBaseUrl}/api/${Env.apiVersion}',
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        );

  final SecureStorage _storage;
  final Future<void> Function() onUnauthorized;

  /// Plain Dio (no interceptors) used to call `/auth/refresh` — avoids
  /// the main Dio's interceptor stack so we don't recurse if refresh
  /// itself happens to return 401.
  final Dio _refreshDio;

  /// While a refresh is in flight, every other 401-er joins this future
  /// instead of issuing a parallel refresh that would invalidate the
  /// just-rotated token.
  Future<String?>? _inFlightRefresh;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only handle 401 from non-refresh requests. A 401 on /auth/refresh
    // means the refresh token itself is dead — let it propagate as the
    // sign-out signal.
    final path = err.requestOptions.path;
    if (err.response?.statusCode != 401 || path.contains('/auth/refresh')) {
      return handler.next(err);
    }
    // Don't retry the same request twice on auth failure.
    if (err.requestOptions.extra['retried_after_refresh'] == true) {
      await _signOut();
      return handler.next(err);
    }

    final newAccess = await _refreshOnce();
    if (newAccess == null) {
      await _signOut();
      return handler.next(err);
    }

    // Replay the original request with the new token attached.
    final retryOptions = err.requestOptions
      ..headers['Authorization'] = 'Bearer $newAccess'
      ..extra['retried_after_refresh'] = true;
    try {
      final response = await _refreshDio.fetch<dynamic>(retryOptions);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  /// Coalesces concurrent 401s into a single refresh call. Returns the
  /// new access token on success, null on failure.
  Future<String?> _refreshOnce() {
    return _inFlightRefresh ??= _doRefresh().whenComplete(
      () => _inFlightRefresh = null,
    );
  }

  Future<String?> _doRefresh() async {
    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return null;
    try {
      final resp = await _refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final data = resp.data;
      if (data == null) return null;
      final newAccess = data['token'] as String?;
      final newRefresh = data['refreshToken'] as String?;
      final expiresAtRaw = data['expiresAt'] as String?;
      if (newAccess == null || newRefresh == null) return null;
      await _storage.writeAccessToken(newAccess);
      await _storage.writeRefreshToken(newRefresh);
      if (expiresAtRaw != null) {
        final expiresAt = DateTime.tryParse(expiresAtRaw);
        if (expiresAt != null) await _storage.writeTokenExpiresAt(expiresAt);
      }
      return newAccess;
    } on DioException {
      return null;
    }
  }

  Future<void> _signOut() async {
    await _storage.clearAuth();
    await onUnauthorized();
  }
}
