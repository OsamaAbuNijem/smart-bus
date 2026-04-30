// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'child_trip_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChildTripDto {

 String get tripId; String get tripType; DateTime get tripDate; String get busPlateNumber; String? get driverName; String? get assistantName; String? get routeName; String get pickupStopName; String get dropoffStopName; DateTime get scheduledDeparture; DateTime? get actualDeparture; DateTime? get actualArrival; DateTime? get boardingTime; DateTime? get dropoffTime; String get boardingStatus; String get tripStatus; int? get durationMinutes; int? get delayMinutes; String get resultTag;
/// Create a copy of ChildTripDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChildTripDtoCopyWith<ChildTripDto> get copyWith => _$ChildTripDtoCopyWithImpl<ChildTripDto>(this as ChildTripDto, _$identity);

  /// Serializes this ChildTripDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChildTripDto&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.tripType, tripType) || other.tripType == tripType)&&(identical(other.tripDate, tripDate) || other.tripDate == tripDate)&&(identical(other.busPlateNumber, busPlateNumber) || other.busPlateNumber == busPlateNumber)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.assistantName, assistantName) || other.assistantName == assistantName)&&(identical(other.routeName, routeName) || other.routeName == routeName)&&(identical(other.pickupStopName, pickupStopName) || other.pickupStopName == pickupStopName)&&(identical(other.dropoffStopName, dropoffStopName) || other.dropoffStopName == dropoffStopName)&&(identical(other.scheduledDeparture, scheduledDeparture) || other.scheduledDeparture == scheduledDeparture)&&(identical(other.actualDeparture, actualDeparture) || other.actualDeparture == actualDeparture)&&(identical(other.actualArrival, actualArrival) || other.actualArrival == actualArrival)&&(identical(other.boardingTime, boardingTime) || other.boardingTime == boardingTime)&&(identical(other.dropoffTime, dropoffTime) || other.dropoffTime == dropoffTime)&&(identical(other.boardingStatus, boardingStatus) || other.boardingStatus == boardingStatus)&&(identical(other.tripStatus, tripStatus) || other.tripStatus == tripStatus)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.delayMinutes, delayMinutes) || other.delayMinutes == delayMinutes)&&(identical(other.resultTag, resultTag) || other.resultTag == resultTag));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,tripId,tripType,tripDate,busPlateNumber,driverName,assistantName,routeName,pickupStopName,dropoffStopName,scheduledDeparture,actualDeparture,actualArrival,boardingTime,dropoffTime,boardingStatus,tripStatus,durationMinutes,delayMinutes,resultTag]);

@override
String toString() {
  return 'ChildTripDto(tripId: $tripId, tripType: $tripType, tripDate: $tripDate, busPlateNumber: $busPlateNumber, driverName: $driverName, assistantName: $assistantName, routeName: $routeName, pickupStopName: $pickupStopName, dropoffStopName: $dropoffStopName, scheduledDeparture: $scheduledDeparture, actualDeparture: $actualDeparture, actualArrival: $actualArrival, boardingTime: $boardingTime, dropoffTime: $dropoffTime, boardingStatus: $boardingStatus, tripStatus: $tripStatus, durationMinutes: $durationMinutes, delayMinutes: $delayMinutes, resultTag: $resultTag)';
}


}

/// @nodoc
abstract mixin class $ChildTripDtoCopyWith<$Res>  {
  factory $ChildTripDtoCopyWith(ChildTripDto value, $Res Function(ChildTripDto) _then) = _$ChildTripDtoCopyWithImpl;
@useResult
$Res call({
 String tripId, String tripType, DateTime tripDate, String busPlateNumber, String? driverName, String? assistantName, String? routeName, String pickupStopName, String dropoffStopName, DateTime scheduledDeparture, DateTime? actualDeparture, DateTime? actualArrival, DateTime? boardingTime, DateTime? dropoffTime, String boardingStatus, String tripStatus, int? durationMinutes, int? delayMinutes, String resultTag
});




}
/// @nodoc
class _$ChildTripDtoCopyWithImpl<$Res>
    implements $ChildTripDtoCopyWith<$Res> {
  _$ChildTripDtoCopyWithImpl(this._self, this._then);

  final ChildTripDto _self;
  final $Res Function(ChildTripDto) _then;

/// Create a copy of ChildTripDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tripId = null,Object? tripType = null,Object? tripDate = null,Object? busPlateNumber = null,Object? driverName = freezed,Object? assistantName = freezed,Object? routeName = freezed,Object? pickupStopName = null,Object? dropoffStopName = null,Object? scheduledDeparture = null,Object? actualDeparture = freezed,Object? actualArrival = freezed,Object? boardingTime = freezed,Object? dropoffTime = freezed,Object? boardingStatus = null,Object? tripStatus = null,Object? durationMinutes = freezed,Object? delayMinutes = freezed,Object? resultTag = null,}) {
  return _then(_self.copyWith(
tripId: null == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String,tripType: null == tripType ? _self.tripType : tripType // ignore: cast_nullable_to_non_nullable
as String,tripDate: null == tripDate ? _self.tripDate : tripDate // ignore: cast_nullable_to_non_nullable
as DateTime,busPlateNumber: null == busPlateNumber ? _self.busPlateNumber : busPlateNumber // ignore: cast_nullable_to_non_nullable
as String,driverName: freezed == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String?,assistantName: freezed == assistantName ? _self.assistantName : assistantName // ignore: cast_nullable_to_non_nullable
as String?,routeName: freezed == routeName ? _self.routeName : routeName // ignore: cast_nullable_to_non_nullable
as String?,pickupStopName: null == pickupStopName ? _self.pickupStopName : pickupStopName // ignore: cast_nullable_to_non_nullable
as String,dropoffStopName: null == dropoffStopName ? _self.dropoffStopName : dropoffStopName // ignore: cast_nullable_to_non_nullable
as String,scheduledDeparture: null == scheduledDeparture ? _self.scheduledDeparture : scheduledDeparture // ignore: cast_nullable_to_non_nullable
as DateTime,actualDeparture: freezed == actualDeparture ? _self.actualDeparture : actualDeparture // ignore: cast_nullable_to_non_nullable
as DateTime?,actualArrival: freezed == actualArrival ? _self.actualArrival : actualArrival // ignore: cast_nullable_to_non_nullable
as DateTime?,boardingTime: freezed == boardingTime ? _self.boardingTime : boardingTime // ignore: cast_nullable_to_non_nullable
as DateTime?,dropoffTime: freezed == dropoffTime ? _self.dropoffTime : dropoffTime // ignore: cast_nullable_to_non_nullable
as DateTime?,boardingStatus: null == boardingStatus ? _self.boardingStatus : boardingStatus // ignore: cast_nullable_to_non_nullable
as String,tripStatus: null == tripStatus ? _self.tripStatus : tripStatus // ignore: cast_nullable_to_non_nullable
as String,durationMinutes: freezed == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int?,delayMinutes: freezed == delayMinutes ? _self.delayMinutes : delayMinutes // ignore: cast_nullable_to_non_nullable
as int?,resultTag: null == resultTag ? _self.resultTag : resultTag // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ChildTripDto].
extension ChildTripDtoPatterns on ChildTripDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChildTripDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChildTripDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChildTripDto value)  $default,){
final _that = this;
switch (_that) {
case _ChildTripDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChildTripDto value)?  $default,){
final _that = this;
switch (_that) {
case _ChildTripDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String tripId,  String tripType,  DateTime tripDate,  String busPlateNumber,  String? driverName,  String? assistantName,  String? routeName,  String pickupStopName,  String dropoffStopName,  DateTime scheduledDeparture,  DateTime? actualDeparture,  DateTime? actualArrival,  DateTime? boardingTime,  DateTime? dropoffTime,  String boardingStatus,  String tripStatus,  int? durationMinutes,  int? delayMinutes,  String resultTag)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChildTripDto() when $default != null:
return $default(_that.tripId,_that.tripType,_that.tripDate,_that.busPlateNumber,_that.driverName,_that.assistantName,_that.routeName,_that.pickupStopName,_that.dropoffStopName,_that.scheduledDeparture,_that.actualDeparture,_that.actualArrival,_that.boardingTime,_that.dropoffTime,_that.boardingStatus,_that.tripStatus,_that.durationMinutes,_that.delayMinutes,_that.resultTag);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String tripId,  String tripType,  DateTime tripDate,  String busPlateNumber,  String? driverName,  String? assistantName,  String? routeName,  String pickupStopName,  String dropoffStopName,  DateTime scheduledDeparture,  DateTime? actualDeparture,  DateTime? actualArrival,  DateTime? boardingTime,  DateTime? dropoffTime,  String boardingStatus,  String tripStatus,  int? durationMinutes,  int? delayMinutes,  String resultTag)  $default,) {final _that = this;
switch (_that) {
case _ChildTripDto():
return $default(_that.tripId,_that.tripType,_that.tripDate,_that.busPlateNumber,_that.driverName,_that.assistantName,_that.routeName,_that.pickupStopName,_that.dropoffStopName,_that.scheduledDeparture,_that.actualDeparture,_that.actualArrival,_that.boardingTime,_that.dropoffTime,_that.boardingStatus,_that.tripStatus,_that.durationMinutes,_that.delayMinutes,_that.resultTag);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String tripId,  String tripType,  DateTime tripDate,  String busPlateNumber,  String? driverName,  String? assistantName,  String? routeName,  String pickupStopName,  String dropoffStopName,  DateTime scheduledDeparture,  DateTime? actualDeparture,  DateTime? actualArrival,  DateTime? boardingTime,  DateTime? dropoffTime,  String boardingStatus,  String tripStatus,  int? durationMinutes,  int? delayMinutes,  String resultTag)?  $default,) {final _that = this;
switch (_that) {
case _ChildTripDto() when $default != null:
return $default(_that.tripId,_that.tripType,_that.tripDate,_that.busPlateNumber,_that.driverName,_that.assistantName,_that.routeName,_that.pickupStopName,_that.dropoffStopName,_that.scheduledDeparture,_that.actualDeparture,_that.actualArrival,_that.boardingTime,_that.dropoffTime,_that.boardingStatus,_that.tripStatus,_that.durationMinutes,_that.delayMinutes,_that.resultTag);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChildTripDto implements ChildTripDto {
  const _ChildTripDto({required this.tripId, required this.tripType, required this.tripDate, required this.busPlateNumber, this.driverName, this.assistantName, this.routeName, required this.pickupStopName, required this.dropoffStopName, required this.scheduledDeparture, this.actualDeparture, this.actualArrival, this.boardingTime, this.dropoffTime, required this.boardingStatus, required this.tripStatus, this.durationMinutes, this.delayMinutes, required this.resultTag});
  factory _ChildTripDto.fromJson(Map<String, dynamic> json) => _$ChildTripDtoFromJson(json);

@override final  String tripId;
@override final  String tripType;
@override final  DateTime tripDate;
@override final  String busPlateNumber;
@override final  String? driverName;
@override final  String? assistantName;
@override final  String? routeName;
@override final  String pickupStopName;
@override final  String dropoffStopName;
@override final  DateTime scheduledDeparture;
@override final  DateTime? actualDeparture;
@override final  DateTime? actualArrival;
@override final  DateTime? boardingTime;
@override final  DateTime? dropoffTime;
@override final  String boardingStatus;
@override final  String tripStatus;
@override final  int? durationMinutes;
@override final  int? delayMinutes;
@override final  String resultTag;

/// Create a copy of ChildTripDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChildTripDtoCopyWith<_ChildTripDto> get copyWith => __$ChildTripDtoCopyWithImpl<_ChildTripDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChildTripDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChildTripDto&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.tripType, tripType) || other.tripType == tripType)&&(identical(other.tripDate, tripDate) || other.tripDate == tripDate)&&(identical(other.busPlateNumber, busPlateNumber) || other.busPlateNumber == busPlateNumber)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.assistantName, assistantName) || other.assistantName == assistantName)&&(identical(other.routeName, routeName) || other.routeName == routeName)&&(identical(other.pickupStopName, pickupStopName) || other.pickupStopName == pickupStopName)&&(identical(other.dropoffStopName, dropoffStopName) || other.dropoffStopName == dropoffStopName)&&(identical(other.scheduledDeparture, scheduledDeparture) || other.scheduledDeparture == scheduledDeparture)&&(identical(other.actualDeparture, actualDeparture) || other.actualDeparture == actualDeparture)&&(identical(other.actualArrival, actualArrival) || other.actualArrival == actualArrival)&&(identical(other.boardingTime, boardingTime) || other.boardingTime == boardingTime)&&(identical(other.dropoffTime, dropoffTime) || other.dropoffTime == dropoffTime)&&(identical(other.boardingStatus, boardingStatus) || other.boardingStatus == boardingStatus)&&(identical(other.tripStatus, tripStatus) || other.tripStatus == tripStatus)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.delayMinutes, delayMinutes) || other.delayMinutes == delayMinutes)&&(identical(other.resultTag, resultTag) || other.resultTag == resultTag));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,tripId,tripType,tripDate,busPlateNumber,driverName,assistantName,routeName,pickupStopName,dropoffStopName,scheduledDeparture,actualDeparture,actualArrival,boardingTime,dropoffTime,boardingStatus,tripStatus,durationMinutes,delayMinutes,resultTag]);

@override
String toString() {
  return 'ChildTripDto(tripId: $tripId, tripType: $tripType, tripDate: $tripDate, busPlateNumber: $busPlateNumber, driverName: $driverName, assistantName: $assistantName, routeName: $routeName, pickupStopName: $pickupStopName, dropoffStopName: $dropoffStopName, scheduledDeparture: $scheduledDeparture, actualDeparture: $actualDeparture, actualArrival: $actualArrival, boardingTime: $boardingTime, dropoffTime: $dropoffTime, boardingStatus: $boardingStatus, tripStatus: $tripStatus, durationMinutes: $durationMinutes, delayMinutes: $delayMinutes, resultTag: $resultTag)';
}


}

/// @nodoc
abstract mixin class _$ChildTripDtoCopyWith<$Res> implements $ChildTripDtoCopyWith<$Res> {
  factory _$ChildTripDtoCopyWith(_ChildTripDto value, $Res Function(_ChildTripDto) _then) = __$ChildTripDtoCopyWithImpl;
@override @useResult
$Res call({
 String tripId, String tripType, DateTime tripDate, String busPlateNumber, String? driverName, String? assistantName, String? routeName, String pickupStopName, String dropoffStopName, DateTime scheduledDeparture, DateTime? actualDeparture, DateTime? actualArrival, DateTime? boardingTime, DateTime? dropoffTime, String boardingStatus, String tripStatus, int? durationMinutes, int? delayMinutes, String resultTag
});




}
/// @nodoc
class __$ChildTripDtoCopyWithImpl<$Res>
    implements _$ChildTripDtoCopyWith<$Res> {
  __$ChildTripDtoCopyWithImpl(this._self, this._then);

  final _ChildTripDto _self;
  final $Res Function(_ChildTripDto) _then;

/// Create a copy of ChildTripDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tripId = null,Object? tripType = null,Object? tripDate = null,Object? busPlateNumber = null,Object? driverName = freezed,Object? assistantName = freezed,Object? routeName = freezed,Object? pickupStopName = null,Object? dropoffStopName = null,Object? scheduledDeparture = null,Object? actualDeparture = freezed,Object? actualArrival = freezed,Object? boardingTime = freezed,Object? dropoffTime = freezed,Object? boardingStatus = null,Object? tripStatus = null,Object? durationMinutes = freezed,Object? delayMinutes = freezed,Object? resultTag = null,}) {
  return _then(_ChildTripDto(
tripId: null == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String,tripType: null == tripType ? _self.tripType : tripType // ignore: cast_nullable_to_non_nullable
as String,tripDate: null == tripDate ? _self.tripDate : tripDate // ignore: cast_nullable_to_non_nullable
as DateTime,busPlateNumber: null == busPlateNumber ? _self.busPlateNumber : busPlateNumber // ignore: cast_nullable_to_non_nullable
as String,driverName: freezed == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String?,assistantName: freezed == assistantName ? _self.assistantName : assistantName // ignore: cast_nullable_to_non_nullable
as String?,routeName: freezed == routeName ? _self.routeName : routeName // ignore: cast_nullable_to_non_nullable
as String?,pickupStopName: null == pickupStopName ? _self.pickupStopName : pickupStopName // ignore: cast_nullable_to_non_nullable
as String,dropoffStopName: null == dropoffStopName ? _self.dropoffStopName : dropoffStopName // ignore: cast_nullable_to_non_nullable
as String,scheduledDeparture: null == scheduledDeparture ? _self.scheduledDeparture : scheduledDeparture // ignore: cast_nullable_to_non_nullable
as DateTime,actualDeparture: freezed == actualDeparture ? _self.actualDeparture : actualDeparture // ignore: cast_nullable_to_non_nullable
as DateTime?,actualArrival: freezed == actualArrival ? _self.actualArrival : actualArrival // ignore: cast_nullable_to_non_nullable
as DateTime?,boardingTime: freezed == boardingTime ? _self.boardingTime : boardingTime // ignore: cast_nullable_to_non_nullable
as DateTime?,dropoffTime: freezed == dropoffTime ? _self.dropoffTime : dropoffTime // ignore: cast_nullable_to_non_nullable
as DateTime?,boardingStatus: null == boardingStatus ? _self.boardingStatus : boardingStatus // ignore: cast_nullable_to_non_nullable
as String,tripStatus: null == tripStatus ? _self.tripStatus : tripStatus // ignore: cast_nullable_to_non_nullable
as String,durationMinutes: freezed == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int?,delayMinutes: freezed == delayMinutes ? _self.delayMinutes : delayMinutes // ignore: cast_nullable_to_non_nullable
as int?,resultTag: null == resultTag ? _self.resultTag : resultTag // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
