// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'student_info_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StudentInfoDto {

 String get id; String get fullName; String? get fullNameEn; String get nationalNumber; String get grade;@JsonKey(name: 'class') String? get className; DateTime? get dateOfBirth; String? get schoolName; String? get schoolAddress; String get homeAddress; String? get homeArea; String? get homeStreet; double? get homeLatitude; double? get homeLongitude; String? get notes; String? get routeName; String? get pickupStopName; List<String> get allergies; StudentContactDto? get parent;
/// Create a copy of StudentInfoDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudentInfoDtoCopyWith<StudentInfoDto> get copyWith => _$StudentInfoDtoCopyWithImpl<StudentInfoDto>(this as StudentInfoDto, _$identity);

  /// Serializes this StudentInfoDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StudentInfoDto&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.fullNameEn, fullNameEn) || other.fullNameEn == fullNameEn)&&(identical(other.nationalNumber, nationalNumber) || other.nationalNumber == nationalNumber)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.className, className) || other.className == className)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName)&&(identical(other.schoolAddress, schoolAddress) || other.schoolAddress == schoolAddress)&&(identical(other.homeAddress, homeAddress) || other.homeAddress == homeAddress)&&(identical(other.homeArea, homeArea) || other.homeArea == homeArea)&&(identical(other.homeStreet, homeStreet) || other.homeStreet == homeStreet)&&(identical(other.homeLatitude, homeLatitude) || other.homeLatitude == homeLatitude)&&(identical(other.homeLongitude, homeLongitude) || other.homeLongitude == homeLongitude)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.routeName, routeName) || other.routeName == routeName)&&(identical(other.pickupStopName, pickupStopName) || other.pickupStopName == pickupStopName)&&const DeepCollectionEquality().equals(other.allergies, allergies)&&(identical(other.parent, parent) || other.parent == parent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,fullName,fullNameEn,nationalNumber,grade,className,dateOfBirth,schoolName,schoolAddress,homeAddress,homeArea,homeStreet,homeLatitude,homeLongitude,notes,routeName,pickupStopName,const DeepCollectionEquality().hash(allergies),parent]);

@override
String toString() {
  return 'StudentInfoDto(id: $id, fullName: $fullName, fullNameEn: $fullNameEn, nationalNumber: $nationalNumber, grade: $grade, className: $className, dateOfBirth: $dateOfBirth, schoolName: $schoolName, schoolAddress: $schoolAddress, homeAddress: $homeAddress, homeArea: $homeArea, homeStreet: $homeStreet, homeLatitude: $homeLatitude, homeLongitude: $homeLongitude, notes: $notes, routeName: $routeName, pickupStopName: $pickupStopName, allergies: $allergies, parent: $parent)';
}


}

/// @nodoc
abstract mixin class $StudentInfoDtoCopyWith<$Res>  {
  factory $StudentInfoDtoCopyWith(StudentInfoDto value, $Res Function(StudentInfoDto) _then) = _$StudentInfoDtoCopyWithImpl;
@useResult
$Res call({
 String id, String fullName, String? fullNameEn, String nationalNumber, String grade,@JsonKey(name: 'class') String? className, DateTime? dateOfBirth, String? schoolName, String? schoolAddress, String homeAddress, String? homeArea, String? homeStreet, double? homeLatitude, double? homeLongitude, String? notes, String? routeName, String? pickupStopName, List<String> allergies, StudentContactDto? parent
});


$StudentContactDtoCopyWith<$Res>? get parent;

}
/// @nodoc
class _$StudentInfoDtoCopyWithImpl<$Res>
    implements $StudentInfoDtoCopyWith<$Res> {
  _$StudentInfoDtoCopyWithImpl(this._self, this._then);

  final StudentInfoDto _self;
  final $Res Function(StudentInfoDto) _then;

/// Create a copy of StudentInfoDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? fullNameEn = freezed,Object? nationalNumber = null,Object? grade = null,Object? className = freezed,Object? dateOfBirth = freezed,Object? schoolName = freezed,Object? schoolAddress = freezed,Object? homeAddress = null,Object? homeArea = freezed,Object? homeStreet = freezed,Object? homeLatitude = freezed,Object? homeLongitude = freezed,Object? notes = freezed,Object? routeName = freezed,Object? pickupStopName = freezed,Object? allergies = null,Object? parent = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,fullNameEn: freezed == fullNameEn ? _self.fullNameEn : fullNameEn // ignore: cast_nullable_to_non_nullable
as String?,nationalNumber: null == nationalNumber ? _self.nationalNumber : nationalNumber // ignore: cast_nullable_to_non_nullable
as String,grade: null == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as String,className: freezed == className ? _self.className : className // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,schoolName: freezed == schoolName ? _self.schoolName : schoolName // ignore: cast_nullable_to_non_nullable
as String?,schoolAddress: freezed == schoolAddress ? _self.schoolAddress : schoolAddress // ignore: cast_nullable_to_non_nullable
as String?,homeAddress: null == homeAddress ? _self.homeAddress : homeAddress // ignore: cast_nullable_to_non_nullable
as String,homeArea: freezed == homeArea ? _self.homeArea : homeArea // ignore: cast_nullable_to_non_nullable
as String?,homeStreet: freezed == homeStreet ? _self.homeStreet : homeStreet // ignore: cast_nullable_to_non_nullable
as String?,homeLatitude: freezed == homeLatitude ? _self.homeLatitude : homeLatitude // ignore: cast_nullable_to_non_nullable
as double?,homeLongitude: freezed == homeLongitude ? _self.homeLongitude : homeLongitude // ignore: cast_nullable_to_non_nullable
as double?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,routeName: freezed == routeName ? _self.routeName : routeName // ignore: cast_nullable_to_non_nullable
as String?,pickupStopName: freezed == pickupStopName ? _self.pickupStopName : pickupStopName // ignore: cast_nullable_to_non_nullable
as String?,allergies: null == allergies ? _self.allergies : allergies // ignore: cast_nullable_to_non_nullable
as List<String>,parent: freezed == parent ? _self.parent : parent // ignore: cast_nullable_to_non_nullable
as StudentContactDto?,
  ));
}
/// Create a copy of StudentInfoDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StudentContactDtoCopyWith<$Res>? get parent {
    if (_self.parent == null) {
    return null;
  }

  return $StudentContactDtoCopyWith<$Res>(_self.parent!, (value) {
    return _then(_self.copyWith(parent: value));
  });
}
}


/// Adds pattern-matching-related methods to [StudentInfoDto].
extension StudentInfoDtoPatterns on StudentInfoDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StudentInfoDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StudentInfoDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StudentInfoDto value)  $default,){
final _that = this;
switch (_that) {
case _StudentInfoDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StudentInfoDto value)?  $default,){
final _that = this;
switch (_that) {
case _StudentInfoDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fullName,  String? fullNameEn,  String nationalNumber,  String grade, @JsonKey(name: 'class')  String? className,  DateTime? dateOfBirth,  String? schoolName,  String? schoolAddress,  String homeAddress,  String? homeArea,  String? homeStreet,  double? homeLatitude,  double? homeLongitude,  String? notes,  String? routeName,  String? pickupStopName,  List<String> allergies,  StudentContactDto? parent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StudentInfoDto() when $default != null:
return $default(_that.id,_that.fullName,_that.fullNameEn,_that.nationalNumber,_that.grade,_that.className,_that.dateOfBirth,_that.schoolName,_that.schoolAddress,_that.homeAddress,_that.homeArea,_that.homeStreet,_that.homeLatitude,_that.homeLongitude,_that.notes,_that.routeName,_that.pickupStopName,_that.allergies,_that.parent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fullName,  String? fullNameEn,  String nationalNumber,  String grade, @JsonKey(name: 'class')  String? className,  DateTime? dateOfBirth,  String? schoolName,  String? schoolAddress,  String homeAddress,  String? homeArea,  String? homeStreet,  double? homeLatitude,  double? homeLongitude,  String? notes,  String? routeName,  String? pickupStopName,  List<String> allergies,  StudentContactDto? parent)  $default,) {final _that = this;
switch (_that) {
case _StudentInfoDto():
return $default(_that.id,_that.fullName,_that.fullNameEn,_that.nationalNumber,_that.grade,_that.className,_that.dateOfBirth,_that.schoolName,_that.schoolAddress,_that.homeAddress,_that.homeArea,_that.homeStreet,_that.homeLatitude,_that.homeLongitude,_that.notes,_that.routeName,_that.pickupStopName,_that.allergies,_that.parent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fullName,  String? fullNameEn,  String nationalNumber,  String grade, @JsonKey(name: 'class')  String? className,  DateTime? dateOfBirth,  String? schoolName,  String? schoolAddress,  String homeAddress,  String? homeArea,  String? homeStreet,  double? homeLatitude,  double? homeLongitude,  String? notes,  String? routeName,  String? pickupStopName,  List<String> allergies,  StudentContactDto? parent)?  $default,) {final _that = this;
switch (_that) {
case _StudentInfoDto() when $default != null:
return $default(_that.id,_that.fullName,_that.fullNameEn,_that.nationalNumber,_that.grade,_that.className,_that.dateOfBirth,_that.schoolName,_that.schoolAddress,_that.homeAddress,_that.homeArea,_that.homeStreet,_that.homeLatitude,_that.homeLongitude,_that.notes,_that.routeName,_that.pickupStopName,_that.allergies,_that.parent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StudentInfoDto implements StudentInfoDto {
  const _StudentInfoDto({required this.id, required this.fullName, this.fullNameEn, required this.nationalNumber, required this.grade, @JsonKey(name: 'class') this.className, this.dateOfBirth, this.schoolName, this.schoolAddress, required this.homeAddress, this.homeArea, this.homeStreet, this.homeLatitude, this.homeLongitude, this.notes, this.routeName, this.pickupStopName, final  List<String> allergies = const <String>[], this.parent}): _allergies = allergies;
  factory _StudentInfoDto.fromJson(Map<String, dynamic> json) => _$StudentInfoDtoFromJson(json);

@override final  String id;
@override final  String fullName;
@override final  String? fullNameEn;
@override final  String nationalNumber;
@override final  String grade;
@override@JsonKey(name: 'class') final  String? className;
@override final  DateTime? dateOfBirth;
@override final  String? schoolName;
@override final  String? schoolAddress;
@override final  String homeAddress;
@override final  String? homeArea;
@override final  String? homeStreet;
@override final  double? homeLatitude;
@override final  double? homeLongitude;
@override final  String? notes;
@override final  String? routeName;
@override final  String? pickupStopName;
 final  List<String> _allergies;
@override@JsonKey() List<String> get allergies {
  if (_allergies is EqualUnmodifiableListView) return _allergies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allergies);
}

@override final  StudentContactDto? parent;

/// Create a copy of StudentInfoDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StudentInfoDtoCopyWith<_StudentInfoDto> get copyWith => __$StudentInfoDtoCopyWithImpl<_StudentInfoDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StudentInfoDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StudentInfoDto&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.fullNameEn, fullNameEn) || other.fullNameEn == fullNameEn)&&(identical(other.nationalNumber, nationalNumber) || other.nationalNumber == nationalNumber)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.className, className) || other.className == className)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName)&&(identical(other.schoolAddress, schoolAddress) || other.schoolAddress == schoolAddress)&&(identical(other.homeAddress, homeAddress) || other.homeAddress == homeAddress)&&(identical(other.homeArea, homeArea) || other.homeArea == homeArea)&&(identical(other.homeStreet, homeStreet) || other.homeStreet == homeStreet)&&(identical(other.homeLatitude, homeLatitude) || other.homeLatitude == homeLatitude)&&(identical(other.homeLongitude, homeLongitude) || other.homeLongitude == homeLongitude)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.routeName, routeName) || other.routeName == routeName)&&(identical(other.pickupStopName, pickupStopName) || other.pickupStopName == pickupStopName)&&const DeepCollectionEquality().equals(other._allergies, _allergies)&&(identical(other.parent, parent) || other.parent == parent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,fullName,fullNameEn,nationalNumber,grade,className,dateOfBirth,schoolName,schoolAddress,homeAddress,homeArea,homeStreet,homeLatitude,homeLongitude,notes,routeName,pickupStopName,const DeepCollectionEquality().hash(_allergies),parent]);

@override
String toString() {
  return 'StudentInfoDto(id: $id, fullName: $fullName, fullNameEn: $fullNameEn, nationalNumber: $nationalNumber, grade: $grade, className: $className, dateOfBirth: $dateOfBirth, schoolName: $schoolName, schoolAddress: $schoolAddress, homeAddress: $homeAddress, homeArea: $homeArea, homeStreet: $homeStreet, homeLatitude: $homeLatitude, homeLongitude: $homeLongitude, notes: $notes, routeName: $routeName, pickupStopName: $pickupStopName, allergies: $allergies, parent: $parent)';
}


}

/// @nodoc
abstract mixin class _$StudentInfoDtoCopyWith<$Res> implements $StudentInfoDtoCopyWith<$Res> {
  factory _$StudentInfoDtoCopyWith(_StudentInfoDto value, $Res Function(_StudentInfoDto) _then) = __$StudentInfoDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String fullName, String? fullNameEn, String nationalNumber, String grade,@JsonKey(name: 'class') String? className, DateTime? dateOfBirth, String? schoolName, String? schoolAddress, String homeAddress, String? homeArea, String? homeStreet, double? homeLatitude, double? homeLongitude, String? notes, String? routeName, String? pickupStopName, List<String> allergies, StudentContactDto? parent
});


@override $StudentContactDtoCopyWith<$Res>? get parent;

}
/// @nodoc
class __$StudentInfoDtoCopyWithImpl<$Res>
    implements _$StudentInfoDtoCopyWith<$Res> {
  __$StudentInfoDtoCopyWithImpl(this._self, this._then);

  final _StudentInfoDto _self;
  final $Res Function(_StudentInfoDto) _then;

/// Create a copy of StudentInfoDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? fullNameEn = freezed,Object? nationalNumber = null,Object? grade = null,Object? className = freezed,Object? dateOfBirth = freezed,Object? schoolName = freezed,Object? schoolAddress = freezed,Object? homeAddress = null,Object? homeArea = freezed,Object? homeStreet = freezed,Object? homeLatitude = freezed,Object? homeLongitude = freezed,Object? notes = freezed,Object? routeName = freezed,Object? pickupStopName = freezed,Object? allergies = null,Object? parent = freezed,}) {
  return _then(_StudentInfoDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,fullNameEn: freezed == fullNameEn ? _self.fullNameEn : fullNameEn // ignore: cast_nullable_to_non_nullable
as String?,nationalNumber: null == nationalNumber ? _self.nationalNumber : nationalNumber // ignore: cast_nullable_to_non_nullable
as String,grade: null == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as String,className: freezed == className ? _self.className : className // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,schoolName: freezed == schoolName ? _self.schoolName : schoolName // ignore: cast_nullable_to_non_nullable
as String?,schoolAddress: freezed == schoolAddress ? _self.schoolAddress : schoolAddress // ignore: cast_nullable_to_non_nullable
as String?,homeAddress: null == homeAddress ? _self.homeAddress : homeAddress // ignore: cast_nullable_to_non_nullable
as String,homeArea: freezed == homeArea ? _self.homeArea : homeArea // ignore: cast_nullable_to_non_nullable
as String?,homeStreet: freezed == homeStreet ? _self.homeStreet : homeStreet // ignore: cast_nullable_to_non_nullable
as String?,homeLatitude: freezed == homeLatitude ? _self.homeLatitude : homeLatitude // ignore: cast_nullable_to_non_nullable
as double?,homeLongitude: freezed == homeLongitude ? _self.homeLongitude : homeLongitude // ignore: cast_nullable_to_non_nullable
as double?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,routeName: freezed == routeName ? _self.routeName : routeName // ignore: cast_nullable_to_non_nullable
as String?,pickupStopName: freezed == pickupStopName ? _self.pickupStopName : pickupStopName // ignore: cast_nullable_to_non_nullable
as String?,allergies: null == allergies ? _self._allergies : allergies // ignore: cast_nullable_to_non_nullable
as List<String>,parent: freezed == parent ? _self.parent : parent // ignore: cast_nullable_to_non_nullable
as StudentContactDto?,
  ));
}

/// Create a copy of StudentInfoDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StudentContactDtoCopyWith<$Res>? get parent {
    if (_self.parent == null) {
    return null;
  }

  return $StudentContactDtoCopyWith<$Res>(_self.parent!, (value) {
    return _then(_self.copyWith(parent: value));
  });
}
}


/// @nodoc
mixin _$StudentContactDto {

 String get id; String get name; String get phoneNumber; String? get relation; String? get address;
/// Create a copy of StudentContactDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudentContactDtoCopyWith<StudentContactDto> get copyWith => _$StudentContactDtoCopyWithImpl<StudentContactDto>(this as StudentContactDto, _$identity);

  /// Serializes this StudentContactDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StudentContactDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.relation, relation) || other.relation == relation)&&(identical(other.address, address) || other.address == address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,phoneNumber,relation,address);

@override
String toString() {
  return 'StudentContactDto(id: $id, name: $name, phoneNumber: $phoneNumber, relation: $relation, address: $address)';
}


}

/// @nodoc
abstract mixin class $StudentContactDtoCopyWith<$Res>  {
  factory $StudentContactDtoCopyWith(StudentContactDto value, $Res Function(StudentContactDto) _then) = _$StudentContactDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name, String phoneNumber, String? relation, String? address
});




}
/// @nodoc
class _$StudentContactDtoCopyWithImpl<$Res>
    implements $StudentContactDtoCopyWith<$Res> {
  _$StudentContactDtoCopyWithImpl(this._self, this._then);

  final StudentContactDto _self;
  final $Res Function(StudentContactDto) _then;

/// Create a copy of StudentContactDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? phoneNumber = null,Object? relation = freezed,Object? address = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,relation: freezed == relation ? _self.relation : relation // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StudentContactDto].
extension StudentContactDtoPatterns on StudentContactDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StudentContactDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StudentContactDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StudentContactDto value)  $default,){
final _that = this;
switch (_that) {
case _StudentContactDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StudentContactDto value)?  $default,){
final _that = this;
switch (_that) {
case _StudentContactDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String phoneNumber,  String? relation,  String? address)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StudentContactDto() when $default != null:
return $default(_that.id,_that.name,_that.phoneNumber,_that.relation,_that.address);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String phoneNumber,  String? relation,  String? address)  $default,) {final _that = this;
switch (_that) {
case _StudentContactDto():
return $default(_that.id,_that.name,_that.phoneNumber,_that.relation,_that.address);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String phoneNumber,  String? relation,  String? address)?  $default,) {final _that = this;
switch (_that) {
case _StudentContactDto() when $default != null:
return $default(_that.id,_that.name,_that.phoneNumber,_that.relation,_that.address);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StudentContactDto implements StudentContactDto {
  const _StudentContactDto({required this.id, required this.name, required this.phoneNumber, this.relation, this.address});
  factory _StudentContactDto.fromJson(Map<String, dynamic> json) => _$StudentContactDtoFromJson(json);

@override final  String id;
@override final  String name;
@override final  String phoneNumber;
@override final  String? relation;
@override final  String? address;

/// Create a copy of StudentContactDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StudentContactDtoCopyWith<_StudentContactDto> get copyWith => __$StudentContactDtoCopyWithImpl<_StudentContactDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StudentContactDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StudentContactDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.relation, relation) || other.relation == relation)&&(identical(other.address, address) || other.address == address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,phoneNumber,relation,address);

@override
String toString() {
  return 'StudentContactDto(id: $id, name: $name, phoneNumber: $phoneNumber, relation: $relation, address: $address)';
}


}

/// @nodoc
abstract mixin class _$StudentContactDtoCopyWith<$Res> implements $StudentContactDtoCopyWith<$Res> {
  factory _$StudentContactDtoCopyWith(_StudentContactDto value, $Res Function(_StudentContactDto) _then) = __$StudentContactDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String phoneNumber, String? relation, String? address
});




}
/// @nodoc
class __$StudentContactDtoCopyWithImpl<$Res>
    implements _$StudentContactDtoCopyWith<$Res> {
  __$StudentContactDtoCopyWithImpl(this._self, this._then);

  final _StudentContactDto _self;
  final $Res Function(_StudentContactDto) _then;

/// Create a copy of StudentContactDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? phoneNumber = null,Object? relation = freezed,Object? address = freezed,}) {
  return _then(_StudentContactDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,relation: freezed == relation ? _self.relation : relation // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
