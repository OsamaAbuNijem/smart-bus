import 'package:freezed_annotation/freezed_annotation.dart';

part 'live_tracking_dto.freezed.dart';
part 'live_tracking_dto.g.dart';

@freezed
abstract class LiveTrackingDto with _$LiveTrackingDto {
  const factory LiveTrackingDto({
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
    BusLocationDto? busLocation,
    String? driverName,
    String? driverPhone,
    String? assistantName,
    String? assistantPhone,
    required String studentFullName,
    double? homeLatitude,
    double? homeLongitude,
    String? homeAddress,
    String? schoolName,
  }) = _LiveTrackingDto;

  factory LiveTrackingDto.fromJson(Map<String, dynamic> json) =>
      _$LiveTrackingDtoFromJson(json);
}

@freezed
abstract class BusLocationDto with _$BusLocationDto {
  const factory BusLocationDto({
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
    required DateTime timestamp,
  }) = _BusLocationDto;

  factory BusLocationDto.fromJson(Map<String, dynamic> json) =>
      _$BusLocationDtoFromJson(json);
}
