/// School info returned by `GET /api/v1/schools/my-fleet`. Surfaced on
/// the driver / assistant settings screen so the crew member can see
/// who they're driving for at a glance — name, city, and the
/// school's main phone number.
class FleetSchoolInfoDto {
  const FleetSchoolInfoDto({
    required this.name,
    required this.city,
    required this.phoneNumber,
  });

  factory FleetSchoolInfoDto.fromJson(Map<String, dynamic> json) =>
      FleetSchoolInfoDto(
        name: json['name'] as String? ?? '',
        city: json['city'] as String?,
        phoneNumber: json['phoneNumber'] as String?,
      );

  final String name;
  final String? city;
  final String? phoneNumber;
}
