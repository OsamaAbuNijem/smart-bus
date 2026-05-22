import 'package:freezed_annotation/freezed_annotation.dart';

part 'child_trip.freezed.dart';

enum TripResultTag { onTime, late, absent, pending }

/// Mirrors the server's StudentTrip.BoardingStatus enum:
/// Waiting → bus hasn't picked the student up yet (or trip hasn't
/// started); Boarded → student is on the bus; DroppedOff → student
/// reached their destination (school on Morning, home on Return);
/// Absent → parent reported absence for the day.
enum BoardingStatus { waiting, boarded, droppedOff, absent }

enum TripPhase { scheduled, inProgress, completed }

extension TripResultTagX on TripResultTag {
  static TripResultTag fromApi(String value) => switch (value) {
        'OnTime' => TripResultTag.onTime,
        'Late' => TripResultTag.late,
        'Absent' => TripResultTag.absent,
        _ => TripResultTag.pending,
      };
}

extension BoardingStatusX on BoardingStatus {
  static BoardingStatus fromApi(String value) => switch (value) {
        'Boarded' => BoardingStatus.boarded,
        'DroppedOff' => BoardingStatus.droppedOff,
        'Absent' => BoardingStatus.absent,
        _ => BoardingStatus.waiting,
      };
}

extension TripPhaseX on TripPhase {
  static TripPhase fromApi(String value) => switch (value) {
        'InProgress' => TripPhase.inProgress,
        'Completed' => TripPhase.completed,
        _ => TripPhase.scheduled,
      };
}

@freezed
abstract class ChildTrip with _$ChildTrip {
  const factory ChildTrip({
    required String tripId,
    required String tripType, // "Morning" | "Return"
    required DateTime tripDate,
    required String busPlateNumber,
    String? driverName,
    String? assistantName,
    String? routeName,
    required String pickupStopName,
    required String dropoffStopName,
    required DateTime scheduledDeparture,
    DateTime? actualDeparture,
    DateTime? actualArrival,
    DateTime? boardingTime,
    DateTime? dropoffTime,
    required BoardingStatus boardingStatus,
    required TripPhase tripPhase,
    int? durationMinutes,
    int? delayMinutes,
    required TripResultTag resultTag,
  }) = _ChildTrip;
}
