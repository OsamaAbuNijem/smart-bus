import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tilmez_bus/core/location/current_location.dart';
import 'package:tilmez_bus/features/assistant/data/datasources/assistant_remote_datasource.dart';
import 'package:tilmez_bus/features/assistant/data/models/trip_details_dto.dart'
    show TripDetailsDto;

/// Trip details (header + roster), keyed by tripId.
final tripDetailsProvider =
    FutureProvider.autoDispose.family<TripDetailsDto, String>(
  (ref, tripId) async {
    final ds = ref.watch(assistantRemoteDataSourceProvider);
    return ds.getTripDetails(tripId);
  },
);

/// Imperative actions for the live trip screen.
class TripActionsController {
  const TripActionsController(this._ref, this._tripId);
  final Ref _ref;
  final String _tripId;

  Future<void> setBoarding({
    required String studentId,
    required String status,
  }) async {
    final ds = _ref.read(assistantRemoteDataSourceProvider);
    final loc = status == 'Boarded'
        ? await const CurrentLocation().tryFetch()
        : null;
    await ds.updateBoarding(
      tripId: _tripId,
      studentId: studentId,
      status: status,
      boardingTime: status == 'Boarded' ? DateTime.now().toUtc() : null,
      latitude: loc?.latitude,
      longitude: loc?.longitude,
    );
    _ref.invalidate(tripDetailsProvider(_tripId));
  }

  /// Scan a student onto the trip. Returns the student's full name from
  /// the server response so callers can render an immediate confirmation
  /// banner. The trip-details provider is invalidated so the roster UI
  /// refreshes in the background.
  Future<String?> scanStudent(String qrToken) async {
    final ds = _ref.read(assistantRemoteDataSourceProvider);
    final loc = await const CurrentLocation().tryFetch();
    final name = await ds.scanStudent(
      tripId: _tripId,
      qrToken: qrToken,
      latitude: loc?.latitude,
      longitude: loc?.longitude,
    );
    _ref.invalidate(tripDetailsProvider(_tripId));
    return name;
  }

  Future<void> notifyArrived(String studentId) async {
    final ds = _ref.read(assistantRemoteDataSourceProvider);
    await ds.notifyParentArrived(studentId);
  }
}

final tripActionsProvider =
    Provider.family<TripActionsController, String>(
  (ref, tripId) => TripActionsController(ref, tripId),
);
