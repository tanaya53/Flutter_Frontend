import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/student_model.dart';

class ChildProfileScreen extends StatelessWidget {
  final StudentModel child;

  const ChildProfileScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${child.firstName}\'s Institutional Profile'),
        backgroundColor: AppColors.info,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.info.withOpacity(0.15),
                      child: Text(
                        child.firstName[0],
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.info),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      child.fullName,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Roll No: ${child.studentId} • Admission: ${child.admissionNumber}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    _row('Class & Division', '${child.gradeClass} (${child.division})'),
                    _row('Gender', child.gender),
                    _row('Blood Group', child.bloodGroup),
                    _row('Hostel Block', child.hostelBlock.isEmpty ? 'Day Scholar' : child.hostelBlock),
                    _row('Dormitory Room', child.roomNumber.isEmpty ? 'N/A' : 'Room ${child.roomNumber}, Bed ${child.bedNumber}'),
                    _row('Assigned Mentor', child.assignedMentorName ?? 'Assigned Faculty Mentor'),
                    _row('Emergency Contact', child.emergencyContact),
                    _row('Home Address', child.address),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textMuted, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}
