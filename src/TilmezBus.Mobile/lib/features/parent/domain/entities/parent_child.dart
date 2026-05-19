import 'package:freezed_annotation/freezed_annotation.dart';

part 'parent_child.freezed.dart';

@freezed
abstract class ParentChild with _$ParentChild {
  const factory ParentChild({
    required String id,
    required String fullName,
    String? fullNameEn,
    String? grade,
    String? className,
    String? routeName,
    String? homeArea,
  }) = _ParentChild;
}
