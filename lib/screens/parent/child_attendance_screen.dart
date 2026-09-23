import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../models/student_model.dart';
import '../../../services/api_service.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/empty_state.dart';

class ChildAttendanceScreen extends StatefulWidget {
  final StudentModel child;

  const ChildAttendanceScreen({super.key, required this.child});

  @override
  State<ChildAttendanceScreen> createState() => _ChildAttendanceScreenState();
}

class _ChildAttendanceScreenState extends State<ChildAttendanceScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic> _history = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.get(ApiConstants.studentAttendanceHistory(widget.child.id));
      if (mounted) {
        setState(() {
          _history = res as Map<String, dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = (_history['history'] as List<dynamic>?) ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.child.firstName}\'s Attendance'),
        backgroundColor: AppColors.info,
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading attendance record...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _metric('Attendance Rate', '${_history['attendance_rate'] ?? 100}%', AppColors.success),
                        _metric('Present', '${_history['present_days'] ?? 0}', AppColors.success),
                        _metric('Absent', '${_history['absent_days'] ?? 0}', AppColors.error),
                        _metric('Leave', '${_history['leave_days'] ?? 0}', AppColors.warning),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Daily Roll Call Log',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 10),

                  if (list.isEmpty)
                    const EmptyState(title: 'No attendance records recorded yet')
                  else
                    ...list.map(
                      (item) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: Icon(
                            item['status'] == 'PRESENT' ? Icons.check_circle : Icons.cancel,
                            color: item['status'] == 'PRESENT' ? AppColors.success : AppColors.error,
                          ),
                          title: Text(item['date'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text(item['remarks'] ?? ''),
                          trailing: Text(
                            item['status'] ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: item['status'] == 'PRESENT' ? AppColors.success : AppColors.error,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _metric(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
