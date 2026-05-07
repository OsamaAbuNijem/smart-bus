/// Lightweight bus identity used by the QR scan + manual setup flows.
class BusSummaryDto {
  const BusSummaryDto({
    required this.id,
    required this.plateNumber,
    required this.model,
    required this.capacity,
  });

  factory BusSummaryDto.fromJson(Map<String, dynamic> json) => BusSummaryDto(
        id: json['id'] as String,
        plateNumber: json['plateNumber'] as String,
        model: json['model'] as String?,
        capacity: json['capacity'] as int,
      );

  final String id;
  final String plateNumber;
  final String? model;
  final int capacity;
}
