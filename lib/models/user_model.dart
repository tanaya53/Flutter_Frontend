class SchoolModel {
  final int id;
  final String schoolId;
  final String name;
  final String district;
  final String state;
  final String schoolType;
  final String contactPhone;

  SchoolModel({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.district,
    required this.state,
    required this.schoolType,
    required this.contactPhone,
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: json['id'] ?? 0,
      schoolId: json['school_id'] ?? '',
      name: json['name'] ?? '',
      district: json['district'] ?? '',
      state: json['state'] ?? 'Maharashtra',
      schoolType: json['school_type'] ?? 'GOVT_ASHRAM',
      contactPhone: json['contact_phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'school_id': schoolId,
    'name': name,
    'district': district,
    'state': state,
    'school_type': schoolType,
    'contact_phone': contactPhone,
  };
}

class UserModel {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String role; // principal, teacher, warden, parent
  final String phoneNumber;
  final bool isApproved;
  final int? schoolId;
  final SchoolModel? schoolDetails;

  UserModel({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    required this.role,
    required this.phoneNumber,
    required this.isApproved,
    this.schoolId,
    this.schoolDetails,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      fullName: json['full_name'] ?? (json['username'] ?? ''),
      email: json['email'] ?? '',
      role: json['role'] ?? 'teacher',
      phoneNumber: json['phone_number'] ?? '',
      isApproved: json['is_approved'] ?? false,
      schoolId: json['school'],
      schoolDetails: json['school_details'] != null
          ? SchoolModel.fromJson(json['school_details'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'first_name': firstName,
    'last_name': lastName,
    'full_name': fullName,
    'email': email,
    'role': role,
    'phone_number': phoneNumber,
    'is_approved': isApproved,
    'school': schoolId,
    'school_details': schoolDetails?.toJson(),
  };

  bool get isPrincipal => role == 'principal';
  bool get isTeacher => role == 'teacher';
  bool get isWarden => role == 'warden';
  bool get isParent => role == 'parent';
}
