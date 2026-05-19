// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'child_trip.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChildTrip {

 String get tripId; String get tripType;// "Morning" | "Return"
 DateTime get tripDate; String get busPlateNumber; String? get driverName; String? get assistantName; String? get routeName; String get pickupStopName; String get dropoffStopName; DateTime get scheduledDeparture; DateTime? get actualDeparture; DateTime? get actualArrival; DateTime? get boardingTime; DateTime? get dropoffTime; BoardingStatus get boardingStatus; TripPhase get tripPhase; int? get durationMinutes; int? get delayMinutes; TripResultTag get resultTag;
/// Create a copy of ChildTrip
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChildTripCopyWith<ChildTrip> get copyWith => _$ChildTripCopyWithImpl<ChildTrip>(this as ChildTrip, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChildTrip&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.tripType, tripType) || other.tripType == tripType)&&(identical(other.tripDate, tripDate) || other.tripDate == tripDate)&&(identical(other.busPlateNumber, busPlateNumber) || other.busPlateNumber == busPlateNumber)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.assistantName, assistantName) || other.assistantName == assistantName)&&(identical(other.routeName, routeName) || other.routeName == routeName)&&(identical(other.pickupStopName, pickupStopName) || other.pickupStopName == pickupStopName)&&(identical(other.dropoffStopName, dropoffStopName) || other.dropoffStopName == dropoffStopName)&&(identical(other.scheduledDeparture, scheduledDeparture) || other.scheduledDeparture == scheduledDeparture)&&(identical(other.actualDeparture, actualDeparture) || other.actualDeparture == actualDeparture)&&(identical(other.actualArrival, actualArrival) || other.actualArrival == actualArrival)&&(identical(other.boardingTime, boardingTime) || other.boardingTime == boardingTime)&&(identical(other.dropoffTime, dropoffTime) || other.dropoffTime == dropoffTime)&&(identical(other.boardingStatus, boardingStatus) || other.boardingStatus == boardingStatus)&&(identical(other.tripPhase, tripPhase) || other.tripPhase == tripPhase)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.delayMinutes, delayMinutes) || other.delayMinutes == delayMinutes)&&(identical(other.resultTag, resultTag) || other.resultTag == resultTag));
}


@override
int get hashCode => Object.hashAll([runtimeType,tripId,tripType,tripDate,busPlateNumber,driverName,assistantName,routeName,pickupStopName,dropoffStopName,scheduledDeparture,actualDeparture,actualArrival,boardingTime,dropoffTime,boardingStatus,tripPhase,durationMinutes,delayMinutes,resultTag]);

@override
String toString() {
  return 'ChildTrip(tripId: $tripId, tripType: $tripType, tripDate: $tripDate, busPlateNumber: $busPlateNumber, driverName: $driverName, assistantName: $assistantName, routeName: $routeName, pickupStopName: $pickupStopName, dropoffStopName: $dropoffStopName, scheduledDeparture: $scheduledDeparture, actualDeparture: $actualDeparture, actualArrival: $actualArrival, boardingTime: $boardingTime, dropoffTime: $dropoffTime, boardingStatus: $boardingStatus, tripPhase: $tripPhase, durationMinutes: $durationMinutes, delayMinutes: $delayMinutes, resultTag: $resultTag)';
}


}

/// @nodoc
abstract mixin class $ChildTripCopyWith<$Res>  {
  factory $ChildTripCopyWith(ChildTrip value, $Res Function(ChildTrip) _then) = _$ChildTripCopyWithImpl;
@useResult
$Res call({
 String tripId, String tripType, DateTime tripDate, String busPlateNumber, String? driverName, String? assistantName, String? routeName, String pickupStopName, String dropoffStopName, DateTime scheduledDeparture, DateTime? actualDeparture, DateTime? actualArrival, DateTime? boardingTime, DateTime? dropoffTime, BoardingStatus boardingStatus, TripPhase tripPhase, int? durationMinutes, int? delayMinutes, TripResultTag resultTag
});




}
/// @nodoc
class _$ChildTripCopyWithImpl<$Res>
    implements $ChildTripCopyWith<$Res> {
  _$ChildTripCopyWithImpl(this._self, this._then);

  final ChildTrip _self;
  final $Res Function(ChildTrip) _then;

/// Create a copy of ChildTrip
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tripId = null,Object? tripType = null,Object? tripDate = null,Object? busPlateNumber = null,Object? driverName = freezed,Object? assistantName = freezed,Object? routeName = freezed,Object? pickupStopName = null,Object? dropoffStopName = null,Object? scheduledDeparture = null,Object? actualDeparture = freezed,Object? actualArrival = freezed,Object? boardingTime = freezed,Object? dropoffTime = freezed,Object? boardingStatus = null,Object? tripPhase = null,Object? durationMinutes = freezed,Object? delayMinutes = freezed,Object? resultTag = null,}) {
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
as BoardingStatus,tripPhase: null == tripPhase ? _self.tripPhase : tripPhase // ignore: cast_nullable_to_non_nullable
as TripPhase,durationMinutes: freezed == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int?,delayMinutes: freezed == delayMinutes ? _self.delayMinutes : delayMinutes // ignore: cast_nullable_to_non_nullable
as int?,resultTag: null == resultTag ? _self.resultTag : resultTag // ignore: cast_nullable_to_non_nullable
as TripResultTag,
  ));
}

}


/// Adds pattern-matching-related methods to [ChildTrip].
extension ChildTripPatterns on ChildTrip {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChildTrip value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChildTrip() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChildTrip value)  $default,){
final _that = this;
switch (_that) {
case _ChildTrip():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChildTrip value)?  $default,){
final _that = this;
switch (_that) {
case _ChildTrip() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String tripId,  String tripType,  DateTime tripDate,  String busPlateNumber,  String? driverName,  String? assistantName,  String? routeName,  String pickupStopName,  String dropoffStopName,  DateTime scheduledDeparture,  DateTime? actualDeparture,  DateTime? actualArrival,  DateTime? boardingTime,  DateTime? dropoffTime,  BoardingStatus boardingStatus,  TripPhase tripPhase,  int? durationMinutes,  int? delayMinutes,  TripResultTag resultTag)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChildTrip() when $default != null:
return $default(_that.tripId,_that.tripType,_that.tripDate,_that.busPlateNumber,_that.driverName,_that.assistantName,_that.routeName,_that.pickupStopName,_that.dropoffStopName,_that.scheduledDeparture,_that.actualDeparture,_that.actualArrival,_that.boardingTime,_that.dropoffTime,_that.boardingStatus,_that.tripPhase,_that.durationMinutes,_that.delayMinutes,_that.resultTag);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String tripId,  String tripType,  DateTime tripDate,  String busPlateNumber,  String? driverName,  String? assistantName,  String? routeName,  String pickupStopName,  String dropoffStopName,  DateTime scheduledDeparture,  DateTime? actualDeparture,  DateTime? actualArrival,  DateTime? boardingTime,  DateTime? dropoffTime,  BoardingStatus boardingStatus,  TripPhase tripPhase,  int? durationMinutes,  int? delayMinutes,  TripResultTag resultTag)  $default,) {final _that = this;
switch (_that) {
case _ChildTrip():
return $default(_that.tripId,_that.tripType,_that.tripDate,_that.busPlateNumber,_that.driverName,_that.assistantName,_that.routeName,_that.pickupStopName,_that.dropoffStopName,_that.scheduledDeparture,_that.actualDeparture,_that.actualArrival,_that.boardingTime,_that.dropoffTime,_that.boardingStatus,_that.tripPhase,_that.durationMinutes,_that.delayMinutes,_that.resultTag);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String tripId,  String tripType,  DateTime tripDate,  String busPlateNumber,  String? driverName,  String? assistantName,  String? routeName,  String pickupStopName,  String dropoffStopName,  DateTime scheduledDeparture,  DateTime? actualDeparture,  DateTime? actualArrival,  DateTime? boardingTime,  DateTime? dropoffTime,  BoardingStatus boardingStatus,  TripPhase tripPhase,  int? durationMinutes,  int? delayMinutes,  TripResultTag resultTag)?  $default,) {final _that = this;
switch (_that) {
case _ChildTrip() when $default != null:
return $default(_that.tripId,_that.tripType,_that.tripDate,_that.busPlateNumber,_that.driverName,_that.assistantName,_that.routeName,_that.pickupStopName,_that.dropoffStopName,_that.scheduledDeparture,_that.actualDeparture,_that.actualArrival,_that.boardingTime,_that.dropoffTime,_that.boardingStatus,_that.tripPhase,_that.durationMinutes,_that.delayMinutes,_that.resultTag);case _:
  return null;

}
}

}

/// @nodoc


class _ChildTrip implements ChildTrip {
  const _ChildTrip({required this.tripId, required this.tripType, required this.tripDate, required this.busPlateNumber, this.driverName, this.assistantName, this.routeName, required this.pickupStopName, required this.dropoffStopName, required this.scheduledDeparture, this.actualDeparture, this.actualArrival, this.boardingTime, this.dropoffTime, required this.boardingStatus, required this.tripPhase, this.durationMinutes, this.delayMinutes, required this.resultTag});
  

@override final  String tripId;
@override final  String tripType;
// "Morning" | "Return"
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
@override final  BoardingStatus boardingStatus;
@override final  TripPhase tripPhase;
@override final  int? durationMinutes;
@override final  int? delayMinutes;
@override final  TripResultTag resultTag;

/// Create a copy of ChildTrip
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChildTripCopyWith<_ChildTrip> get copyWith => __$ChildTripCopyWithImpl<_ChildTrip>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChildTrip&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.tripType, tripType) || other.tripType == tripType)&&(identical(other.tripDate, tripDate) || other.tripDate == tripDate)&&(identical(other.busPlateNumber, busPlateNumber) || other.busPlateNumber == busPlateNumber)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.assistantName, assistantName) || other.assistantName == assistantName)&&(identical(other.routeName, routeName) || other.routeName == routeName)&&(identical(other.pickupStopName, pickupStopName) || other.pickupStopName == pickupStopName)&&(identical(other.dropoffStopName, dropoffStopName) || other.dropoffStopName == dropoffStopName)&&(identical(other.scheduledDeparture, scheduledDeparture) || other.scheduledDeparture == scheduledDeparture)&&(identical(other.actualDeparture, actualDeparture) || other.actualDeparture == actualDeparture)&&(identical(other.actualArrival, actualArrival) || other.actualArrival == actualArrival)&&(identical(other.boardingTime, boardingTime) || other.boardingTime == boardingTime)&&(identical(other.dropoffTime, dropoffTime) || other.dropoffTime == dropoffTime)&&(identical(other.boardingStatus, boardingStatus) || other.boardingStatus == boardingStatus)&&(identical(other.tripPhase, tripPhase) || other.tripPhase == tripPhase)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.delayMinutes, delayMinutes) || other.delayMinutes == delayMinutes)&&(identical(other.resultTag, resultTag) || other.resultTag == resultTag));
}


@override
int get hashCode => Object.hashAll([runtimeType,tripId,tripType,tripDate,busPlateNumber,driverName,assistantName,routeName,pickupStopName,dropoffStopName,scheduledDeparture,actualDeparture,actualArrival,boardingTime,dropoffTime,boardingStatus,tripPhase,durationMinutes,delayMinutes,resultTag]);

@override
String toString() {
  return 'ChildTrip(tripId: $tripId, tripType: $tripType, tripDate: $tripDate, busPlateNumber: $busPlateNumber, driverName: $driverName, assistantName: $assistantName, routeName: $routeName, pickupStopName: $pickupStopName, dropoffStopName: $dropoffStopName, scheduledDeparture: $scheduledDeparture, actualDeparture: $actualDeparture, actualArrival: $actualArrival, boardingTime: $boardingTime, dropoffTime: $dropoffTime, boardingStatus: $boardingStatus, tripPhase: $tripPhase, durationMinutes: $durationMinutes, delayMinutes: $delayMinutes, resultTag: $resultTag)';
}


}

/// @nodoc
abstract mixin class _$ChildTripCopyWith<$Res> implements $ChildTripCopyWith<$Res> {
  factory _$ChildTripCopyWith(_ChildTrip value, $Res Function(_ChildTrip) _then) = __$ChildTripCopyWithImpl;
@override @useResult
$Res call({
 String tripId, String tripType, DateTime tripDate, String busPlateNumber, String? driverName, String? assistantName, String? routeName, String pickupStopName, String dropoffStopName, DateTime scheduledDeparture, DateTime? actualDeparture, DateTime? actualArrival, DateTime? boardingTime, DateTime? dropoffTime, BoardingStatus boardingStatus, TripPhase tripPhase, int? durationMinutes, int? delayMinutes, TripResultTag resultTag
});




}
/// @nodoc
class __$ChildTripCopyWithImpl<$Res>
    implements _$ChildTripCopyWith<$Res> {
  __$ChildTripCopyWithImpl(this._self, this._then);

  final _ChildTrip _self;
  final $Res Function(_ChildTrip) _then;

/// Create a copy of ChildTrip
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tripId = null,Object? tripType = null,Object? tripDate = null,Object? busPlateNumber = null,Object? driverName = freezed,Object? assistantName = freezed,Object? routeName = freezed,Object? pickupStopName = null,Object? dropoffStopName = null,Object? scheduledDeparture = null,Object? actualDeparture = freezed,Object? actualArrival = freezed,Object? boardingTime = freezed,Object? dropoffTime = freezed,Object? boardingStatus = null,Object? tripPhase = null,Object? durationMinutes = freezed,Object? delayMinutes = freezed,Object? resultTag = null,}) {
  return _then(_ChildTrip(
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
as BoardingStatus,tripPhase: null == tripPhase ? _self.tripPhase : tripPhase // ignore: cast_nullable_to_non_nullable
as TripPhase,durationMinutes: freezed == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int?,delayMinutes: freezed == delayMinutes ? _self.delayMinutes : delayMinutes // ignore: cast_nullable_to_non_nullable
as int?,resultTag: null == resultTag ? _self.resultTag : resultTag // ignore: cast_nullable_to_non_nullable
as TripResultTag,
  ));
}


}

// dart format on
