// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'student_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StudentInfo {

 String get id; String get fullName; String? get fullNameEn; String get nationalNumber; String get grade; String? get className; DateTime? get dateOfBirth; String? get schoolName; String? get schoolAddress; String get homeAddress; String? get homeArea; String? get homeStreet; double? get homeLatitude; double? get homeLongitude; String? get notes; String? get routeName; String? get pickupStopName; List<String> get allergies; StudentContact? get parent;
/// Create a copy of StudentInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudentInfoCopyWith<StudentInfo> get copyWith => _$StudentInfoCopyWithImpl<StudentInfo>(this as StudentInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StudentInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.fullNameEn, fullNameEn) || other.fullNameEn == fullNameEn)&&(identical(other.nationalNumber, nationalNumber) || other.nationalNumber == nationalNumber)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.className, className) || other.className == className)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName)&&(identical(other.schoolAddress, schoolAddress) || other.schoolAddress == schoolAddress)&&(identical(other.homeAddress, homeAddress) || other.homeAddress == homeAddress)&&(identical(other.homeArea, homeArea) || other.homeArea == homeArea)&&(identical(other.homeStreet, homeStreet) || other.homeStreet == homeStreet)&&(identical(other.homeLatitude, homeLatitude) || other.homeLatitude == homeLatitude)&&(identical(other.homeLongitude, homeLongitude) || other.homeLongitude == homeLongitude)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.routeName, routeName) || other.routeName == routeName)&&(identical(other.pickupStopName, pickupStopName) || other.pickupStopName == pickupStopName)&&const DeepCollectionEquality().equals(other.allergies, allergies)&&(identical(other.parent, parent) || other.parent == parent));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,fullName,fullNameEn,nationalNumber,grade,className,dateOfBirth,schoolName,schoolAddress,homeAddress,homeArea,homeStreet,homeLatitude,homeLongitude,notes,routeName,pickupStopName,const DeepCollectionEquality().hash(allergies),parent]);

@override
String toString() {
  return 'StudentInfo(id: $id, fullName: $fullName, fullNameEn: $fullNameEn, nationalNumber: $nationalNumber, grade: $grade, className: $className, dateOfBirth: $dateOfBirth, schoolName: $schoolName, schoolAddress: $schoolAddress, homeAddress: $homeAddress, homeArea: $homeArea, homeStreet: $homeStreet, homeLatitude: $homeLatitude, homeLongitude: $homeLongitude, notes: $notes, routeName: $routeName, pickupStopName: $pickupStopName, allergies: $allergies, parent: $parent)';
}


}

/// @nodoc
abstract mixin class $StudentInfoCopyWith<$Res>  {
  factory $StudentInfoCopyWith(StudentInfo value, $Res Function(StudentInfo) _then) = _$StudentInfoCopyWithImpl;
@useResult
$Res call({
 String id, String fullName, String? fullNameEn, String nationalNumber, String grade, String? className, DateTime? dateOfBirth, String? schoolName, String? schoolAddress, String homeAddress, String? homeArea, String? homeStreet, double? homeLatitude, double? homeLongitude, String? notes, String? routeName, String? pickupStopName, List<String> allergies, StudentContact? parent
});


$StudentContactCopyWith<$Res>? get parent;

}
/// @nodoc
class _$StudentInfoCopyWithImpl<$Res>
    implements $StudentInfoCopyWith<$Res> {
  _$StudentInfoCopyWithImpl(this._self, this._then);

  final StudentInfo _self;
  final $Res Function(StudentInfo) _then;

/// Create a copy of StudentInfo
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
as StudentContact?,
  ));
}
/// Create a copy of StudentInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StudentContactCopyWith<$Res>? get parent {
    if (_self.parent == null) {
    return null;
  }

  return $StudentContactCopyWith<$Res>(_self.parent!, (value) {
    return _then(_self.copyWith(parent: value));
  });
}
}


/// Adds pattern-matching-related methods to [StudentInfo].
extension StudentInfoPatterns on StudentInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StudentInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StudentInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StudentInfo value)  $default,){
final _that = this;
switch (_that) {
case _StudentInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StudentInfo value)?  $default,){
final _that = this;
switch (_that) {
case _StudentInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fullName,  String? fullNameEn,  String nationalNumber,  String grade,  String? className,  DateTime? dateOfBirth,  String? schoolName,  String? schoolAddress,  String homeAddress,  String? homeArea,  String? homeStreet,  double? homeLatitude,  double? homeLongitude,  String? notes,  String? routeName,  String? pickupStopName,  List<String> allergies,  StudentContact? parent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StudentInfo() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fullName,  String? fullNameEn,  String nationalNumber,  String grade,  String? className,  DateTime? dateOfBirth,  String? schoolName,  String? schoolAddress,  String homeAddress,  String? homeArea,  String? homeStreet,  double? homeLatitude,  double? homeLongitude,  String? notes,  String? routeName,  String? pickupStopName,  List<String> allergies,  StudentContact? parent)  $default,) {final _that = this;
switch (_that) {
case _StudentInfo():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fullName,  String? fullNameEn,  String nationalNumber,  String grade,  String? className,  DateTime? dateOfBirth,  String? schoolName,  String? schoolAddress,  String homeAddress,  String? homeArea,  String? homeStreet,  double? homeLatitude,  double? homeLongitude,  String? notes,  String? routeName,  String? pickupStopName,  List<String> allergies,  StudentContact? parent)?  $default,) {final _that = this;
switch (_that) {
case _StudentInfo() when $default != null:
return $default(_that.id,_that.fullName,_that.fullNameEn,_that.nationalNumber,_that.grade,_that.className,_that.dateOfBirth,_that.schoolName,_that.schoolAddress,_that.homeAddress,_that.homeArea,_that.homeStreet,_that.homeLatitude,_that.homeLongitude,_that.notes,_that.routeName,_that.pickupStopName,_that.allergies,_that.parent);case _:
  return null;

}
}

}

/// @nodoc


class _StudentInfo implements StudentInfo {
  const _StudentInfo({required this.id, required this.fullName, this.fullNameEn, required this.nationalNumber, required this.grade, this.className, this.dateOfBirth, this.schoolName, this.schoolAddress, required this.homeAddress, this.homeArea, this.homeStreet, this.homeLatitude, this.homeLongitude, this.notes, this.routeName, this.pickupStopName, final  List<String> allergies = const <String>[], this.parent}): _allergies = allergies;
  

@override final  String id;
@override final  String fullName;
@override final  String? fullNameEn;
@override final  String nationalNumber;
@override final  String grade;
@override final  String? className;
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

@override final  StudentContact? parent;

/// Create a copy of StudentInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StudentInfoCopyWith<_StudentInfo> get copyWith => __$StudentInfoCopyWithImpl<_StudentInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StudentInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.fullNameEn, fullNameEn) || other.fullNameEn == fullNameEn)&&(identical(other.nationalNumber, nationalNumber) || other.nationalNumber == nationalNumber)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.className, className) || other.className == className)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName)&&(identical(other.schoolAddress, schoolAddress) || other.schoolAddress == schoolAddress)&&(identical(other.homeAddress, homeAddress) || other.homeAddress == homeAddress)&&(identical(other.homeArea, homeArea) || other.homeArea == homeArea)&&(identical(other.homeStreet, homeStreet) || other.homeStreet == homeStreet)&&(identical(other.homeLatitude, homeLatitude) || other.homeLatitude == homeLatitude)&&(identical(other.homeLongitude, homeLongitude) || other.homeLongitude == homeLongitude)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.routeName, routeName) || other.routeName == routeName)&&(identical(other.pickupStopName, pickupStopName) || other.pickupStopName == pickupStopName)&&const DeepCollectionEquality().equals(other._allergies, _allergies)&&(identical(other.parent, parent) || other.parent == parent));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,fullName,fullNameEn,nationalNumber,grade,className,dateOfBirth,schoolName,schoolAddress,homeAddress,homeArea,homeStreet,homeLatitude,homeLongitude,notes,routeName,pickupStopName,const DeepCollectionEquality().hash(_allergies),parent]);

@override
String toString() {
  return 'StudentInfo(id: $id, fullName: $fullName, fullNameEn: $fullNameEn, nationalNumber: $nationalNumber, grade: $grade, className: $className, dateOfBirth: $dateOfBirth, schoolName: $schoolName, schoolAddress: $schoolAddress, homeAddress: $homeAddress, homeArea: $homeArea, homeStreet: $homeStreet, homeLatitude: $homeLatitude, homeLongitude: $homeLongitude, notes: $notes, routeName: $routeName, pickupStopName: $pickupStopName, allergies: $allergies, parent: $parent)';
}


}

/// @nodoc
abstract mixin class _$StudentInfoCopyWith<$Res> implements $StudentInfoCopyWith<$Res> {
  factory _$StudentInfoCopyWith(_StudentInfo value, $Res Function(_StudentInfo) _then) = __$StudentInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, String fullName, String? fullNameEn, String nationalNumber, String grade, String? className, DateTime? dateOfBirth, String? schoolName, String? schoolAddress, String homeAddress, String? homeArea, String? homeStreet, double? homeLatitude, double? homeLongitude, String? notes, String? routeName, String? pickupStopName, List<String> allergies, StudentContact? parent
});


@override $StudentContactCopyWith<$Res>? get parent;

}
/// @nodoc
class __$StudentInfoCopyWithImpl<$Res>
    implements _$StudentInfoCopyWith<$Res> {
  __$StudentInfoCopyWithImpl(this._self, this._then);

  final _StudentInfo _self;
  final $Res Function(_StudentInfo) _then;

/// Create a copy of StudentInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? fullNameEn = freezed,Object? nationalNumber = null,Object? grade = null,Object? className = freezed,Object? dateOfBirth = freezed,Object? schoolName = freezed,Object? schoolAddress = freezed,Object? homeAddress = null,Object? homeArea = freezed,Object? homeStreet = freezed,Object? homeLatitude = freezed,Object? homeLongitude = freezed,Object? notes = freezed,Object? routeName = freezed,Object? pickupStopName = freezed,Object? allergies = null,Object? parent = freezed,}) {
  return _then(_StudentInfo(
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
as StudentContact?,
  ));
}

/// Create a copy of StudentInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StudentContactCopyWith<$Res>? get parent {
    if (_self.parent == null) {
    return null;
  }

  return $StudentContactCopyWith<$Res>(_self.parent!, (value) {
    return _then(_self.copyWith(parent: value));
  });
}
}

/// @nodoc
mixin _$StudentContact {

 String get id; String get name; String get phoneNumber; String? get relation; String? get address;
/// Create a copy of StudentContact
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudentContactCopyWith<StudentContact> get copyWith => _$StudentContactCopyWithImpl<StudentContact>(this as StudentContact, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StudentContact&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.relation, relation) || other.relation == relation)&&(identical(other.address, address) || other.address == address));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,phoneNumber,relation,address);

@override
String toString() {
  return 'StudentContact(id: $id, name: $name, phoneNumber: $phoneNumber, relation: $relation, address: $address)';
}


}

/// @nodoc
abstract mixin class $StudentContactCopyWith<$Res>  {
  factory $StudentContactCopyWith(StudentContact value, $Res Function(StudentContact) _then) = _$StudentContactCopyWithImpl;
@useResult
$Res call({
 String id, String name, String phoneNumber, String? relation, String? address
});




}
/// @nodoc
class _$StudentContactCopyWithImpl<$Res>
    implements $StudentContactCopyWith<$Res> {
  _$StudentContactCopyWithImpl(this._self, this._then);

  final StudentContact _self;
  final $Res Function(StudentContact) _then;

/// Create a copy of StudentContact
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


/// Adds pattern-matching-related methods to [StudentContact].
extension StudentContactPatterns on StudentContact {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StudentContact value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StudentContact() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StudentContact value)  $default,){
final _that = this;
switch (_that) {
case _StudentContact():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StudentContact value)?  $default,){
final _that = this;
switch (_that) {
case _StudentContact() when $default != null:
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
case _StudentContact() when $default != null:
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
case _StudentContact():
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
case _StudentContact() when $default != null:
return $default(_that.id,_that.name,_that.phoneNumber,_that.relation,_that.address);case _:
  return null;

}
}

}

/// @nodoc


class _StudentContact implements StudentContact {
  const _StudentContact({required this.id, required this.name, required this.phoneNumber, this.relation, this.address});
  

@override final  String id;
@override final  String name;
@override final  String phoneNumber;
@override final  String? relation;
@override final  String? address;

/// Create a copy of StudentContact
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StudentContactCopyWith<_StudentContact> get copyWith => __$StudentContactCopyWithImpl<_StudentContact>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StudentContact&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.relation, relation) || other.relation == relation)&&(identical(other.address, address) || other.address == address));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,phoneNumber,relation,address);

@override
String toString() {
  return 'StudentContact(id: $id, name: $name, phoneNumber: $phoneNumber, relation: $relation, address: $address)';
}


}

/// @nodoc
abstract mixin class _$StudentContactCopyWith<$Res> implements $StudentContactCopyWith<$Res> {
  factory _$StudentContactCopyWith(_StudentContact value, $Res Function(_StudentContact) _then) = __$StudentContactCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String phoneNumber, String? relation, String? address
});




}
/// @nodoc
class __$StudentContactCopyWithImpl<$Res>
    implements _$StudentContactCopyWith<$Res> {
  __$StudentContactCopyWithImpl(this._self, this._then);

  final _StudentContact _self;
  final $Res Function(_StudentContact) _then;

/// Create a copy of StudentContact
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? phoneNumber = null,Object? relation = freezed,Object? address = freezed,}) {
  return _then(_StudentContact(
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
