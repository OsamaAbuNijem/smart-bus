// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parent_detail_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ParentDetailDto {

 String get id; String get fullName; String? get phoneNumber; List<ParentChildDto> get children;
/// Create a copy of ParentDetailDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParentDetailDtoCopyWith<ParentDetailDto> get copyWith => _$ParentDetailDtoCopyWithImpl<ParentDetailDto>(this as ParentDetailDto, _$identity);

  /// Serializes this ParentDetailDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentDetailDto&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&const DeepCollectionEquality().equals(other.children, children));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,phoneNumber,const DeepCollectionEquality().hash(children));

@override
String toString() {
  return 'ParentDetailDto(id: $id, fullName: $fullName, phoneNumber: $phoneNumber, children: $children)';
}


}

/// @nodoc
abstract mixin class $ParentDetailDtoCopyWith<$Res>  {
  factory $ParentDetailDtoCopyWith(ParentDetailDto value, $Res Function(ParentDetailDto) _then) = _$ParentDetailDtoCopyWithImpl;
@useResult
$Res call({
 String id, String fullName, String? phoneNumber, List<ParentChildDto> children
});




}
/// @nodoc
class _$ParentDetailDtoCopyWithImpl<$Res>
    implements $ParentDetailDtoCopyWith<$Res> {
  _$ParentDetailDtoCopyWithImpl(this._self, this._then);

  final ParentDetailDto _self;
  final $Res Function(ParentDetailDto) _then;

/// Create a copy of ParentDetailDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? phoneNumber = freezed,Object? children = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,children: null == children ? _self.children : children // ignore: cast_nullable_to_non_nullable
as List<ParentChildDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [ParentDetailDto].
extension ParentDetailDtoPatterns on ParentDetailDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParentDetailDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParentDetailDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParentDetailDto value)  $default,){
final _that = this;
switch (_that) {
case _ParentDetailDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParentDetailDto value)?  $default,){
final _that = this;
switch (_that) {
case _ParentDetailDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fullName,  String? phoneNumber,  List<ParentChildDto> children)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParentDetailDto() when $default != null:
return $default(_that.id,_that.fullName,_that.phoneNumber,_that.children);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fullName,  String? phoneNumber,  List<ParentChildDto> children)  $default,) {final _that = this;
switch (_that) {
case _ParentDetailDto():
return $default(_that.id,_that.fullName,_that.phoneNumber,_that.children);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fullName,  String? phoneNumber,  List<ParentChildDto> children)?  $default,) {final _that = this;
switch (_that) {
case _ParentDetailDto() when $default != null:
return $default(_that.id,_that.fullName,_that.phoneNumber,_that.children);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ParentDetailDto implements ParentDetailDto {
  const _ParentDetailDto({required this.id, required this.fullName, this.phoneNumber, final  List<ParentChildDto> children = const <ParentChildDto>[]}): _children = children;
  factory _ParentDetailDto.fromJson(Map<String, dynamic> json) => _$ParentDetailDtoFromJson(json);

@override final  String id;
@override final  String fullName;
@override final  String? phoneNumber;
 final  List<ParentChildDto> _children;
@override@JsonKey() List<ParentChildDto> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}


/// Create a copy of ParentDetailDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParentDetailDtoCopyWith<_ParentDetailDto> get copyWith => __$ParentDetailDtoCopyWithImpl<_ParentDetailDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ParentDetailDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParentDetailDto&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&const DeepCollectionEquality().equals(other._children, _children));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,phoneNumber,const DeepCollectionEquality().hash(_children));

@override
String toString() {
  return 'ParentDetailDto(id: $id, fullName: $fullName, phoneNumber: $phoneNumber, children: $children)';
}


}

/// @nodoc
abstract mixin class _$ParentDetailDtoCopyWith<$Res> implements $ParentDetailDtoCopyWith<$Res> {
  factory _$ParentDetailDtoCopyWith(_ParentDetailDto value, $Res Function(_ParentDetailDto) _then) = __$ParentDetailDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String fullName, String? phoneNumber, List<ParentChildDto> children
});




}
/// @nodoc
class __$ParentDetailDtoCopyWithImpl<$Res>
    implements _$ParentDetailDtoCopyWith<$Res> {
  __$ParentDetailDtoCopyWithImpl(this._self, this._then);

  final _ParentDetailDto _self;
  final $Res Function(_ParentDetailDto) _then;

/// Create a copy of ParentDetailDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? phoneNumber = freezed,Object? children = null,}) {
  return _then(_ParentDetailDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<ParentChildDto>,
  ));
}


}


/// @nodoc
mixin _$ParentChildDto {

 String get id; String get fullName; String? get fullNameEn; String? get grade;@JsonKey(name: 'class') String? get className; String? get routeName; String? get homeArea;
/// Create a copy of ParentChildDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParentChildDtoCopyWith<ParentChildDto> get copyWith => _$ParentChildDtoCopyWithImpl<ParentChildDto>(this as ParentChildDto, _$identity);

  /// Serializes this ParentChildDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentChildDto&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.fullNameEn, fullNameEn) || other.fullNameEn == fullNameEn)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.className, className) || other.className == className)&&(identical(other.routeName, routeName) || other.routeName == routeName)&&(identical(other.homeArea, homeArea) || other.homeArea == homeArea));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,fullNameEn,grade,className,routeName,homeArea);

@override
String toString() {
  return 'ParentChildDto(id: $id, fullName: $fullName, fullNameEn: $fullNameEn, grade: $grade, className: $className, routeName: $routeName, homeArea: $homeArea)';
}


}

/// @nodoc
abstract mixin class $ParentChildDtoCopyWith<$Res>  {
  factory $ParentChildDtoCopyWith(ParentChildDto value, $Res Function(ParentChildDto) _then) = _$ParentChildDtoCopyWithImpl;
@useResult
$Res call({
 String id, String fullName, String? fullNameEn, String? grade,@JsonKey(name: 'class') String? className, String? routeName, String? homeArea
});




}
/// @nodoc
class _$ParentChildDtoCopyWithImpl<$Res>
    implements $ParentChildDtoCopyWith<$Res> {
  _$ParentChildDtoCopyWithImpl(this._self, this._then);

  final ParentChildDto _self;
  final $Res Function(ParentChildDto) _then;

/// Create a copy of ParentChildDto
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


/// Adds pattern-matching-related methods to [ParentChildDto].
extension ParentChildDtoPatterns on ParentChildDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParentChildDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParentChildDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParentChildDto value)  $default,){
final _that = this;
switch (_that) {
case _ParentChildDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParentChildDto value)?  $default,){
final _that = this;
switch (_that) {
case _ParentChildDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fullName,  String? fullNameEn,  String? grade, @JsonKey(name: 'class')  String? className,  String? routeName,  String? homeArea)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParentChildDto() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fullName,  String? fullNameEn,  String? grade, @JsonKey(name: 'class')  String? className,  String? routeName,  String? homeArea)  $default,) {final _that = this;
switch (_that) {
case _ParentChildDto():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fullName,  String? fullNameEn,  String? grade, @JsonKey(name: 'class')  String? className,  String? routeName,  String? homeArea)?  $default,) {final _that = this;
switch (_that) {
case _ParentChildDto() when $default != null:
return $default(_that.id,_that.fullName,_that.fullNameEn,_that.grade,_that.className,_that.routeName,_that.homeArea);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ParentChildDto implements ParentChildDto {
  const _ParentChildDto({required this.id, required this.fullName, this.fullNameEn, this.grade, @JsonKey(name: 'class') this.className, this.routeName, this.homeArea});
  factory _ParentChildDto.fromJson(Map<String, dynamic> json) => _$ParentChildDtoFromJson(json);

@override final  String id;
@override final  String fullName;
@override final  String? fullNameEn;
@override final  String? grade;
@override@JsonKey(name: 'class') final  String? className;
@override final  String? routeName;
@override final  String? homeArea;

/// Create a copy of ParentChildDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParentChildDtoCopyWith<_ParentChildDto> get copyWith => __$ParentChildDtoCopyWithImpl<_ParentChildDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ParentChildDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParentChildDto&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.fullNameEn, fullNameEn) || other.fullNameEn == fullNameEn)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.className, className) || other.className == className)&&(identical(other.routeName, routeName) || other.routeName == routeName)&&(identical(other.homeArea, homeArea) || other.homeArea == homeArea));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,fullNameEn,grade,className,routeName,homeArea);

@override
String toString() {
  return 'ParentChildDto(id: $id, fullName: $fullName, fullNameEn: $fullNameEn, grade: $grade, className: $className, routeName: $routeName, homeArea: $homeArea)';
}


}

/// @nodoc
abstract mixin class _$ParentChildDtoCopyWith<$Res> implements $ParentChildDtoCopyWith<$Res> {
  factory _$ParentChildDtoCopyWith(_ParentChildDto value, $Res Function(_ParentChildDto) _then) = __$ParentChildDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String fullName, String? fullNameEn, String? grade,@JsonKey(name: 'class') String? className, String? routeName, String? homeArea
});




}
/// @nodoc
class __$ParentChildDtoCopyWithImpl<$Res>
    implements _$ParentChildDtoCopyWith<$Res> {
  __$ParentChildDtoCopyWithImpl(this._self, this._then);

  final _ParentChildDto _self;
  final $Res Function(_ParentChildDto) _then;

/// Create a copy of ParentChildDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? fullNameEn = freezed,Object? grade = freezed,Object? className = freezed,Object? routeName = freezed,Object? homeArea = freezed,}) {
  return _then(_ParentChildDto(
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
