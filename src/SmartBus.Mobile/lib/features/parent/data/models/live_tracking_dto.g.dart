// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_tracking_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LiveTrackingDto _$LiveTrackingDtoFromJson(Map<String, dynamic> json) =>
    _LiveTrackingDto(
      tripId: json['tripId'] as String?,
      tripStatus: json['tripStatus'] as String?,
      tripType: json['tripType'] as String?,
      scheduledDeparture: json['scheduledDeparture'] == null
          ? null
          : DateTime.parse(json['scheduledDeparture'] as String),
      actualDeparture: json['actualDeparture'] == null
          ? null
          : DateTime.parse(json['actualDeparture'] as String),
      actualArrival: json['actualArrival'] == null
          ? null
          : DateTime.parse(json['actualArrival'] as String),
      boardingTime: json['boardingTime'] == null
          ? null
          : DateTime.parse(json['boardingTime'] as String),
      boardingStatus: json['boardingStatus'] as String?,
      busId: json['busId'] as String?,
      busPlateNumber: json['busPlateNumber'] as String?,
      busLocation: json['busLocation'] == null
          ? null
          : BusLocationDto.fromJson(
              json['busLocation'] as Map<String, dynamic>,
            ),
      driverName: json['driverName'] as String?,
      driverPhone: json['driverPhone'] as String?,
      assistantName: json['assistantName'] as String?,
      assistantPhone: json['assistantPhone'] as String?,
      studentFullName: json['studentFullName'] as String,
      homeLatitude: (json['homeLatitude'] as num?)?.toDouble(),
      homeLongitude: (json['homeLongitude'] as num?)?.toDouble(),
      homeAddress: json['homeAddress'] as String?,
      schoolName: json['schoolName'] as String?,
    );

Map<String, dynamic> _$LiveTrackingDtoToJson(
  _LiveTrackingDto instance,
) => <String, dynamic>{
  if (instance.tripId case final value?) 'tripId': value,
  if (instance.tripStatus case final value?) 'tripStatus': value,
  if (instance.tripType case final value?) 'tripType': value,
  if (instance.scheduledDeparture?.toIso8601String() case final value?)
    'scheduledDeparture': value,
  if (instance.actualDeparture?.toIso8601String() case final value?)
    'actualDeparture': value,
  if (instance.actualArrival?.toIso8601String() case final value?)
    'actualArrival': value,
  if (instance.boardingTime?.toIso8601String() case final value?)
    'boardingTime': value,
  if (instance.boardingStatus case final value?) 'boardingStatus': value,
  if (instance.busId case final value?) 'busId': value,
  if (instance.busPlateNumber case final value?) 'busPlateNumber': value,
  if (instance.busLocation?.toJson() case final value?) 'busLocation': value,
  if (instance.driverName case final value?) 'driverName': value,
  if (instance.driverPhone case final value?) 'driverPhone': value,
  if (instance.assistantName case final value?) 'assistantName': value,
  if (instance.assistantPhone case final value?) 'assistantPhone': value,
  'studentFullName': instance.studentFullName,
  if (instance.homeLatitude case final value?) 'homeLatitude': value,
  if (instance.homeLongitude case final value?) 'homeLongitude': value,
  if (instance.homeAddress case final value?) 'homeAddress': value,
  if (instance.schoolName case final value?) 'schoolName': value,
};

_BusLocationDto _$BusLocationDtoFromJson(Map<String, dynamic> json) =>
    _BusLocationDto(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
      heading: (json['heading'] as num?)?.toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$BusLocationDtoToJson(_BusLocationDto instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      if (instance.speed case final value?) 'speed': value,
      if (instance.heading case final value?) 'heading': value,
      'timestamp': instance.timestamp.toIso8601String(),
    };
