class DailyAttendanceModel {
  final int id;
  final int studentId;
  final String studentName;
  final String studentRoll;
  final String gradeClass;
  final String date;
  final String status; // PRESENT, ABSENT, ON_LEAVE
  final String remarks;

  DailyAttendanceModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentRoll,
    required this.gradeClass,
    required this.date,
    required this.status,
    required this.remarks,
  });

  factory DailyAttendanceModel.fromJson(Map<String, dynamic> json) {
    return DailyAttendanceModel(
      id: json['id'] ?? 0,
      studentId: json['student'] ?? 0,
      studentName: json['student_name'] ?? '',
      studentRoll: json['student_roll'] ?? '',
      gradeClass: json['grade_class'] ?? '',
      date: json['date'] ?? '',
      status: json['status'] ?? 'PRESENT',
      remarks: json['remarks'] ?? '',
    );
  }

  bool get isPresent => status == 'PRESENT';
  bool get isAbsent => status == 'ABSENT';
  bool get isOnLeave => status == 'ON_LEAVE';
}

class AttendanceSummaryModel {
  final String date;
  final int totalStudents;
  final int present;
  final int absent;
  final int onLeave;
  final int unmarked;
  final double attendancePercentage;

  AttendanceSummaryModel({
    required this.date,
    required this.totalStudents,
    required this.present,
    required this.absent,
    required this.onLeave,
    required this.unmarked,
    required this.attendancePercentage,
  });

  factory AttendanceSummaryModel.fromJson(Map<String, dynamic> json) {
    return AttendanceSummaryModel(
      date: json['date'] ?? '',
      totalStudents: json['total_students'] ?? 0,
      present: json['present'] ?? 0,
      absent: json['absent'] ?? 0,
      onLeave: json['on_leave'] ?? 0,
      unmarked: json['unmarked'] ?? 0,
      attendancePercentage: (json['attendance_percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class RepeatedAbsenteeModel {
  final int studentId;
  final String studentName;
  final String studentCode;
  final String gradeClass;
  final int absentDays;
  final String riskLevel;
  final String alert;

  RepeatedAbsenteeModel({
    required this.studentId,
    required this.studentName,
    required this.studentCode,
    required this.gradeClass,
    required this.absentDays,
    required this.riskLevel,
    required this.alert,
  });

  factory RepeatedAbsenteeModel.fromJson(Map<String, dynamic> json) {
    return RepeatedAbsenteeModel(
      studentId: json['student_id'] ?? 0,
      studentName: json['student_name'] ?? '',
      studentCode: json['student_code'] ?? '',
      gradeClass: json['grade_class'] ?? '',
      absentDays: json['absent_days'] ?? 0,
      riskLevel: json['risk_level'] ?? 'MODERATE',
      alert: json['alert'] ?? '',
    );
  }
}
