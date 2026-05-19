import 'package:dio/dio.dart';

import 'package:tilmez_bus/core/errors/failures.dart';

/// Maps a low-level [DioException] (or anything else) to a [Failure].
/// Centralised here so every datasource produces the same Failure types.
Failure mapDioErrorToFailure(Object error) {
  if (error is! DioException) return const UnknownFailure();

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const TimeoutFailure();
    case DioExceptionType.connectionError:
      return const NetworkFailure();
    case DioExceptionType.cancel:
      return const CancelledFailure();
    case DioExceptionType.badCertificate:
      return const NetworkFailure('bad_certificate');
    case DioExceptionType.badResponse:
      final response = error.response;
      final status = response?.statusCode ?? 0;
      final body = response?.data;
      final serverMsg = _extractMessage(body);
      switch (status) {
        case 400:
          return ValidationFailure(
            serverMsg ?? 'bad_request',
            _extractFieldErrors(body),
          );
        case 401:
          return UnauthorizedFailure(serverMsg ?? 'unauthorized');
        case 403:
          return ForbiddenFailure(serverMsg ?? 'forbidden');
        case 404:
          return NotFoundFailure(serverMsg ?? 'not_found');
        case >= 500:
          return ServerFailure(serverMsg ?? 'server_error', status);
        default:
          return ServerFailure(serverMsg ?? 'http_$status', status);
      }
    case DioExceptionType.unknown:
      return const UnknownFailure();
  }
}

String? _extractMessage(Object? body) {
  if (body is Map) {
    final m = body['error'] ??
        body['Error'] ??
        body['message'] ??
        body['Message'] ??
        body['title'] ??
        body['Title'];
    if (m is String && m.isNotEmpty) return m;
  }
  return null;
}

Map<String, List<String>> _extractFieldErrors(Object? body) {
  // ASP.NET Core ProblemDetails / ValidationProblemDetails shape:
  // { "errors": { "Email": ["..."], "Password": ["..."] } }
  if (body is Map) {
    final errors = body['errors'] ?? body['Errors'];
    if (errors is Map) {
      return errors.map(
        (key, value) => MapEntry(
          key.toString(),
          (value as List?)?.map((e) => e.toString()).toList() ?? const [],
        ),
      );
    }
  }
  return const {};
}
