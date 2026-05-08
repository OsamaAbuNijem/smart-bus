/// Server response for `GET /api/v1/trips/{id}/details`.
class TripDetailsDto {
  const TripDetailsDto({
    required this.tripId,
    required this.tripType,
    required this.status,
    required this.busPlateNumber,
    required this.driverName,
    required this.scheduledDeparture,
    required this.actualDeparture,
    required this.actualArrival,
    required this.studentCount,
    required this.boardedCount,
    required this.students,
  });

  factory TripDetailsDto.fromJson(Map<String, dynamic> json) => TripDetailsDto(
        tripId: json['tripId'] as String,
        tripType: json['tripType'] as String,
        status: json['status'] as String,
        busPlateNumber: json['busPlateNumber'] as String,
        driverName: json['driverName'] as String?,
        scheduledDeparture:
            DateTime.parse(json['scheduledDeparture'] as String),
        actualDeparture: json['actualDeparture'] == null
            ? null
            : DateTime.parse(json['actualDeparture'] as String),
        actualArrival: json['actualArrival'] == null
            ? null
            : DateTime.parse(json['actualArrival'] as String),
        studentCount: json['studentCount'] as int,
        boardedCount: json['boardedCount'] as int,
        students: ((json['students'] as List<dynamic>?) ?? const [])
            .map((e) =>
                TripStudentDetailDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final String tripId;
  final String tripType;
  final String status;
  final String busPlateNumber;
  final String? driverName;
  final DateTime scheduledDeparture;
  final DateTime? actualDeparture;
  final DateTime? actualArrival;
  final int studentCount;
  final int boardedCount;
  final List<TripStudentDetailDto> students;

  bool get isMorning => tripType == 'Morning';
}

class TripStudentDetailDto {
  const TripStudentDetailDto({
    required this.studentId,
    required this.fullName,
    required this.fullNameEn,
    required this.grade,
    required this.className,
    required this.homeArea,
    required this.latitude,
    required this.longitude,
    required this.boardingStatus,
    required this.boardingTime,
    required this.dropoffTime,
    required this.isAbsentToday,
    required this.absenceReason,
    required this.absencePickupPersonName,
    required this.absencePickupPersonRelation,
    required this.absenceDriverNote,
    required this.parentName,
    required this.parentPhone,
  });

  factory TripStudentDetailDto.fromJson(Map<String, dynamic> json) =>
      TripStudentDetailDto(
        studentId: json['studentId'] as String,
        fullName: json['fullName'] as String,
        fullNameEn: json['fullNameEn'] as String?,
        grade: json['grade'] as String,
        className: json['class'] as String?,
        homeArea: json['homeArea'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        boardingStatus: json['boardingStatus'] as String,
        boardingTime: json['boardingTime'] == null
            ? null
            : DateTime.parse(json['boardingTime'] as String),
        dropoffTime: json['dropoffTime'] == null
            ? null
            : DateTime.parse(json['dropoffTime'] as String),
        isAbsentToday: json['isAbsentToday'] as bool? ?? false,
        absenceReason: json['absenceReason'] as String?,
        absencePickupPersonName: json['absencePickupPersonName'] as String?,
        absencePickupPersonRelation:
            json['absencePickupPersonRelation'] as String?,
        absenceDriverNote: json['absenceDriverNote'] as String?,
        parentName: json['parentName'] as String?,
        parentPhone: json['parentPhone'] as String?,
      );

  final String studentId;
  final String fullName;
  final String? fullNameEn;
  final String grade;
  final String? className;
  final String? homeArea;
  final double? latitude;
  final double? longitude;
  final String boardingStatus; // "Waiting" | "Boarded" | "Absent"
  final DateTime? boardingTime;
  final DateTime? dropoffTime;
  final bool isAbsentToday;
  final String? absenceReason;
  final String? absencePickupPersonName;
  final String? absencePickupPersonRelation;
  final String? absenceDriverNote;
  final String? parentName;
  final String? parentPhone;

  bool get isBoarded => boardingStatus == 'Boarded';
  bool get isAbsent => boardingStatus == 'Absent' || isAbsentToday;
  bool get isWaiting =>
      boardingStatus == 'Waiting' && !isAbsent;
}
