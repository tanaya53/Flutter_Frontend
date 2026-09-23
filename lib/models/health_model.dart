class HealthRecordModel {
  final int id;
  final int studentId;
  final String studentName;
  final String bloodGroup;
  final String allergies;
  final String chronicConditions;
  final double? heightCm;
  final double? weightKg;
  final String emergencyNotes;

  HealthRecordModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.bloodGroup,
    required this.allergies,
    required this.chronicConditions,
    this.heightCm,
    this.weightKg,
    required this.emergencyNotes,
  });

  factory HealthRecordModel.fromJson(Map<String, dynamic> json) {
    return HealthRecordModel(
      id: json['id'] ?? 0,
      studentId: json['student'] ?? 0,
      studentName: json['student_name'] ?? '',
      bloodGroup: json['blood_group'] ?? 'O+',
      allergies: json['allergies'] ?? 'None',
      chronicConditions: json['chronic_conditions'] ?? 'None',
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      emergencyNotes: json['emergency_medical_notes'] ?? '',
    );
  }
}

class EmergencyAlertModel {
  final int id;
  final int studentId;
  final String studentName;
  final String studentClass;
  final String title;
  final String description;
  final String severity; // LOW, MEDIUM, HIGH, CRITICAL
  final String status; // ACTIVE, UNDER_CARE, RESOLVED
  final bool hospitalAdmitted;
  final String reportedByName;
  final String reportedAt;

  EmergencyAlertModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentClass,
    required this.title,
    required this.description,
    required this.severity,
    required this.status,
    required this.hospitalAdmitted,
    required this.reportedByName,
    required this.reportedAt,
  });

  factory EmergencyAlertModel.fromJson(Map<String, dynamic> json) {
    return EmergencyAlertModel(
      id: json['id'] ?? 0,
      studentId: json['student'] ?? 0,
      studentName: json['student_name'] ?? '',
      studentClass: json['student_class'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      severity: json['severity'] ?? 'MEDIUM',
      status: json['status'] ?? 'ACTIVE',
      hospitalAdmitted: json['hospital_admitted'] ?? false,
      reportedByName: json['reported_by_name'] ?? '',
      reportedAt: json['reported_at'] ?? '',
    );
  }

  bool get isCritical => severity == 'CRITICAL' || severity == 'HIGH';
}
