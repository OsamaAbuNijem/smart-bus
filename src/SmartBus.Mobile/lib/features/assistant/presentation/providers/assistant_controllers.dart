import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smart_bus/features/assistant/data/datasources/assistant_remote_datasource.dart';
import 'package:smart_bus/features/assistant/data/models/bus_summary_dto.dart';
import 'package:smart_bus/features/assistant/data/models/driver_summary_dto.dart';
import 'package:smart_bus/features/assistant/data/models/my_today_trip_dto.dart';
import 'package:smart_bus/features/assistant/data/models/roster_student_dto.dart';
import 'package:smart_bus/features/assistant/data/models/start_trip_response_dto.dart';
import 'package:smart_bus/features/assistant/data/models/trip_student_dto.dart';

/// Today's trips for the current driver/assistant.
final myTodayTripsProvider = FutureProvider.autoDispose<List<MyTodayTripDto>>(
  (ref) async {
    final ds = ref.watch(assistantRemoteDataSourceProvider);
    return ds.getMyTodayTrips();
  },
);

/// Buses dropdown (manual setup). autoDispose so the list refetches on each
/// new-trip entry instead of caching stale rows across login sessions —
/// otherwise a soft-deleted bus or a school swap leaks into the picker.
final busesListProvider = FutureProvider.autoDispose<List<BusSummaryDto>>(
  (ref) async {
    final ds = ref.watch(assistantRemoteDataSourceProvider);
    return ds.getBuses();
  },
);

/// Drivers dropdown (DriverType=Driver only). autoDispose for the same
/// reason as [busesListProvider] — stale rows must not survive logout.
final driversListProvider = FutureProvider.autoDispose<List<DriverSummaryDto>>(
  (ref) async {
    final ds = ref.watch(assistantRemoteDataSourceProvider);
    return ds.getDrivers();
  },
);

/// Students preview based on last trip for (bus, type).
final lastRosterProvider = FutureProvider.autoDispose
    .family<List<RosterStudentDto>, ({String busId, String tripType})>(
  (ref, key) async {
    final ds = ref.watch(assistantRemoteDataSourceProvider);
    return ds.getLastRoster(busId: key.busId, tripType: key.tripType);
  },
);

/// Default driver for the chosen (bus, type), taken from the bus schedule.
/// The trip-setup screen uses this to pre-fill the driver picker so the
/// assistant doesn't have to choose from the full list every time.
final busDefaultDriverProvider = FutureProvider.autoDispose
    .family<DriverSummaryDto?, ({String busId, String tripType})>(
  (ref, key) async {
    final ds = ref.watch(assistantRemoteDataSourceProvider);
    return ds.getDefaultDriver(busId: key.busId, tripType: key.tripType);
  },
);

/// Holds the bus that was resolved from the latest QR scan, so the setup
/// screen can render it as the "From QR" chip. Cleared on back/start trip.
class ScannedBusController extends StateNotifier<AsyncValue<BusSummaryDto?>> {
  ScannedBusController(this._ds) : super(const AsyncValue.data(null));
  final AssistantRemoteDataSource _ds;

  Future<BusSummaryDto?> resolveQr(String qrToken) async {
    state = const AsyncValue.loading();
    try {
      final bus = await _ds.getBusByQr(qrToken);
      state = AsyncValue.data(bus);
      return bus;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  void clear() => state = const AsyncValue.data(null);
}

final scannedBusControllerProvider =
    StateNotifierProvider<ScannedBusController, AsyncValue<BusSummaryDto?>>(
  (ref) => ScannedBusController(ref.watch(assistantRemoteDataSourceProvider)),
);

/// Imperative "create + start trip" action.
final startTripActionProvider = Provider<
    Future<StartTripResponseDto> Function({
      required String busId,
      required String driverId,
      required String tripType,
      bool skipRoster,
      List<String>? manualStudentIds,
      bool scheduled,
    })>((ref) {
  return ({
    required String busId,
    required String driverId,
    required String tripType,
    bool skipRoster = false,
    List<String>? manualStudentIds,
    bool scheduled = false,
  }) async {
    final ds = ref.read(assistantRemoteDataSourceProvider);
    final result = await ds.startTrip(
      busId: busId,
      driverId: driverId,
      tripType: tripType,
      skipRoster: skipRoster,
      manualStudentIds: manualStudentIds,
      scheduled: scheduled,
    );
    ref.invalidate(myTodayTripsProvider);
    return result;
  };
});

/// Step-2 "go live" action — flip a Scheduled trip to InProgress.
final activateTripActionProvider =
    Provider<Future<void> Function(String tripId)>((ref) {
  return (String tripId) async {
    final ds = ref.read(assistantRemoteDataSourceProvider);
    await ds.activateTrip(tripId);
    ref.invalidate(myTodayTripsProvider);
  };
});

/// Cancel a Scheduled trip from the assistant. Server rejects this for
/// non-Scheduled statuses — assistants can't wipe live or completed trips.
final deleteScheduledTripActionProvider =
    Provider<Future<void> Function(String tripId)>((ref) {
  return (String tripId) async {
    final ds = ref.read(assistantRemoteDataSourceProvider);
    await ds.deleteScheduledTrip(tripId);
    ref.invalidate(myTodayTripsProvider);
  };
});

/// Student-name search (debounced live filter for the manual-roster picker).
/// autoDispose so the cache turns over when the user leaves the screen.
final studentSearchProvider = FutureProvider.autoDispose
    .family<List<RosterStudentDto>, String>((ref, query) async {
  // Empty query short-circuits to "show some" rather than a noisy full list.
  if (query.trim().isEmpty) return const [];
  final ds = ref.watch(assistantRemoteDataSourceProvider);
  return ds.searchStudents(query);
});

/// Roster for a given trip id (used after Start trip).
final tripStudentsProvider =
    FutureProvider.autoDispose.family<List<TripStudentDto>, String>(
  (ref, tripId) async {
    final ds = ref.watch(assistantRemoteDataSourceProvider);
    return ds.getTripStudents(tripId);
  },
);
