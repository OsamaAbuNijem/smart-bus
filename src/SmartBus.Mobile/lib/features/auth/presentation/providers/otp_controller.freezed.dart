// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'otp_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OtpFlow {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OtpFlow);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'OtpFlow()';
}


}

/// @nodoc
class $OtpFlowCopyWith<$Res>  {
$OtpFlowCopyWith(OtpFlow _, $Res Function(OtpFlow) __);
}


/// Adds pattern-matching-related methods to [OtpFlow].
extension OtpFlowPatterns on OtpFlow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( OtpIdle value)?  idle,TResult Function( OtpPending value)?  pending,TResult Function( OtpVerified value)?  verified,required TResult orElse(),}){
final _that = this;
switch (_that) {
case OtpIdle() when idle != null:
return idle(_that);case OtpPending() when pending != null:
return pending(_that);case OtpVerified() when verified != null:
return verified(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( OtpIdle value)  idle,required TResult Function( OtpPending value)  pending,required TResult Function( OtpVerified value)  verified,}){
final _that = this;
switch (_that) {
case OtpIdle():
return idle(_that);case OtpPending():
return pending(_that);case OtpVerified():
return verified(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( OtpIdle value)?  idle,TResult? Function( OtpPending value)?  pending,TResult? Function( OtpVerified value)?  verified,}){
final _that = this;
switch (_that) {
case OtpIdle() when idle != null:
return idle(_that);case OtpPending() when pending != null:
return pending(_that);case OtpVerified() when verified != null:
return verified(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function( String phoneNumber,  UserRole role,  DateTime expiresAt,  String? devOtp)?  pending,TResult Function()?  verified,required TResult orElse(),}) {final _that = this;
switch (_that) {
case OtpIdle() when idle != null:
return idle();case OtpPending() when pending != null:
return pending(_that.phoneNumber,_that.role,_that.expiresAt,_that.devOtp);case OtpVerified() when verified != null:
return verified();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function( String phoneNumber,  UserRole role,  DateTime expiresAt,  String? devOtp)  pending,required TResult Function()  verified,}) {final _that = this;
switch (_that) {
case OtpIdle():
return idle();case OtpPending():
return pending(_that.phoneNumber,_that.role,_that.expiresAt,_that.devOtp);case OtpVerified():
return verified();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function( String phoneNumber,  UserRole role,  DateTime expiresAt,  String? devOtp)?  pending,TResult? Function()?  verified,}) {final _that = this;
switch (_that) {
case OtpIdle() when idle != null:
return idle();case OtpPending() when pending != null:
return pending(_that.phoneNumber,_that.role,_that.expiresAt,_that.devOtp);case OtpVerified() when verified != null:
return verified();case _:
  return null;

}
}

}

/// @nodoc


class OtpIdle implements OtpFlow {
  const OtpIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OtpIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'OtpFlow.idle()';
}


}




/// @nodoc


class OtpPending implements OtpFlow {
  const OtpPending({required this.phoneNumber, required this.role, required this.expiresAt, this.devOtp});
  

 final  String phoneNumber;
 final  UserRole role;
 final  DateTime expiresAt;
 final  String? devOtp;

/// Create a copy of OtpFlow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OtpPendingCopyWith<OtpPending> get copyWith => _$OtpPendingCopyWithImpl<OtpPending>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OtpPending&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.role, role) || other.role == role)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.devOtp, devOtp) || other.devOtp == devOtp));
}


@override
int get hashCode => Object.hash(runtimeType,phoneNumber,role,expiresAt,devOtp);

@override
String toString() {
  return 'OtpFlow.pending(phoneNumber: $phoneNumber, role: $role, expiresAt: $expiresAt, devOtp: $devOtp)';
}


}

/// @nodoc
abstract mixin class $OtpPendingCopyWith<$Res> implements $OtpFlowCopyWith<$Res> {
  factory $OtpPendingCopyWith(OtpPending value, $Res Function(OtpPending) _then) = _$OtpPendingCopyWithImpl;
@useResult
$Res call({
 String phoneNumber, UserRole role, DateTime expiresAt, String? devOtp
});




}
/// @nodoc
class _$OtpPendingCopyWithImpl<$Res>
    implements $OtpPendingCopyWith<$Res> {
  _$OtpPendingCopyWithImpl(this._self, this._then);

  final OtpPending _self;
  final $Res Function(OtpPending) _then;

/// Create a copy of OtpFlow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? phoneNumber = null,Object? role = null,Object? expiresAt = null,Object? devOtp = freezed,}) {
  return _then(OtpPending(
phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,devOtp: freezed == devOtp ? _self.devOtp : devOtp // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class OtpVerified implements OtpFlow {
  const OtpVerified();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OtpVerified);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'OtpFlow.verified()';
}


}




// dart format on
