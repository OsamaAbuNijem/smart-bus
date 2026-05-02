// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_info_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StudentInfoDto _$StudentInfoDtoFromJson(Map<String, dynamic> json) =>
    _StudentInfoDto(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      fullNameEn: json['fullNameEn'] as String?,
      nationalNumber: json['nationalNumber'] as String,
      grade: json['grade'] as String,
      className: json['class'] as String?,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      schoolName: json['schoolName'] as String?,
      homeAddress: json['homeAddress'] as String,
      homeArea: json['homeArea'] as String?,
      homeStreet: json['homeStreet'] as String?,
      notes: json['notes'] as String?,
      routeName: json['routeName'] as String?,
      pickupStopName: json['pickupStopName'] as String?,
      allergies:
          (json['allergies'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      parent: json['parent'] == null
          ? null
          : StudentContactDto.fromJson(json['parent'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StudentInfoDtoToJson(_StudentInfoDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      if (instance.fullNameEn case final value?) 'fullNameEn': value,
      'nationalNumber': instance.nationalNumber,
      'grade': instance.grade,
      if (instance.className case final value?) 'class': value,
      if (instance.dateOfBirth?.toIso8601String() case final value?)
        'dateOfBirth': value,
      if (instance.schoolName case final value?) 'schoolName': value,
      'homeAddress': instance.homeAddress,
      if (instance.homeArea case final value?) 'homeArea': value,
      if (instance.homeStreet case final value?) 'homeStreet': value,
      if (instance.notes case final value?) 'notes': value,
      if (instance.routeName case final value?) 'routeName': value,
      if (instance.pickupStopName case final value?) 'pickupStopName': value,
      'allergies': instance.allergies,
      if (instance.parent?.toJson() case final value?) 'parent': value,
    };

_StudentContactDto _$StudentContactDtoFromJson(Map<String, dynamic> json) =>
    _StudentContactDto(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      relation: json['relation'] as String?,
      address: json['address'] as String?,
    );

Map<String, dynamic> _$StudentContactDtoToJson(_StudentContactDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phoneNumber': instance.phoneNumber,
      if (instance.relation case final value?) 'relation': value,
      if (instance.address case final value?) 'address': value,
    };
