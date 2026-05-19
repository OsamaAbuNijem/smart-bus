/// Server response shape for `GET /api/v1/trips/my-today`.
class MyTodayTripDto {
  const MyTodayTripDto({
    required this.tripId,
    required this.busId,
    required this.busPlateNumber,
    required this.tripType,
    required this.status,
    required this.scheduledDeparture,
    required this.actualDeparture,
    required this.actualArrival,
    required this.studentCount,
    required this.boardedCount,
  });

  factory MyTodayTripDto.fromJson(Map<String, dynamic> json) => MyTodayTripDto(
        tripId: json['tripId'] as String?,
        busId: json['busId'] as String,
        busPlateNumber: json['busPlateNumber'] as String,
        tripType: json['tripType'] as String,
        status: json['status'] as String,
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
      );

  final String? tripId;
  final String busId;
  final String busPlateNumber;
  final String tripType;       // "Morning" | "Return"
  final String status;         // "Scheduled" | "InProgress" | "Completed"
  final DateTime scheduledDeparture;
  final DateTime? actualDeparture;
  final DateTime? actualArrival;
  final int studentCount;
  final int boardedCount;

  bool get isLive => status == 'InProgress';
  bool get isCompleted => status == 'Completed';
  bool get isScheduled => status == 'Scheduled';
  bool get isMorning => tripType == 'Morning';
}
