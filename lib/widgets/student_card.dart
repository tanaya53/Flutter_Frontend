import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/student_model.dart';

class StudentCard extends StatelessWidget {
  final StudentModel student;
  final VoidCallback? onTap;
  final Widget? trailing;

  const StudentCard({
    super.key,
    required this.student,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        onTap: onTap,
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primaryLight.withOpacity(0.15),
          child: Text(
            student.firstName.isNotEmpty ? student.firstName[0].toUpperCase() : 'S',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        title: Text(
          student.fullName,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  student.gradeClass,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Roll: ${student.studentId}',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              if (student.hostelBlock.isNotEmpty) ...[
                const SizedBox(width: 6),
                const Text('•', style: TextStyle(color: AppColors.textMuted)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Room ${student.roomNumber}',
                    style: const TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
      ),
    );
  }
}
