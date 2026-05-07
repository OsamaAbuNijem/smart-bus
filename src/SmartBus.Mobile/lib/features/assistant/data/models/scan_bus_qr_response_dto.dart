/// Response from `POST /api/v1/trips/scan`.
class ScanBusQrResponseDto {
  const ScanBusQrResponseDto({
    required this.tripId,
    required this.busId,
    required this.plateNumber,
    required this.tripType,
    required this.alreadyExisted,
  });

  factory ScanBusQrResponseDto.fromJson(Map<String, dynamic> json) =>
      ScanBusQrResponseDto(
        tripId: json['tripId'] as String,
        busId: json['busId'] as String,
        plateNumber: json['plateNumber'] as String,
        tripType: json['tripType'] as String,
        alreadyExisted: json['alreadyExisted'] as bool? ?? false,
      );

  final String tripId;
  final String busId;
  final String plateNumber;
  final String tripType; // "Morning" | "Return"
  final bool alreadyExisted;
}
