import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:smart_bus/core/config/env.dart';
import 'package:smart_bus/core/network/auth_interceptor.dart';
import 'package:smart_bus/core/storage/secure_storage.dart';

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
      // Don't auto-throw on 4xx so interceptors / mappers can inspect bodies.
      validateStatus: (code) => code != null && code < 500,
    ),
  );

  dio.interceptors.add(
    AuthInterceptor(
      storage,
      onUnauthorized: () async {
        // Hook for the router to listen via authControllerProvider.
        // Clearing storage already happened inside the interceptor.
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
