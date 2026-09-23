import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../models/student_model.dart';
import '../../../services/api_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loading_widget.dart';

class HostelAttendanceScreen extends StatefulWidget {
  const HostelAttendanceScreen({super.key});

  @override
  State<HostelAttendanceScreen> createState() => _HostelAttendanceScreenState();
}

class _HostelAttendanceScreenState extends State<HostelAttendanceScreen> {
  final ApiService _api = ApiService();
  List<StudentModel> _students = [];
  final Map<int, String> _hostelStatus = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadHostelResidents();
  }

  Future<void> _loadHostelResidents() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.get(ApiConstants.students);
      if (mounted) {
        final list = (res as List<dynamic>).map((e) => StudentModel.fromJson(e)).toList();
        setState(() {
          _students = list;
          for (var s in _students) {
            _hostelStatus[s.id] = 'PRESENT';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitNightRollCall() async {
    setState(() => _isSaving = true);
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Submit records
    try {
      for (var entry in _hostelStatus.entries) {
        await _api.post(ApiConstants.hostelAttendance, {
          'student': entry.key,
          'date': today,
          'session': 'NIGHT',
          'status': entry.value,
          'remarks': 'Recorded in Night Roll Call',
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hostel Night Roll Call completed successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hostel Night Roll Call'),
        backgroundColor: Colors.brown.shade800,
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading dormitory roll...')
          : Column(
              children: [
                Container(
                  color: Colors.brown.shade50,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.nightlight_round, color: Colors.brown, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Night Curfew Verification • ${DateFormat("dd MMM yyyy").format(DateTime.now())}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown.shade900, fontSize: 13),
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
                      final status = _hostelStatus[student.id] ?? 'PRESENT';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.brown.shade100,
                                child: Text(
                                  student.firstName[0],
                                  style: TextStyle(color: Colors.brown.shade900, fontWeight: FontWeight.bold),
                                ),
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
                                      '${student.hostelBlock.isEmpty ? "Hostel" : student.hostelBlock} • Room ${student.roomNumber.isEmpty ? "101" : student.roomNumber}',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  ChoiceChip(
                                    label: const Text('In Dorm'),
                                    selected: status == 'PRESENT',
                                    selectedColor: AppColors.success.withOpacity(0.2),
                                    onSelected: (_) => setState(() => _hostelStatus[student.id] = 'PRESENT'),
                                  ),
                                  const SizedBox(width: 6),
                                  ChoiceChip(
                                    label: const Text('Missing'),
                                    selected: status == 'ABSENT',
                                    selectedColor: AppColors.error.withOpacity(0.2),
                                    onSelected: (_) => setState(() => _hostelStatus[student.id] = 'ABSENT'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: CustomButton(
                    text: 'Confirm Night Roll Call',
                    isLoading: _isSaving,
                    backgroundColor: Colors.brown.shade800,
                    onPressed: _submitNightRollCall,
                  ),
                ),
              ],
            ),
    );
  }
}
