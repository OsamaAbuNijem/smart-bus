/// User-facing failure type produced by the data layer for the presentation
/// layer to render. Keep messages short; rely on l10n for actual UI strings.
sealed class Failure implements Exception {
  const Failure(this.message);
  final String message;

  @override
  String toString() => '$runtimeType($message)';
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'network_error']);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'timeout']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'unauthorized']);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message = 'forbidden']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'not_found']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'server_error', this.statusCode]);
  final int? statusCode;
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, [this.fieldErrors = const {}]);
  final Map<String, List<String>> fieldErrors;
}

class CancelledFailure extends Failure {
  const CancelledFailure() : super('cancelled');
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'unknown_error']);
}
