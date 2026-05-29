/// School info returned by `GET /api/v1/schools/my-fleet`. Surfaced on
/// the driver / assistant settings screen so the crew member can see
/// who they're driving for at a glance — name, city, and the
/// school's main phone number.
class FleetSchoolInfoDto {
  const FleetSchoolInfoDto({
    required this.name,
    required this.city,
    required this.phoneNumber,
    required this.enableQr,
    required this.enableNfc,
  });

  factory FleetSchoolInfoDto.fromJson(Map<String, dynamic> json) =>
      FleetSchoolInfoDto(
        name: json['name'] as String? ?? '',
        city: json['city'] as String?,
        phoneNumber: json['phoneNumber'] as String?,
        // Default both flags to true when the field is missing — older
        // server builds didn't send them, and the safe fallback is to
        // keep QR/NFC visible rather than accidentally hide them.
        enableQr: json['enableQr'] as bool? ?? true,
        enableNfc: json['enableNfc'] as bool? ?? true,
      );

  final String name;
  final String? city;
  final String? phoneNumber;
  final bool enableQr;
  final bool enableNfc;
}
