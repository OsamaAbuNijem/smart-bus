// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'live_tracking_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LiveTrackingDto {

 String? get tripId; String? get tripStatus; String? get tripType; DateTime? get scheduledDeparture; DateTime? get actualDeparture; DateTime? get actualArrival; DateTime? get boardingTime; String? get boardingStatus; String? get busId; String? get busPlateNumber; BusLocationDto? get busLocation; String? get driverName; String? get driverPhone; String? get assistantName; String? get assistantPhone; String get studentFullName; double? get homeLatitude; double? get homeLongitude; String? get homeAddress; String? get schoolName; double? get schoolLatitude; double? get schoolLongitude;
/// Create a copy of LiveTrackingDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiveTrackingDtoCopyWith<LiveTrackingDto> get copyWith => _$LiveTrackingDtoCopyWithImpl<LiveTrackingDto>(this as LiveTrackingDto, _$identity);

  /// Serializes this LiveTrackingDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiveTrackingDto&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.tripStatus, tripStatus) || other.tripStatus == tripStatus)&&(identical(other.tripType, tripType) || other.tripType == tripType)&&(identical(other.scheduledDeparture, scheduledDeparture) || other.scheduledDeparture == scheduledDeparture)&&(identical(other.actualDeparture, actualDeparture) || other.actualDeparture == actualDeparture)&&(identical(other.actualArrival, actualArrival) || other.actualArrival == actualArrival)&&(identical(other.boardingTime, boardingTime) || other.boardingTime == boardingTime)&&(identical(other.boardingStatus, boardingStatus) || other.boardingStatus == boardingStatus)&&(identical(other.busId, busId) || other.busId == busId)&&(identical(other.busPlateNumber, busPlateNumber) || other.busPlateNumber == busPlateNumber)&&(identical(other.busLocation, busLocation) || other.busLocation == busLocation)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.driverPhone, driverPhone) || other.driverPhone == driverPhone)&&(identical(other.assistantName, assistantName) || other.assistantName == assistantName)&&(identical(other.assistantPhone, assistantPhone) || other.assistantPhone == assistantPhone)&&(identical(other.studentFullName, studentFullName) || other.studentFullName == studentFullName)&&(identical(other.homeLatitude, homeLatitude) || other.homeLatitude == homeLatitude)&&(identical(other.homeLongitude, homeLongitude) || other.homeLongitude == homeLongitude)&&(identical(other.homeAddress, homeAddress) || other.homeAddress == homeAddress)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName)&&(identical(other.schoolLatitude, schoolLatitude) || other.schoolLatitude == schoolLatitude)&&(identical(other.schoolLongitude, schoolLongitude) || other.schoolLongitude == schoolLongitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,tripId,tripStatus,tripType,scheduledDeparture,actualDeparture,actualArrival,boardingTime,boardingStatus,busId,busPlateNumber,busLocation,driverName,driverPhone,assistantName,assistantPhone,studentFullName,homeLatitude,homeLongitude,homeAddress,schoolName,schoolLatitude,schoolLongitude]);

@override
String toString() {
  return 'LiveTrackingDto(tripId: $tripId, tripStatus: $tripStatus, tripType: $tripType, scheduledDeparture: $scheduledDeparture, actualDeparture: $actualDeparture, actualArrival: $actualArrival, boardingTime: $boardingTime, boardingStatus: $boardingStatus, busId: $busId, busPlateNumber: $busPlateNumber, busLocation: $busLocation, driverName: $driverName, driverPhone: $driverPhone, assistantName: $assistantName, assistantPhone: $assistantPhone, studentFullName: $studentFullName, homeLatitude: $homeLatitude, homeLongitude: $homeLongitude, homeAddress: $homeAddress, schoolName: $schoolName, schoolLatitude: $schoolLatitude, schoolLongitude: $schoolLongitude)';
}


}

/// @nodoc
abstract mixin class $LiveTrackingDtoCopyWith<$Res>  {
  factory $LiveTrackingDtoCopyWith(LiveTrackingDto value, $Res Function(LiveTrackingDto) _then) = _$LiveTrackingDtoCopyWithImpl;
@useResult
$Res call({
 String? tripId, String? tripStatus, String? tripType, DateTime? scheduledDeparture, DateTime? actualDeparture, DateTime? actualArrival, DateTime? boardingTime, String? boardingStatus, String? busId, String? busPlateNumber, BusLocationDto? busLocation, String? driverName, String? driverPhone, String? assistantName, String? assistantPhone, String studentFullName, double? homeLatitude, double? homeLongitude, String? homeAddress, String? schoolName, double? schoolLatitude, double? schoolLongitude
});


$BusLocationDtoCopyWith<$Res>? get busLocation;

}
/// @nodoc
class _$LiveTrackingDtoCopyWithImpl<$Res>
    implements $LiveTrackingDtoCopyWith<$Res> {
  _$LiveTrackingDtoCopyWithImpl(this._self, this._then);

  final LiveTrackingDto _self;
  final $Res Function(LiveTrackingDto) _then;

/// Create a copy of LiveTrackingDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tripId = freezed,Object? tripStatus = freezed,Object? tripType = freezed,Object? scheduledDeparture = freezed,Object? actualDeparture = freezed,Object? actualArrival = freezed,Object? boardingTime = freezed,Object? boardingStatus = freezed,Object? busId = freezed,Object? busPlateNumber = freezed,Object? busLocation = freezed,Object? driverName = freezed,Object? driverPhone = freezed,Object? assistantName = freezed,Object? assistantPhone = freezed,Object? studentFullName = null,Object? homeLatitude = freezed,Object? homeLongitude = freezed,Object? homeAddress = freezed,Object? schoolName = freezed,Object? schoolLatitude = freezed,Object? schoolLongitude = freezed,}) {
  return _then(_self.copyWith(
tripId: freezed == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String?,tripStatus: freezed == tripStatus ? _self.tripStatus : tripStatus // ignore: cast_nullable_to_non_nullable
as String?,tripType: freezed == tripType ? _self.tripType : tripType // ignore: cast_nullable_to_non_nullable
as String?,scheduledDeparture: freezed == scheduledDeparture ? _self.scheduledDeparture : scheduledDeparture // ignore: cast_nullable_to_non_nullable
as DateTime?,actualDeparture: freezed == actualDeparture ? _self.actualDeparture : actualDeparture // ignore: cast_nullable_to_non_nullable
as DateTime?,actualArrival: freezed == actualArrival ? _self.actualArrival : actualArrival // ignore: cast_nullable_to_non_nullable
as DateTime?,boardingTime: freezed == boardingTime ? _self.boardingTime : boardingTime // ignore: cast_nullable_to_non_nullable
as DateTime?,boardingStatus: freezed == boardingStatus ? _self.boardingStatus : boardingStatus // ignore: cast_nullable_to_non_nullable
as String?,busId: freezed == busId ? _self.busId : busId // ignore: cast_nullable_to_non_nullable
as String?,busPlateNumber: freezed == busPlateNumber ? _self.busPlateNumber : busPlateNumber // ignore: cast_nullable_to_non_nullable
as String?,busLocation: freezed == busLocation ? _self.busLocation : busLocation // ignore: cast_nullable_to_non_nullable
as BusLocationDto?,driverName: freezed == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String?,driverPhone: freezed == driverPhone ? _self.driverPhone : driverPhone // ignore: cast_nullable_to_non_nullable
as String?,assistantName: freezed == assistantName ? _self.assistantName : assistantName // ignore: cast_nullable_to_non_nullable
as String?,assistantPhone: freezed == assistantPhone ? _self.assistantPhone : assistantPhone // ignore: cast_nullable_to_non_nullable
as String?,studentFullName: null == studentFullName ? _self.studentFullName : studentFullName // ignore: cast_nullable_to_non_nullable
as String,homeLatitude: freezed == homeLatitude ? _self.homeLatitude : homeLatitude // ignore: cast_nullable_to_non_nullable
as double?,homeLongitude: freezed == homeLongitude ? _self.homeLongitude : homeLongitude // ignore: cast_nullable_to_non_nullable
as double?,homeAddress: freezed == homeAddress ? _self.homeAddress : homeAddress // ignore: cast_nullable_to_non_nullable
as String?,schoolName: freezed == schoolName ? _self.schoolName : schoolName // ignore: cast_nullable_to_non_nullable
as String?,schoolLatitude: freezed == schoolLatitude ? _self.schoolLatitude : schoolLatitude // ignore: cast_nullable_to_non_nullable
as double?,schoolLongitude: freezed == schoolLongitude ? _self.schoolLongitude : schoolLongitude // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}
/// Create a copy of LiveTrackingDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BusLocationDtoCopyWith<$Res>? get busLocation {
    if (_self.busLocation == null) {
    return null;
  }

  return $BusLocationDtoCopyWith<$Res>(_self.busLocation!, (value) {
    return _then(_self.copyWith(busLocation: value));
  });
}
}


/// Adds pattern-matching-related methods to [LiveTrackingDto].
extension LiveTrackingDtoPatterns on LiveTrackingDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LiveTrackingDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LiveTrackingDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LiveTrackingDto value)  $default,){
final _that = this;
switch (_that) {
case _LiveTrackingDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LiveTrackingDto value)?  $default,){
final _that = this;
switch (_that) {
case _LiveTrackingDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? tripId,  String? tripStatus,  String? tripType,  DateTime? scheduledDeparture,  DateTime? actualDeparture,  DateTime? actualArrival,  DateTime? boardingTime,  String? boardingStatus,  String? busId,  String? busPlateNumber,  BusLocationDto? busLocation,  String? driverName,  String? driverPhone,  String? assistantName,  String? assistantPhone,  String studentFullName,  double? homeLatitude,  double? homeLongitude,  String? homeAddress,  String? schoolName,  double? schoolLatitude,  double? schoolLongitude)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LiveTrackingDto() when $default != null:
return $default(_that.tripId,_that.tripStatus,_that.tripType,_that.scheduledDeparture,_that.actualDeparture,_that.actualArrival,_that.boardingTime,_that.boardingStatus,_that.busId,_that.busPlateNumber,_that.busLocation,_that.driverName,_that.driverPhone,_that.assistantName,_that.assistantPhone,_that.studentFullName,_that.homeLatitude,_that.homeLongitude,_that.homeAddress,_that.schoolName,_that.schoolLatitude,_that.schoolLongitude);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? tripId,  String? tripStatus,  String? tripType,  DateTime? scheduledDeparture,  DateTime? actualDeparture,  DateTime? actualArrival,  DateTime? boardingTime,  String? boardingStatus,  String? busId,  String? busPlateNumber,  BusLocationDto? busLocation,  String? driverName,  String? driverPhone,  String? assistantName,  String? assistantPhone,  String studentFullName,  double? homeLatitude,  double? homeLongitude,  String? homeAddress,  String? schoolName,  double? schoolLatitude,  double? schoolLongitude)  $default,) {final _that = this;
switch (_that) {
case _LiveTrackingDto():
return $default(_that.tripId,_that.tripStatus,_that.tripType,_that.scheduledDeparture,_that.actualDeparture,_that.actualArrival,_that.boardingTime,_that.boardingStatus,_that.busId,_that.busPlateNumber,_that.busLocation,_that.driverName,_that.driverPhone,_that.assistantName,_that.assistantPhone,_that.studentFullName,_that.homeLatitude,_that.homeLongitude,_that.homeAddress,_that.schoolName,_that.schoolLatitude,_that.schoolLongitude);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? tripId,  String? tripStatus,  String? tripType,  DateTime? scheduledDeparture,  DateTime? actualDeparture,  DateTime? actualArrival,  DateTime? boardingTime,  String? boardingStatus,  String? busId,  String? busPlateNumber,  BusLocationDto? busLocation,  String? driverName,  String? driverPhone,  String? assistantName,  String? assistantPhone,  String studentFullName,  double? homeLatitude,  double? homeLongitude,  String? homeAddress,  String? schoolName,  double? schoolLatitude,  double? schoolLongitude)?  $default,) {final _that = this;
switch (_that) {
case _LiveTrackingDto() when $default != null:
return $default(_that.tripId,_that.tripStatus,_that.tripType,_that.scheduledDeparture,_that.actualDeparture,_that.actualArrival,_that.boardingTime,_that.boardingStatus,_that.busId,_that.busPlateNumber,_that.busLocation,_that.driverName,_that.driverPhone,_that.assistantName,_that.assistantPhone,_that.studentFullName,_that.homeLatitude,_that.homeLongitude,_that.homeAddress,_that.schoolName,_that.schoolLatitude,_that.schoolLongitude);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LiveTrackingDto implements LiveTrackingDto {
  const _LiveTrackingDto({this.tripId, this.tripStatus, this.tripType, this.scheduledDeparture, this.actualDeparture, this.actualArrival, this.boardingTime, this.boardingStatus, this.busId, this.busPlateNumber, this.busLocation, this.driverName, this.driverPhone, this.assistantName, this.assistantPhone, required this.studentFullName, this.homeLatitude, this.homeLongitude, this.homeAddress, this.schoolName, this.schoolLatitude, this.schoolLongitude});
  factory _LiveTrackingDto.fromJson(Map<String, dynamic> json) => _$LiveTrackingDtoFromJson(json);

@override final  String? tripId;
@override final  String? tripStatus;
@override final  String? tripType;
@override final  DateTime? scheduledDeparture;
@override final  DateTime? actualDeparture;
@override final  DateTime? actualArrival;
@override final  DateTime? boardingTime;
@override final  String? boardingStatus;
@override final  String? busId;
@override final  String? busPlateNumber;
@override final  BusLocationDto? busLocation;
@override final  String? driverName;
@override final  String? driverPhone;
@override final  String? assistantName;
@override final  String? assistantPhone;
@override final  String studentFullName;
@override final  double? homeLatitude;
@override final  double? homeLongitude;
@override final  String? homeAddress;
@override final  String? schoolName;
@override final  double? schoolLatitude;
@override final  double? schoolLongitude;

/// Create a copy of LiveTrackingDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LiveTrackingDtoCopyWith<_LiveTrackingDto> get copyWith => __$LiveTrackingDtoCopyWithImpl<_LiveTrackingDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LiveTrackingDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LiveTrackingDto&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.tripStatus, tripStatus) || other.tripStatus == tripStatus)&&(identical(other.tripType, tripType) || other.tripType == tripType)&&(identical(other.scheduledDeparture, scheduledDeparture) || other.scheduledDeparture == scheduledDeparture)&&(identical(other.actualDeparture, actualDeparture) || other.actualDeparture == actualDeparture)&&(identical(other.actualArrival, actualArrival) || other.actualArrival == actualArrival)&&(identical(other.boardingTime, boardingTime) || other.boardingTime == boardingTime)&&(identical(other.boardingStatus, boardingStatus) || other.boardingStatus == boardingStatus)&&(identical(other.busId, busId) || other.busId == busId)&&(identical(other.busPlateNumber, busPlateNumber) || other.busPlateNumber == busPlateNumber)&&(identical(other.busLocation, busLocation) || other.busLocation == busLocation)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.driverPhone, driverPhone) || other.driverPhone == driverPhone)&&(identical(other.assistantName, assistantName) || other.assistantName == assistantName)&&(identical(other.assistantPhone, assistantPhone) || other.assistantPhone == assistantPhone)&&(identical(other.studentFullName, studentFullName) || other.studentFullName == studentFullName)&&(identical(other.homeLatitude, homeLatitude) || other.homeLatitude == homeLatitude)&&(identical(other.homeLongitude, homeLongitude) || other.homeLongitude == homeLongitude)&&(identical(other.homeAddress, homeAddress) || other.homeAddress == homeAddress)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName)&&(identical(other.schoolLatitude, schoolLatitude) || other.schoolLatitude == schoolLatitude)&&(identical(other.schoolLongitude, schoolLongitude) || other.schoolLongitude == schoolLongitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,tripId,tripStatus,tripType,scheduledDeparture,actualDeparture,actualArrival,boardingTime,boardingStatus,busId,busPlateNumber,busLocation,driverName,driverPhone,assistantName,assistantPhone,studentFullName,homeLatitude,homeLongitude,homeAddress,schoolName,schoolLatitude,schoolLongitude]);

@override
String toString() {
  return 'LiveTrackingDto(tripId: $tripId, tripStatus: $tripStatus, tripType: $tripType, scheduledDeparture: $scheduledDeparture, actualDeparture: $actualDeparture, actualArrival: $actualArrival, boardingTime: $boardingTime, boardingStatus: $boardingStatus, busId: $busId, busPlateNumber: $busPlateNumber, busLocation: $busLocation, driverName: $driverName, driverPhone: $driverPhone, assistantName: $assistantName, assistantPhone: $assistantPhone, studentFullName: $studentFullName, homeLatitude: $homeLatitude, homeLongitude: $homeLongitude, homeAddress: $homeAddress, schoolName: $schoolName, schoolLatitude: $schoolLatitude, schoolLongitude: $schoolLongitude)';
}


}

/// @nodoc
abstract mixin class _$LiveTrackingDtoCopyWith<$Res> implements $LiveTrackingDtoCopyWith<$Res> {
  factory _$LiveTrackingDtoCopyWith(_LiveTrackingDto value, $Res Function(_LiveTrackingDto) _then) = __$LiveTrackingDtoCopyWithImpl;
@override @useResult
$Res call({
 String? tripId, String? tripStatus, String? tripType, DateTime? scheduledDeparture, DateTime? actualDeparture, DateTime? actualArrival, DateTime? boardingTime, String? boardingStatus, String? busId, String? busPlateNumber, BusLocationDto? busLocation, String? driverName, String? driverPhone, String? assistantName, String? assistantPhone, String studentFullName, double? homeLatitude, double? homeLongitude, String? homeAddress, String? schoolName, double? schoolLatitude, double? schoolLongitude
});


@override $BusLocationDtoCopyWith<$Res>? get busLocation;

}
/// @nodoc
class __$LiveTrackingDtoCopyWithImpl<$Res>
    implements _$LiveTrackingDtoCopyWith<$Res> {
  __$LiveTrackingDtoCopyWithImpl(this._self, this._then);

  final _LiveTrackingDto _self;
  final $Res Function(_LiveTrackingDto) _then;

/// Create a copy of LiveTrackingDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tripId = freezed,Object? tripStatus = freezed,Object? tripType = freezed,Object? scheduledDeparture = freezed,Object? actualDeparture = freezed,Object? actualArrival = freezed,Object? boardingTime = freezed,Object? boardingStatus = freezed,Object? busId = freezed,Object? busPlateNumber = freezed,Object? busLocation = freezed,Object? driverName = freezed,Object? driverPhone = freezed,Object? assistantName = freezed,Object? assistantPhone = freezed,Object? studentFullName = null,Object? homeLatitude = freezed,Object? homeLongitude = freezed,Object? homeAddress = freezed,Object? schoolName = freezed,Object? schoolLatitude = freezed,Object? schoolLongitude = freezed,}) {
  return _then(_LiveTrackingDto(
tripId: freezed == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String?,tripStatus: freezed == tripStatus ? _self.tripStatus : tripStatus // ignore: cast_nullable_to_non_nullable
as String?,tripType: freezed == tripType ? _self.tripType : tripType // ignore: cast_nullable_to_non_nullable
as String?,scheduledDeparture: freezed == scheduledDeparture ? _self.scheduledDeparture : scheduledDeparture // ignore: cast_nullable_to_non_nullable
as DateTime?,actualDeparture: freezed == actualDeparture ? _self.actualDeparture : actualDeparture // ignore: cast_nullable_to_non_nullable
as DateTime?,actualArrival: freezed == actualArrival ? _self.actualArrival : actualArrival // ignore: cast_nullable_to_non_nullable
as DateTime?,boardingTime: freezed == boardingTime ? _self.boardingTime : boardingTime // ignore: cast_nullable_to_non_nullable
as DateTime?,boardingStatus: freezed == boardingStatus ? _self.boardingStatus : boardingStatus // ignore: cast_nullable_to_non_nullable
as String?,busId: freezed == busId ? _self.busId : busId // ignore: cast_nullable_to_non_nullable
as String?,busPlateNumber: freezed == busPlateNumber ? _self.busPlateNumber : busPlateNumber // ignore: cast_nullable_to_non_nullable
as String?,busLocation: freezed == busLocation ? _self.busLocation : busLocation // ignore: cast_nullable_to_non_nullable
as BusLocationDto?,driverName: freezed == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String?,driverPhone: freezed == driverPhone ? _self.driverPhone : driverPhone // ignore: cast_nullable_to_non_nullable
as String?,assistantName: freezed == assistantName ? _self.assistantName : assistantName // ignore: cast_nullable_to_non_nullable
as String?,assistantPhone: freezed == assistantPhone ? _self.assistantPhone : assistantPhone // ignore: cast_nullable_to_non_nullable
as String?,studentFullName: null == studentFullName ? _self.studentFullName : studentFullName // ignore: cast_nullable_to_non_nullable
as String,homeLatitude: freezed == homeLatitude ? _self.homeLatitude : homeLatitude // ignore: cast_nullable_to_non_nullable
as double?,homeLongitude: freezed == homeLongitude ? _self.homeLongitude : homeLongitude // ignore: cast_nullable_to_non_nullable
as double?,homeAddress: freezed == homeAddress ? _self.homeAddress : homeAddress // ignore: cast_nullable_to_non_nullable
as String?,schoolName: freezed == schoolName ? _self.schoolName : schoolName // ignore: cast_nullable_to_non_nullable
as String?,schoolLatitude: freezed == schoolLatitude ? _self.schoolLatitude : schoolLatitude // ignore: cast_nullable_to_non_nullable
as double?,schoolLongitude: freezed == schoolLongitude ? _self.schoolLongitude : schoolLongitude // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

/// Create a copy of LiveTrackingDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BusLocationDtoCopyWith<$Res>? get busLocation {
    if (_self.busLocation == null) {
    return null;
  }

  return $BusLocationDtoCopyWith<$Res>(_self.busLocation!, (value) {
    return _then(_self.copyWith(busLocation: value));
  });
}
}


/// @nodoc
mixin _$BusLocationDto {

 double get latitude; double get longitude; double? get speed; double? get heading; DateTime get timestamp;
/// Create a copy of BusLocationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BusLocationDtoCopyWith<BusLocationDto> get copyWith => _$BusLocationDtoCopyWithImpl<BusLocationDto>(this as BusLocationDto, _$identity);

  /// Serializes this BusLocationDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BusLocationDto&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.heading, heading) || other.heading == heading)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,speed,heading,timestamp);

@override
String toString() {
  return 'BusLocationDto(latitude: $latitude, longitude: $longitude, speed: $speed, heading: $heading, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $BusLocationDtoCopyWith<$Res>  {
  factory $BusLocationDtoCopyWith(BusLocationDto value, $Res Function(BusLocationDto) _then) = _$BusLocationDtoCopyWithImpl;
@useResult
$Res call({
 double latitude, double longitude, double? speed, double? heading, DateTime timestamp
});




}
/// @nodoc
class _$BusLocationDtoCopyWithImpl<$Res>
    implements $BusLocationDtoCopyWith<$Res> {
  _$BusLocationDtoCopyWithImpl(this._self, this._then);

  final BusLocationDto _self;
  final $Res Function(BusLocationDto) _then;

/// Create a copy of BusLocationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? latitude = null,Object? longitude = null,Object? speed = freezed,Object? heading = freezed,Object? timestamp = null,}) {
  return _then(_self.copyWith(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,speed: freezed == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double?,heading: freezed == heading ? _self.heading : heading // ignore: cast_nullable_to_non_nullable
as double?,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [BusLocationDto].
extension BusLocationDtoPatterns on BusLocationDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BusLocationDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BusLocationDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BusLocationDto value)  $default,){
final _that = this;
switch (_that) {
case _BusLocationDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BusLocationDto value)?  $default,){
final _that = this;
switch (_that) {
case _BusLocationDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double latitude,  double longitude,  double? speed,  double? heading,  DateTime timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BusLocationDto() when $default != null:
return $default(_that.latitude,_that.longitude,_that.speed,_that.heading,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double latitude,  double longitude,  double? speed,  double? heading,  DateTime timestamp)  $default,) {final _that = this;
switch (_that) {
case _BusLocationDto():
return $default(_that.latitude,_that.longitude,_that.speed,_that.heading,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double latitude,  double longitude,  double? speed,  double? heading,  DateTime timestamp)?  $default,) {final _that = this;
switch (_that) {
case _BusLocationDto() when $default != null:
return $default(_that.latitude,_that.longitude,_that.speed,_that.heading,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BusLocationDto implements BusLocationDto {
  const _BusLocationDto({required this.latitude, required this.longitude, this.speed, this.heading, required this.timestamp});
  factory _BusLocationDto.fromJson(Map<String, dynamic> json) => _$BusLocationDtoFromJson(json);

@override final  double latitude;
@override final  double longitude;
@override final  double? speed;
@override final  double? heading;
@override final  DateTime timestamp;

/// Create a copy of BusLocationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BusLocationDtoCopyWith<_BusLocationDto> get copyWith => __$BusLocationDtoCopyWithImpl<_BusLocationDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BusLocationDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BusLocationDto&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.heading, heading) || other.heading == heading)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,speed,heading,timestamp);

@override
String toString() {
  return 'BusLocationDto(latitude: $latitude, longitude: $longitude, speed: $speed, heading: $heading, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$BusLocationDtoCopyWith<$Res> implements $BusLocationDtoCopyWith<$Res> {
  factory _$BusLocationDtoCopyWith(_BusLocationDto value, $Res Function(_BusLocationDto) _then) = __$BusLocationDtoCopyWithImpl;
@override @useResult
$Res call({
 double latitude, double longitude, double? speed, double? heading, DateTime timestamp
});




}
/// @nodoc
class __$BusLocationDtoCopyWithImpl<$Res>
    implements _$BusLocationDtoCopyWith<$Res> {
  __$BusLocationDtoCopyWithImpl(this._self, this._then);

  final _BusLocationDto _self;
  final $Res Function(_BusLocationDto) _then;

/// Create a copy of BusLocationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? latitude = null,Object? longitude = null,Object? speed = freezed,Object? heading = freezed,Object? timestamp = null,}) {
  return _then(_BusLocationDto(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,speed: freezed == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double?,heading: freezed == heading ? _self.heading : heading // ignore: cast_nullable_to_non_nullable
as double?,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
