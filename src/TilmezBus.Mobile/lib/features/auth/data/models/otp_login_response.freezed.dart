// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'otp_login_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OtpLoginResponse {

 String get token; DateTime get expiresAt; String get role; String get fullName; String get phoneNumber; String get entityId;
/// Create a copy of OtpLoginResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OtpLoginResponseCopyWith<OtpLoginResponse> get copyWith => _$OtpLoginResponseCopyWithImpl<OtpLoginResponse>(this as OtpLoginResponse, _$identity);

  /// Serializes this OtpLoginResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OtpLoginResponse&&(identical(other.token, token) || other.token == token)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.role, role) || other.role == role)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.entityId, entityId) || other.entityId == entityId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token,expiresAt,role,fullName,phoneNumber,entityId);

@override
String toString() {
  return 'OtpLoginResponse(token: $token, expiresAt: $expiresAt, role: $role, fullName: $fullName, phoneNumber: $phoneNumber, entityId: $entityId)';
}


}

/// @nodoc
abstract mixin class $OtpLoginResponseCopyWith<$Res>  {
  factory $OtpLoginResponseCopyWith(OtpLoginResponse value, $Res Function(OtpLoginResponse) _then) = _$OtpLoginResponseCopyWithImpl;
@useResult
$Res call({
 String token, DateTime expiresAt, String role, String fullName, String phoneNumber, String entityId
});




}
/// @nodoc
class _$OtpLoginResponseCopyWithImpl<$Res>
    implements $OtpLoginResponseCopyWith<$Res> {
  _$OtpLoginResponseCopyWithImpl(this._self, this._then);

  final OtpLoginResponse _self;
  final $Res Function(OtpLoginResponse) _then;

/// Create a copy of OtpLoginResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,Object? expiresAt = null,Object? role = null,Object? fullName = null,Object? phoneNumber = null,Object? entityId = null,}) {
  return _then(_self.copyWith(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [OtpLoginResponse].
extension OtpLoginResponsePatterns on OtpLoginResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OtpLoginResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OtpLoginResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OtpLoginResponse value)  $default,){
final _that = this;
switch (_that) {
case _OtpLoginResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OtpLoginResponse value)?  $default,){
final _that = this;
switch (_that) {
case _OtpLoginResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String token,  DateTime expiresAt,  String role,  String fullName,  String phoneNumber,  String entityId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OtpLoginResponse() when $default != null:
return $default(_that.token,_that.expiresAt,_that.role,_that.fullName,_that.phoneNumber,_that.entityId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String token,  DateTime expiresAt,  String role,  String fullName,  String phoneNumber,  String entityId)  $default,) {final _that = this;
switch (_that) {
case _OtpLoginResponse():
return $default(_that.token,_that.expiresAt,_that.role,_that.fullName,_that.phoneNumber,_that.entityId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String token,  DateTime expiresAt,  String role,  String fullName,  String phoneNumber,  String entityId)?  $default,) {final _that = this;
switch (_that) {
case _OtpLoginResponse() when $default != null:
return $default(_that.token,_that.expiresAt,_that.role,_that.fullName,_that.phoneNumber,_that.entityId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OtpLoginResponse implements OtpLoginResponse {
  const _OtpLoginResponse({required this.token, required this.expiresAt, required this.role, required this.fullName, required this.phoneNumber, required this.entityId});
  factory _OtpLoginResponse.fromJson(Map<String, dynamic> json) => _$OtpLoginResponseFromJson(json);

@override final  String token;
@override final  DateTime expiresAt;
@override final  String role;
@override final  String fullName;
@override final  String phoneNumber;
@override final  String entityId;

/// Create a copy of OtpLoginResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OtpLoginResponseCopyWith<_OtpLoginResponse> get copyWith => __$OtpLoginResponseCopyWithImpl<_OtpLoginResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OtpLoginResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OtpLoginResponse&&(identical(other.token, token) || other.token == token)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.role, role) || other.role == role)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.entityId, entityId) || other.entityId == entityId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token,expiresAt,role,fullName,phoneNumber,entityId);

@override
String toString() {
  return 'OtpLoginResponse(token: $token, expiresAt: $expiresAt, role: $role, fullName: $fullName, phoneNumber: $phoneNumber, entityId: $entityId)';
}


}

/// @nodoc
abstract mixin class _$OtpLoginResponseCopyWith<$Res> implements $OtpLoginResponseCopyWith<$Res> {
  factory _$OtpLoginResponseCopyWith(_OtpLoginResponse value, $Res Function(_OtpLoginResponse) _then) = __$OtpLoginResponseCopyWithImpl;
@override @useResult
$Res call({
 String token, DateTime expiresAt, String role, String fullName, String phoneNumber, String entityId
});




}
/// @nodoc
class __$OtpLoginResponseCopyWithImpl<$Res>
    implements _$OtpLoginResponseCopyWith<$Res> {
  __$OtpLoginResponseCopyWithImpl(this._self, this._then);

  final _OtpLoginResponse _self;
  final $Res Function(_OtpLoginResponse) _then;

/// Create a copy of OtpLoginResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,Object? expiresAt = null,Object? role = null,Object? fullName = null,Object? phoneNumber = null,Object? entityId = null,}) {
  return _then(_OtpLoginResponse(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
