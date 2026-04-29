import 'package:dio/dio.dart';

import 'package:smart_bus/core/storage/secure_storage.dart';

/// Attaches the JWT bearer token to every outgoing request and forces
/// re-authentication when the server returns 401.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage, {required this.onUnauthorized});

  final SecureStorage _storage;
  final Future<void> Function() onUnauthorized;

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
    if (err.response?.statusCode == 401) {
      // Token is single-use (24h). No refresh endpoint, so just clear and
      // let the router redirect to /login.
      await _storage.clearAuth();
      await onUnauthorized();
    }
    handler.next(err);
  }
}
