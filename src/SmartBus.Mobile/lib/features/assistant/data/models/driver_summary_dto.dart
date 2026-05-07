class DriverSummaryDto {
  const DriverSummaryDto({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.driverType,
  });

  factory DriverSummaryDto.fromJson(Map<String, dynamic> json) {
    // The API serialises the enum either as a string ("Driver" / "Assistant")
    // or, in some configs, as an int (0 / 1). Accept both so the client
    // doesn't break if the serialiser swaps.
    final raw = json['driverType'];
    final type = switch (raw) {
      int i => i == 1 ? 'Assistant' : 'Driver',
      String s => s,
      _ => 'Driver',
    };
    return DriverSummaryDto(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      driverType: type,
    );
  }

  final String id;
  final String fullName;
  final String phoneNumber;
  final String driverType; // "Driver" | "Assistant"

  bool get isAssistant => driverType == 'Assistant';
}
