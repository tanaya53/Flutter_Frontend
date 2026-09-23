class AnnouncementModel {
  final int id;
  final String title;
  final String message;
  final String targetRole;
  final String targetClass;
  final bool isEmergency;
  final String? createdByName;
  final String createdAt;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.message,
    required this.targetRole,
    required this.targetClass,
    required this.isEmergency,
    this.createdByName,
    required this.createdAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      targetRole: json['target_role'] ?? 'ALL',
      targetClass: json['target_class'] ?? 'All',
      isEmergency: json['is_emergency'] ?? false,
      createdByName: json['created_by_name'],
      createdAt: json['created_at'] ?? '',
    );
  }
}
