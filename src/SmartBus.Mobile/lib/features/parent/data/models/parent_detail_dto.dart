import 'package:freezed_annotation/freezed_annotation.dart';

part 'parent_detail_dto.freezed.dart';
part 'parent_detail_dto.g.dart';

/// Mirrors `GET /api/v1/parents/{id}` response.
@freezed
abstract class ParentDetailDto with _$ParentDetailDto {
  const factory ParentDetailDto({
    required String id,
    required String fullName,
    String? phoneNumber,
    @Default(<ParentChildDto>[]) List<ParentChildDto> children,
  }) = _ParentDetailDto;

  factory ParentDetailDto.fromJson(Map<String, dynamic> json) =>
      _$ParentDetailDtoFromJson(json);
}

@freezed
abstract class ParentChildDto with _$ParentChildDto {
  const factory ParentChildDto({
    required String id,
    required String fullName,
    String? fullNameEn,
    String? grade,
    @JsonKey(name: 'class') String? className,
    String? routeName,
    String? homeArea,
  }) = _ParentChildDto;

  factory ParentChildDto.fromJson(Map<String, dynamic> json) =>
      _$ParentChildDtoFromJson(json);
}
