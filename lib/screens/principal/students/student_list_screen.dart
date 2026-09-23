import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../models/student_model.dart';
import '../../../services/api_service.dart';
import '../../../widgets/student_card.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/empty_state.dart';
import 'student_form_screen.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<StudentModel> _students = [];
  bool _isLoading = true;
  String _selectedClassFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    try {
      String url = ApiConstants.students;
      if (_selectedClassFilter != 'ALL') {
        url += '?grade_class=${Uri.encodeComponent(_selectedClassFilter)}';
      }
      final res = await _api.get(url);
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

  List<StudentModel> get _filteredStudents {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _students;
    return _students.where((s) {
      return s.fullName.toLowerCase().contains(query) ||
          s.studentId.toLowerCase().contains(query) ||
          s.gradeClass.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.translate('students')),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: tr.translate('add_student'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StudentFormScreen()),
              ).then((val) {
                if (val == true) _loadStudents();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter & Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search by name, roll no, class...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('ALL', 'All Classes'),
                      _buildFilterChip('Class 6', 'Class 6'),
                      _buildFilterChip('Class 7', 'Class 7'),
                      _buildFilterChip('Class 8', 'Class 8'),
                      _buildFilterChip('Class 9', 'Class 9'),
                      _buildFilterChip('Class 10', 'Class 10'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          Expanded(
            child: _isLoading
                ? const LoadingWidget(message: 'Loading student directory...')
                : _filteredStudents.isEmpty
                    ? EmptyState(
                        title: 'No Students Found',
                        subtitle: 'Tap the + button to enroll a new ashram school student.',
                        onRetry: _loadStudents,
                      )
                    : RefreshIndicator(
                        onRefresh: _loadStudents,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _filteredStudents.length,
                          itemBuilder: (context, index) {
                            final student = _filteredStudents[index];
                            return StudentCard(
                              student: student,
                              onTap: () {
                                _showStudentDetailsModal(student);
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedClassFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() => _selectedClassFilter = value);
          _loadStudents();
        },
        selectedColor: AppColors.primaryLight.withOpacity(0.15),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }

  void _showStudentDetailsModal(StudentModel student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                controller: controller,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primary.withOpacity(0.12),
                        child: Text(
                          student.firstName[0].toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.fullName,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Roll No: ${student.studentId} • ${student.gradeClass} (${student.division})',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: AppColors.border),
                  _buildDetailRow('Gender', student.gender),
                  _buildDetailRow('Blood Group', student.bloodGroup),
                  _buildDetailRow('Hostel Block', student.hostelBlock.isEmpty ? 'Day Scholar' : student.hostelBlock),
                  _buildDetailRow('Room & Bed', student.roomNumber.isEmpty ? 'N/A' : 'Room ${student.roomNumber}, Bed ${student.bedNumber}'),
                  _buildDetailRow('Assigned Mentor', student.assignedMentorName ?? 'Not Assigned'),
                  _buildDetailRow('Emergency Contact', student.emergencyContact),
                  _buildDetailRow('Residential Address', student.address),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textMuted, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
