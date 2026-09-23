class ScholarshipModel {
  final int id;
  final int studentId;
  final String studentName;
  final String studentClass;
  final String studentRoll;
  final String schemeName;
  final String applicationNumber;
  final double amount;
  final String academicYear;
  final String status;
  final String? disbursementDate;
  final String remarks;

  ScholarshipModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentClass,
    required this.studentRoll,
    required this.schemeName,
    required this.applicationNumber,
    required this.amount,
    required this.academicYear,
    required this.status,
    this.disbursementDate,
    required this.remarks,
  });

  factory ScholarshipModel.fromJson(Map<String, dynamic> json) {
    return ScholarshipModel(
      id: json['id'] ?? 0,
      studentId: json['student'] ?? 0,
      studentName: json['student_name'] ?? '',
      studentClass: json['student_class'] ?? '',
      studentRoll: json['student_roll'] ?? '',
      schemeName: json['scheme_name'] ?? '',
      applicationNumber: json['application_number'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      academicYear: json['academic_year'] ?? '2026-2027',
      status: json['status'] ?? 'PENDING',
      disbursementDate: json['disbursement_date'],
      remarks: json['remarks'] ?? '',
    );
  }
}

class WelfareSchemeModel {
  final int id;
  final String name;
  final String category;
  final String targetClass;
  final int totalEligible;
  final int totalDistributed;
  final String status;
  final double completionPercentage;

  WelfareSchemeModel({
    required this.id,
    required this.name,
    required this.category,
    required this.targetClass,
    required this.totalEligible,
    required this.totalDistributed,
    required this.status,
    required this.completionPercentage,
  });

  factory WelfareSchemeModel.fromJson(Map<String, dynamic> json) {
    return WelfareSchemeModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? 'UNIFORM',
      targetClass: json['target_class'] ?? '',
      totalEligible: json['total_eligible'] ?? 0,
      totalDistributed: json['total_distributed'] ?? 0,
      status: json['status'] ?? 'IN_PROGRESS',
      completionPercentage:
          (json['completion_percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
