/// Student row from `GET /api/v1/buses/{busId}/last-roster`.
class RosterStudentDto {
  const RosterStudentDto({
    required this.studentId,
    required this.fullName,
    required this.fullNameEn,
    required this.grade,
  });

  factory RosterStudentDto.fromJson(Map<String, dynamic> json) =>
      RosterStudentDto(
        studentId: json['studentId'] as String,
        fullName: json['fullName'] as String,
        fullNameEn: json['fullNameEn'] as String?,
        grade: json['grade'] as String,
      );

  final String studentId;
  final String fullName;
  final String? fullNameEn;
  final String grade;
}
