class AbsenceRequestItem {
  const AbsenceRequestItem({
    required this.id,
    required this.studentId,
    required this.date,
    required this.tripType,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory AbsenceRequestItem.fromJson(Map<String, dynamic> json) {
    final raw = json['date'];
    final date = raw is String
        ? DateTime.parse(raw)
        : DateTime.now();
    return AbsenceRequestItem(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      date: DateTime(date.year, date.month, date.day),
      tripType: (json['tripType'] as String?) ?? 'FullDay',
      reason: (json['reason'] as String?) ?? 'Other',
      status: (json['status'] as String?) ?? 'Pending',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final String id;
  final String studentId;
  final DateTime date;
  final String tripType; // FullDay | MorningOnly | ReturnOnly
  final String reason;
  final String status; // Pending | Approved | Rejected
  final DateTime createdAt;
}
