import 'package:freezed_annotation/freezed_annotation.dart';

part 'student_info_dto.freezed.dart';
part 'student_info_dto.g.dart';

/// Mirrors `GET /api/v1/parents/{parentId}/students/{studentId}` response.
@freezed
abstract class StudentInfoDto with _$StudentInfoDto {
  const factory StudentInfoDto({
    required String id,
    required String fullName,
    String? fullNameEn,
    required String nationalNumber,
    required String grade,
    @JsonKey(name: 'class') String? className,
    DateTime? dateOfBirth,
    String? schoolName,
    String? schoolAddress,
    required String homeAddress,
    String? homeArea,
    String? homeStreet,
    String? notes,
    String? routeName,
    String? pickupStopName,
    @Default(<String>[]) List<String> allergies,
    StudentContactDto? parent,
  }) = _StudentInfoDto;

  factory StudentInfoDto.fromJson(Map<String, dynamic> json) =>
      _$StudentInfoDtoFromJson(json);
}

@freezed
abstract class StudentContactDto with _$StudentContactDto {
  const factory StudentContactDto({
    required String id,
    required String name,
    required String phoneNumber,
    String? relation,
    String? address,
  }) = _StudentContactDto;

  factory StudentContactDto.fromJson(Map<String, dynamic> json) =>
      _$StudentContactDtoFromJson(json);
}
