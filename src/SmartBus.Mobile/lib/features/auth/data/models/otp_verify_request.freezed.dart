// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'otp_verify_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OtpVerifyRequest {

 String get phoneNumber; String get otp; String get role;
/// Create a copy of OtpVerifyRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OtpVerifyRequestCopyWith<OtpVerifyRequest> get copyWith => _$OtpVerifyRequestCopyWithImpl<OtpVerifyRequest>(this as OtpVerifyRequest, _$identity);

  /// Serializes this OtpVerifyRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OtpVerifyRequest&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.otp, otp) || other.otp == otp)&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,phoneNumber,otp,role);

@override
String toString() {
  return 'OtpVerifyRequest(phoneNumber: $phoneNumber, otp: $otp, role: $role)';
}


}

/// @nodoc
abstract mixin class $OtpVerifyRequestCopyWith<$Res>  {
  factory $OtpVerifyRequestCopyWith(OtpVerifyRequest value, $Res Function(OtpVerifyRequest) _then) = _$OtpVerifyRequestCopyWithImpl;
@useResult
$Res call({
 String phoneNumber, String otp, String role
});




}
/// @nodoc
class _$OtpVerifyRequestCopyWithImpl<$Res>
    implements $OtpVerifyRequestCopyWith<$Res> {
  _$OtpVerifyRequestCopyWithImpl(this._self, this._then);

  final OtpVerifyRequest _self;
  final $Res Function(OtpVerifyRequest) _then;

/// Create a copy of OtpVerifyRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phoneNumber = null,Object? otp = null,Object? role = null,}) {
  return _then(_self.copyWith(
phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,otp: null == otp ? _self.otp : otp // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [OtpVerifyRequest].
extension OtpVerifyRequestPatterns on OtpVerifyRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OtpVerifyRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OtpVerifyRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OtpVerifyRequest value)  $default,){
final _that = this;
switch (_that) {
case _OtpVerifyRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OtpVerifyRequest value)?  $default,){
final _that = this;
switch (_that) {
case _OtpVerifyRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String phoneNumber,  String otp,  String role)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OtpVerifyRequest() when $default != null:
return $default(_that.phoneNumber,_that.otp,_that.role);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String phoneNumber,  String otp,  String role)  $default,) {final _that = this;
switch (_that) {
case _OtpVerifyRequest():
return $default(_that.phoneNumber,_that.otp,_that.role);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String phoneNumber,  String otp,  String role)?  $default,) {final _that = this;
switch (_that) {
case _OtpVerifyRequest() when $default != null:
return $default(_that.phoneNumber,_that.otp,_that.role);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OtpVerifyRequest implements OtpVerifyRequest {
  const _OtpVerifyRequest({required this.phoneNumber, required this.otp, required this.role});
  factory _OtpVerifyRequest.fromJson(Map<String, dynamic> json) => _$OtpVerifyRequestFromJson(json);

@override final  String phoneNumber;
@override final  String otp;
@override final  String role;

/// Create a copy of OtpVerifyRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OtpVerifyRequestCopyWith<_OtpVerifyRequest> get copyWith => __$OtpVerifyRequestCopyWithImpl<_OtpVerifyRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OtpVerifyRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OtpVerifyRequest&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.otp, otp) || other.otp == otp)&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,phoneNumber,otp,role);

@override
String toString() {
  return 'OtpVerifyRequest(phoneNumber: $phoneNumber, otp: $otp, role: $role)';
}


}

/// @nodoc
abstract mixin class _$OtpVerifyRequestCopyWith<$Res> implements $OtpVerifyRequestCopyWith<$Res> {
  factory _$OtpVerifyRequestCopyWith(_OtpVerifyRequest value, $Res Function(_OtpVerifyRequest) _then) = __$OtpVerifyRequestCopyWithImpl;
@override @useResult
$Res call({
 String phoneNumber, String otp, String role
});




}
/// @nodoc
class __$OtpVerifyRequestCopyWithImpl<$Res>
    implements _$OtpVerifyRequestCopyWith<$Res> {
  __$OtpVerifyRequestCopyWithImpl(this._self, this._then);

  final _OtpVerifyRequest _self;
  final $Res Function(_OtpVerifyRequest) _then;

/// Create a copy of OtpVerifyRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phoneNumber = null,Object? otp = null,Object? role = null,}) {
  return _then(_OtpVerifyRequest(
phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,otp: null == otp ? _self.otp : otp // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
