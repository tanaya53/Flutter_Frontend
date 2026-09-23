class StudentModel {
  final int id;
  final String studentId; // e.g. ASH001-S01
  final String firstName;
  final String lastName;
  final String fullName;
  final String photoUrl;
  final String? dob;
  final String gender;
  final String gradeClass;
  final String division;
  final String admissionNumber;
  final String address;
  final String emergencyContact;
  final String bloodGroup;
  final int? assignedMentorId;
  final String? assignedMentorName;
  final String hostelBlock;
  final String roomNumber;
  final String bedNumber;
  final bool isActive;

  StudentModel({
    required this.id,
    required this.studentId,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.photoUrl,
    this.dob,
    required this.gender,
    required this.gradeClass,
    required this.division,
    required this.admissionNumber,
    required this.address,
    required this.emergencyContact,
    required this.bloodGroup,
    this.assignedMentorId,
    this.assignedMentorName,
    required this.hostelBlock,
    required this.roomNumber,
    required this.bedNumber,
    required this.isActive,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] ?? 0,
      studentId: json['student_id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      fullName: json['full_name'] ?? '${json['first_name']} ${json['last_name']}',
      photoUrl: json['photo_url'] ?? '',
      dob: json['dob'],
      gender: json['gender'] ?? 'MALE',
      gradeClass: json['grade_class'] ?? '',
      division: json['division'] ?? 'A',
      admissionNumber: json['admission_number'] ?? '',
      address: json['address'] ?? '',
      emergencyContact: json['emergency_contact'] ?? '',
      bloodGroup: json['blood_group'] ?? 'O+',
      assignedMentorId: json['assigned_mentor'],
      assignedMentorName: json['assigned_mentor_name'],
      hostelBlock: json['hostel_block'] ?? '',
      roomNumber: json['room_number'] ?? '',
      bedNumber: json['bed_number'] ?? '',
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'student_id': studentId,
    'first_name': firstName,
    'last_name': lastName,
    'dob': dob,
    'gender': gender,
    'grade_class': gradeClass,
    'division': division,
    'admission_number': admissionNumber,
    'address': address,
    'emergency_contact': emergencyContact,
    'blood_group': bloodGroup,
    'assigned_mentor': assignedMentorId,
    'hostel_block': hostelBlock,
    'room_number': roomNumber,
    'bed_number': bedNumber,
    'is_active': isActive,
  };
}
