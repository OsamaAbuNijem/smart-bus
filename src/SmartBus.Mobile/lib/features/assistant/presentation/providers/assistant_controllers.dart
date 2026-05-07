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

/// Buses dropdown (manual setup).
final busesListProvider = FutureProvider<List<BusSummaryDto>>(
  (ref) async {
    final ds = ref.watch(assistantRemoteDataSourceProvider);
    return ds.getBuses();
  },
);

/// Drivers dropdown (DriverType=Driver only).
final driversListProvider = FutureProvider<List<DriverSummaryDto>>(
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
    })>((ref) {
  return ({
    required String busId,
    required String driverId,
    required String tripType,
  }) async {
    final ds = ref.read(assistantRemoteDataSourceProvider);
    final result = await ds.startTrip(
      busId: busId,
      driverId: driverId,
      tripType: tripType,
    );
    ref.invalidate(myTodayTripsProvider);
    return result;
  };
});

/// Roster for a given trip id (used after Start trip).
final tripStudentsProvider =
    FutureProvider.autoDispose.family<List<TripStudentDto>, String>(
  (ref, tripId) async {
    final ds = ref.watch(assistantRemoteDataSourceProvider);
    return ds.getTripStudents(tripId);
  },
);
