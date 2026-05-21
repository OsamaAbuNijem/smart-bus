import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:tilmez_bus/core/config/env.dart';
import 'package:tilmez_bus/core/network/auth_interceptor.dart';
import 'package:tilmez_bus/core/storage/secure_storage.dart';
import 'package:tilmez_bus/features/auth/presentation/providers/auth_controller.dart';

part 'dio_client.g.dart';

/// The single Dio instance used by every datasource. Configured with the
/// API base URL, auth interceptor, and (in dev) a request/response logger.
@Riverpod(keepAlive: true)
Dio dioClient(Ref ref) {
  final storage = ref.watch(secureStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: '${Env.apiBaseUrl}/api/${Env.apiVersion}',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      // Default Dio behaviour: 2xx success, anything else throws DioException.
      // The mapper in api_exception.dart turns 4xx/5xx into typed Failures.
    ),
  );

  dio.interceptors.add(
    AuthInterceptor(
      storage,
      onUnauthorized: () async {
        // Storage is already cleared by the interceptor. Push that state
        // to the auth controller so the GoRouter's redirect rule fires
        // and the app navigates back to /login. Without this the user
        // is stuck on a screen that 401-loops every refresh.
        // invalidate() re-runs AuthController.build() which reads the
        // now-empty storage and emits AsyncData(null).
        ref.invalidate(authControllerProvider);
      },
    ),
  );

  if (Env.isDev) {
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: false,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        compact: true,
        maxWidth: 120,
      ),
    );
  }

  return dio;
}
