import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../models/student_model.dart';
import '../../../services/api_service.dart';
import '../../../widgets/student_card.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/empty_state.dart';

class AssignedStudentsScreen extends StatefulWidget {
  const AssignedStudentsScreen({super.key});

  @override
  State<AssignedStudentsScreen> createState() => _AssignedStudentsScreenState();
}

class _AssignedStudentsScreenState extends State<AssignedStudentsScreen> {
  final ApiService _api = ApiService();
  List<StudentModel> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.get(ApiConstants.myStudents);
      if (mounted) {
        setState(() {
          _students = (res as List<dynamic>).map((e) => StudentModel.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Mentored Students'),
        backgroundColor: AppColors.secondary,
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading assigned students...')
          : _students.isEmpty
              ? const EmptyState(title: 'No Assigned Students Found')
              : RefreshIndicator(
                  onRefresh: _loadStudents,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      return StudentCard(student: student);
                    },
                  ),
                ),
    );
  }
}
