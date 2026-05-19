// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parent_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ParentDetailDto _$ParentDetailDtoFromJson(Map<String, dynamic> json) =>
    _ParentDetailDto(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      children:
          (json['children'] as List<dynamic>?)
              ?.map((e) => ParentChildDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ParentChildDto>[],
    );

Map<String, dynamic> _$ParentDetailDtoToJson(_ParentDetailDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      if (instance.phoneNumber case final value?) 'phoneNumber': value,
      'children': instance.children.map((e) => e.toJson()).toList(),
    };

_ParentChildDto _$ParentChildDtoFromJson(Map<String, dynamic> json) =>
    _ParentChildDto(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      fullNameEn: json['fullNameEn'] as String?,
      grade: json['grade'] as String?,
      className: json['class'] as String?,
      routeName: json['routeName'] as String?,
      homeArea: json['homeArea'] as String?,
    );

Map<String, dynamic> _$ParentChildDtoToJson(_ParentChildDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      if (instance.fullNameEn case final value?) 'fullNameEn': value,
      if (instance.grade case final value?) 'grade': value,
      if (instance.className case final value?) 'class': value,
      if (instance.routeName case final value?) 'routeName': value,
      if (instance.homeArea case final value?) 'homeArea': value,
    };
