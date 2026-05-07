/// Roster row from `GET /api/v1/trips/{id}/students`.
class TripStudentDto {
  const TripStudentDto({
    required this.studentId,
    required this.fullName,
    required this.grade,
    required this.homeArea,
    required this.boardingStatus,
    required this.boardingTime,
    required this.dropoffTime,
  });

  factory TripStudentDto.fromJson(Map<String, dynamic> json) => TripStudentDto(
        studentId: json['studentId'] as String,
        fullName: json['fullName'] as String,
        grade: json['grade'] as String,
        homeArea: json['homeArea'] as String?,
        boardingStatus: json['boardingStatus'] as String,
        boardingTime: json['boardingTime'] == null
            ? null
            : DateTime.parse(json['boardingTime'] as String),
        dropoffTime: json['dropoffTime'] == null
            ? null
            : DateTime.parse(json['dropoffTime'] as String),
      );

  final String studentId;
  final String fullName;
  final String grade;
  final String? homeArea;
  final String boardingStatus; // "Waiting" | "Boarded" | "Absent"
  final DateTime? boardingTime;
  final DateTime? dropoffTime;
}
