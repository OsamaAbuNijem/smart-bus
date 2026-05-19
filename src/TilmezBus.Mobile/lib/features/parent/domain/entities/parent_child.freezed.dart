// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parent_child.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ParentChild {

 String get id; String get fullName; String? get fullNameEn; String? get grade; String? get className; String? get routeName; String? get homeArea;
/// Create a copy of ParentChild
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParentChildCopyWith<ParentChild> get copyWith => _$ParentChildCopyWithImpl<ParentChild>(this as ParentChild, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentChild&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.fullNameEn, fullNameEn) || other.fullNameEn == fullNameEn)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.className, className) || other.className == className)&&(identical(other.routeName, routeName) || other.routeName == routeName)&&(identical(other.homeArea, homeArea) || other.homeArea == homeArea));
}


@override
int get hashCode => Object.hash(runtimeType,id,fullName,fullNameEn,grade,className,routeName,homeArea);

@override
String toString() {
  return 'ParentChild(id: $id, fullName: $fullName, fullNameEn: $fullNameEn, grade: $grade, className: $className, routeName: $routeName, homeArea: $homeArea)';
}


}

/// @nodoc
abstract mixin class $ParentChildCopyWith<$Res>  {
  factory $ParentChildCopyWith(ParentChild value, $Res Function(ParentChild) _then) = _$ParentChildCopyWithImpl;
@useResult
$Res call({
 String id, String fullName, String? fullNameEn, String? grade, String? className, String? routeName, String? homeArea
});




}
/// @nodoc
class _$ParentChildCopyWithImpl<$Res>
    implements $ParentChildCopyWith<$Res> {
  _$ParentChildCopyWithImpl(this._self, this._then);

  final ParentChild _self;
  final $Res Function(ParentChild) _then;

/// Create a copy of ParentChild
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? fullNameEn = freezed,Object? grade = freezed,Object? className = freezed,Object? routeName = freezed,Object? homeArea = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,fullNameEn: freezed == fullNameEn ? _self.fullNameEn : fullNameEn // ignore: cast_nullable_to_non_nullable
as String?,grade: freezed == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as String?,className: freezed == className ? _self.className : className // ignore: cast_nullable_to_non_nullable
as String?,routeName: freezed == routeName ? _self.routeName : routeName // ignore: cast_nullable_to_non_nullable
as String?,homeArea: freezed == homeArea ? _self.homeArea : homeArea // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ParentChild].
extension ParentChildPatterns on ParentChild {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParentChild value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParentChild() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParentChild value)  $default,){
final _that = this;
switch (_that) {
case _ParentChild():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParentChild value)?  $default,){
final _that = this;
switch (_that) {
case _ParentChild() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fullName,  String? fullNameEn,  String? grade,  String? className,  String? routeName,  String? homeArea)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParentChild() when $default != null:
return $default(_that.id,_that.fullName,_that.fullNameEn,_that.grade,_that.className,_that.routeName,_that.homeArea);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fullName,  String? fullNameEn,  String? grade,  String? className,  String? routeName,  String? homeArea)  $default,) {final _that = this;
switch (_that) {
case _ParentChild():
return $default(_that.id,_that.fullName,_that.fullNameEn,_that.grade,_that.className,_that.routeName,_that.homeArea);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fullName,  String? fullNameEn,  String? grade,  String? className,  String? routeName,  String? homeArea)?  $default,) {final _that = this;
switch (_that) {
case _ParentChild() when $default != null:
return $default(_that.id,_that.fullName,_that.fullNameEn,_that.grade,_that.className,_that.routeName,_that.homeArea);case _:
  return null;

}
}

}

/// @nodoc


class _ParentChild implements ParentChild {
  const _ParentChild({required this.id, required this.fullName, this.fullNameEn, this.grade, this.className, this.routeName, this.homeArea});
  

@override final  String id;
@override final  String fullName;
@override final  String? fullNameEn;
@override final  String? grade;
@override final  String? className;
@override final  String? routeName;
@override final  String? homeArea;

/// Create a copy of ParentChild
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParentChildCopyWith<_ParentChild> get copyWith => __$ParentChildCopyWithImpl<_ParentChild>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParentChild&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.fullNameEn, fullNameEn) || other.fullNameEn == fullNameEn)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.className, className) || other.className == className)&&(identical(other.routeName, routeName) || other.routeName == routeName)&&(identical(other.homeArea, homeArea) || other.homeArea == homeArea));
}


@override
int get hashCode => Object.hash(runtimeType,id,fullName,fullNameEn,grade,className,routeName,homeArea);

@override
String toString() {
  return 'ParentChild(id: $id, fullName: $fullName, fullNameEn: $fullNameEn, grade: $grade, className: $className, routeName: $routeName, homeArea: $homeArea)';
}


}

/// @nodoc
abstract mixin class _$ParentChildCopyWith<$Res> implements $ParentChildCopyWith<$Res> {
  factory _$ParentChildCopyWith(_ParentChild value, $Res Function(_ParentChild) _then) = __$ParentChildCopyWithImpl;
@override @useResult
$Res call({
 String id, String fullName, String? fullNameEn, String? grade, String? className, String? routeName, String? homeArea
});




}
/// @nodoc
class __$ParentChildCopyWithImpl<$Res>
    implements _$ParentChildCopyWith<$Res> {
  __$ParentChildCopyWithImpl(this._self, this._then);

  final _ParentChild _self;
  final $Res Function(_ParentChild) _then;

/// Create a copy of ParentChild
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? fullNameEn = freezed,Object? grade = freezed,Object? className = freezed,Object? routeName = freezed,Object? homeArea = freezed,}) {
  return _then(_ParentChild(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,fullNameEn: freezed == fullNameEn ? _self.fullNameEn : fullNameEn // ignore: cast_nullable_to_non_nullable
as String?,grade: freezed == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as String?,className: freezed == className ? _self.className : className // ignore: cast_nullable_to_non_nullable
as String?,routeName: freezed == routeName ? _self.routeName : routeName // ignore: cast_nullable_to_non_nullable
as String?,homeArea: freezed == homeArea ? _self.homeArea : homeArea // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
