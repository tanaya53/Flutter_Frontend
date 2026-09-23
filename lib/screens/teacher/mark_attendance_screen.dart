import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../models/student_model.dart';
import '../../../services/api_service.dart';
import '../../../services/offline_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loading_widget.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final ApiService _api = ApiService();
  final OfflineService _offlineService = OfflineService();

  List<StudentModel> _students = [];
  final Map<int, String> _attendanceMap = {}; // student_id -> PRESENT / ABSENT / ON_LEAVE
  bool _isLoading = true;
  bool _isSubmitting = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadClassStudents();
  }

  Future<void> _loadClassStudents() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.get(ApiConstants.students);
      if (mounted) {
        final list = (res as List<dynamic>).map((e) => StudentModel.fromJson(e)).toList();
        setState(() {
          _students = list;
          for (var s in _students) {
            _attendanceMap[s.id] = 'PRESENT'; // Default all to present
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitAttendance() async {
    setState(() => _isSubmitting = true);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    final payload = _attendanceMap.entries.map((e) {
      return {
        'student_id': e.key,
        'status': e.value,
        'remarks': e.value == 'ABSENT' ? 'Marked by classroom mentor' : '',
      };
    }).toList();

    try {
      // Try direct API submission
      await _api.post(ApiConstants.bulkAttendance, {
        'date': dateStr,
        'attendances': payload,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Attendance recorded successfully for $dateStr!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      // Offline fallback: Queue locally in SharedPreferences
      await _offlineService.queueOfflineAttendance(
        date: dateStr,
        attendances: payload,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Offline mode: Attendance saved locally. Auto-syncs when online.'),
            backgroundColor: AppColors.warning,
          ),
        );
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat('dd MMM yyyy').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Class Attendance'),
        backgroundColor: AppColors.secondary,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, size: 20),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2025),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading classroom roster...')
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: AppColors.secondary.withOpacity(0.08),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Date: $dateFormatted',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.secondary),
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                for (var s in _students) {
                                  _attendanceMap[s.id] = 'PRESENT';
                                }
                              });
                            },
                            child: const Text('All Present', style: TextStyle(color: AppColors.success)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      final currentStatus = _attendanceMap[student.id] ?? 'PRESENT';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.primaryLight.withOpacity(0.12),
                                child: Text(student.firstName[0], style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      student.fullName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    Text(
                                      'Roll: ${student.studentId} • ${student.gradeClass}',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              // Status Toggle Buttons
                              _buildStatusToggle(student.id, currentStatus),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
                  ),
                  child: CustomButton(
                    text: 'Submit Attendance ($dateFormatted)',
                    isLoading: _isSubmitting,
                    backgroundColor: AppColors.secondary,
                    onPressed: _submitAttendance,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatusToggle(int studentId, String currentStatus) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildChoiceBtn(studentId, 'P', 'PRESENT', currentStatus, AppColors.success),
        const SizedBox(width: 4),
        _buildChoiceBtn(studentId, 'A', 'ABSENT', currentStatus, AppColors.error),
        const SizedBox(width: 4),
        _buildChoiceBtn(studentId, 'L', 'ON_LEAVE', currentStatus, AppColors.warning),
      ],
    );
  }

  Widget _buildChoiceBtn(int studentId, String label, String value, String currentStatus, Color color) {
    final isSelected = currentStatus == value;
    return InkWell(
      onTap: () => setState(() => _attendanceMap[studentId] = value),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color, width: isSelected ? 2 : 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
