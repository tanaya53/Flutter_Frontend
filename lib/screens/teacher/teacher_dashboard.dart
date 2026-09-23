import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/language_toggle.dart';
import '../../widgets/connection_status_bar.dart';
import '../auth/login_screen.dart';
import 'assigned_students_screen.dart';
import 'mark_attendance_screen.dart';
import 'academic_remarks_screen.dart';
import 'health_alerts_screen.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  Map<String, dynamic> _attendanceSummary = {};
  List<dynamic> _myStudents = [];

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
  }

  Future<void> _loadTeacherData() async {
    setState(() => _isLoading = true);
    try {
      final sumRes = await _api.get(ApiConstants.attendanceSummary);
      final studRes = await _api.get(ApiConstants.myStudents);
      if (mounted) {
        setState(() {
          _attendanceSummary = sumRes as Map<String, dynamic>;
          _myStudents = studRes as List<dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final school = user?.schoolDetails;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('माझी शाळा • Teacher Portal'),
            if (school != null)
              Text(
                '${school.name} (${school.schoolId})',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.normal, color: Colors.white70),
              ),
          ],
        ),
        backgroundColor: AppColors.secondary,
        actions: [
          const LanguageToggle(isDark: true),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const ConnectionStatusBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadTeacherData,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Profile Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.secondary, AppColors.secondaryLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              child: const Icon(Icons.cast_for_education, color: Colors.white),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.fullName ?? 'Teacher',
                                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Mentor • ${school?.name ?? "Ashram School"}',
                                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Metrics
                      Row(
                        children: [
                          Expanded(
                            child: DashboardCard(
                              title: 'My Mentored Students',
                              value: '${_myStudents.length}',
                              subtitle: 'Active Wards',
                              icon: Icons.people_outline,
                              color: AppColors.secondary,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AssignedStudentsScreen())),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DashboardCard(
                              title: "Today's Present",
                              value: '${_attendanceSummary['present'] ?? 0}',
                              subtitle: 'Class Roll Call',
                              icon: Icons.check_circle_outline,
                              color: AppColors.success,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MarkAttendanceScreen())),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Teacher Actions & Classroom Tools',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 10),

                      _buildActionCard(
                        icon: Icons.playlist_add_check_rounded,
                        color: AppColors.success,
                        title: tr.translate('mark_attendance'),
                        subtitle: 'Record daily classroom attendance for your assigned class',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MarkAttendanceScreen())),
                      ),
                      _buildActionCard(
                        icon: Icons.people_alt_outlined,
                        color: AppColors.primary,
                        title: 'Assigned Mentee Profiles',
                        subtitle: 'View student performance, room allocation and guardian contacts',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AssignedStudentsScreen())),
                      ),
                      _buildActionCard(
                        icon: Icons.rate_review_outlined,
                        color: Colors.deepPurple,
                        title: tr.translate('academic_remarks'),
                        subtitle: 'Add unit test remarks, student concerns & emotional wellbeing logs',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AcademicRemarksScreen())),
                      ),
                      _buildActionCard(
                        icon: Icons.medical_services_outlined,
                        color: AppColors.error,
                        title: tr.translate('health_alerts'),
                        subtitle: 'View medical checkup alerts for students in your class',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthAlertsScreen())),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
      ),
    );
  }
}
