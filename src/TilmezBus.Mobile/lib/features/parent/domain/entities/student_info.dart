import 'package:freezed_annotation/freezed_annotation.dart';

part 'student_info.freezed.dart';

@freezed
abstract class StudentInfo with _$StudentInfo {
  const factory StudentInfo({
    required String id,
    required String fullName,
    String? fullNameEn,
    required String nationalNumber,
    required String grade,
    String? className,
    DateTime? dateOfBirth,
    String? schoolName,
    String? schoolAddress,
    required String homeAddress,
    String? homeArea,
    String? homeStreet,
    double? homeLatitude,
    double? homeLongitude,
    String? notes,
    String? routeName,
    String? pickupStopName,
    @Default(<String>[]) List<String> allergies,
    StudentContact? parent,
  }) = _StudentInfo;
}

@freezed
abstract class StudentContact with _$StudentContact {
  const factory StudentContact({
    required String id,
    required String name,
    required String phoneNumber,
    String? relation,
    String? address,
  }) = _StudentContact;
}
