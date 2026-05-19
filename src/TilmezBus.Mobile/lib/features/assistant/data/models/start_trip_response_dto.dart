class StartTripResponseDto {
  const StartTripResponseDto({
    required this.tripId,
    required this.busId,
    required this.busPlateNumber,
    required this.tripType,
    required this.studentCount,
  });

  factory StartTripResponseDto.fromJson(Map<String, dynamic> json) =>
      StartTripResponseDto(
        tripId: json['tripId'] as String,
        busId: json['busId'] as String,
        busPlateNumber: json['busPlateNumber'] as String,
        tripType: json['tripType'] as String,
        studentCount: json['studentCount'] as int,
      );

  final String tripId;
  final String busId;
  final String busPlateNumber;
  final String tripType;
  final int studentCount;
}
