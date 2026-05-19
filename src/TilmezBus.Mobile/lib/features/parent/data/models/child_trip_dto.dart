import 'package:freezed_annotation/freezed_annotation.dart';

part 'child_trip_dto.freezed.dart';
part 'child_trip_dto.g.dart';

/// Mirrors `GET /api/v1/parents/{parentId}/students/{studentId}/trips`
/// response item.
@freezed
abstract class ChildTripDto with _$ChildTripDto {
  const factory ChildTripDto({
    required String tripId,
    required String tripType,
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
    required String boardingStatus,
    required String tripStatus,
    int? durationMinutes,
    int? delayMinutes,
    required String resultTag,
  }) = _ChildTripDto;

  factory ChildTripDto.fromJson(Map<String, dynamic> json) =>
      _$ChildTripDtoFromJson(json);
}
