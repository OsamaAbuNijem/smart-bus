import 'package:freezed_annotation/freezed_annotation.dart';

part 'live_tracking.freezed.dart';

@freezed
abstract class LiveTracking with _$LiveTracking {
  const factory LiveTracking({
    String? tripId,
    String? tripStatus,
    String? tripType,
    DateTime? scheduledDeparture,
    DateTime? actualDeparture,
    DateTime? actualArrival,
    DateTime? boardingTime,
    String? boardingStatus,
    String? busId,
    String? busPlateNumber,
    BusLocation? busLocation,
    String? driverName,
    String? driverPhone,
    String? assistantName,
    String? assistantPhone,
    required String studentFullName,
    double? homeLatitude,
    double? homeLongitude,
    String? homeAddress,
    String? schoolName,
    double? schoolLatitude,
    double? schoolLongitude,
  }) = _LiveTracking;
}

@freezed
abstract class BusLocation with _$BusLocation {
  const factory BusLocation({
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
    required DateTime timestamp,
  }) = _BusLocation;
}
