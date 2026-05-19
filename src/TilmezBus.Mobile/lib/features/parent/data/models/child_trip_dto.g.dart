// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_trip_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChildTripDto _$ChildTripDtoFromJson(Map<String, dynamic> json) =>
    _ChildTripDto(
      tripId: json['tripId'] as String,
      tripType: json['tripType'] as String,
      tripDate: DateTime.parse(json['tripDate'] as String),
      busPlateNumber: json['busPlateNumber'] as String,
      driverName: json['driverName'] as String?,
      assistantName: json['assistantName'] as String?,
      routeName: json['routeName'] as String?,
      pickupStopName: json['pickupStopName'] as String,
      dropoffStopName: json['dropoffStopName'] as String,
      scheduledDeparture: DateTime.parse(json['scheduledDeparture'] as String),
      actualDeparture: json['actualDeparture'] == null
          ? null
          : DateTime.parse(json['actualDeparture'] as String),
      actualArrival: json['actualArrival'] == null
          ? null
          : DateTime.parse(json['actualArrival'] as String),
      boardingTime: json['boardingTime'] == null
          ? null
          : DateTime.parse(json['boardingTime'] as String),
      dropoffTime: json['dropoffTime'] == null
          ? null
          : DateTime.parse(json['dropoffTime'] as String),
      boardingStatus: json['boardingStatus'] as String,
      tripStatus: json['tripStatus'] as String,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      delayMinutes: (json['delayMinutes'] as num?)?.toInt(),
      resultTag: json['resultTag'] as String,
    );

Map<String, dynamic> _$ChildTripDtoToJson(_ChildTripDto instance) =>
    <String, dynamic>{
      'tripId': instance.tripId,
      'tripType': instance.tripType,
      'tripDate': instance.tripDate.toIso8601String(),
      'busPlateNumber': instance.busPlateNumber,
      if (instance.driverName case final value?) 'driverName': value,
      if (instance.assistantName case final value?) 'assistantName': value,
      if (instance.routeName case final value?) 'routeName': value,
      'pickupStopName': instance.pickupStopName,
      'dropoffStopName': instance.dropoffStopName,
      'scheduledDeparture': instance.scheduledDeparture.toIso8601String(),
      if (instance.actualDeparture?.toIso8601String() case final value?)
        'actualDeparture': value,
      if (instance.actualArrival?.toIso8601String() case final value?)
        'actualArrival': value,
      if (instance.boardingTime?.toIso8601String() case final value?)
        'boardingTime': value,
      if (instance.dropoffTime?.toIso8601String() case final value?)
        'dropoffTime': value,
      'boardingStatus': instance.boardingStatus,
      'tripStatus': instance.tripStatus,
      if (instance.durationMinutes case final value?) 'durationMinutes': value,
      if (instance.delayMinutes case final value?) 'delayMinutes': value,
      'resultTag': instance.resultTag,
    };
