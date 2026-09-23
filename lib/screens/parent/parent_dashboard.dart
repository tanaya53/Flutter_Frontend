import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../models/student_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/language_toggle.dart';
import '../../widgets/connection_status_bar.dart';
import '../../widgets/loading_widget.dart';
import '../auth/login_screen.dart';
import 'child_profile_screen.dart';
import 'child_attendance_screen.dart';
import 'health_screen.dart';
import 'announcements_screen.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  final ApiService _api = ApiService();
  StudentModel? _child;
  bool _isLoading = true;
  Map<String, dynamic> _attendanceHistory = {};

  @override
  void initState() {
    super.initState();
    _loadChildData();
  }

  Future<void> _loadChildData() async {
    setState(() => _isLoading = true);
    try {
      final childRes = await _api.get(ApiConstants.myChild);
      final student = StudentModel.fromJson(childRes);
      final attRes = await _api.get(ApiConstants.studentAttendanceHistory(student.id));

      if (mounted) {
        setState(() {
          _child = student;
          _attendanceHistory = attRes as Map<String, dynamic>;
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
            const Text('माझी शाळा • Parent Portal'),
            if (school != null)
              Text(
                '${school.name} (${school.schoolId})',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.normal, color: Colors.white70),
              ),
          ],
        ),
        backgroundColor: AppColors.info,
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
              child: _isLoading
                  ? const LoadingWidget(message: 'Connecting to child institutional profile...')
                  : RefreshIndicator(
                      onRefresh: _loadChildData,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Child Profile Hero Banner
                            if (_child != null)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.info, Color(0xFF2B6CB0)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor: Colors.white,
                                      child: Text(
                                        _child!.firstName[0],
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.info,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _child!.fullName,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Roll No: ${_child!.studentId} • ${_child!.gradeClass}',
                                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                                          ),
                                          Text(
                                            'Hostel: ${_child!.hostelBlock.isEmpty ? "Day Scholar" : "${_child!.hostelBlock} (Room ${_child!.roomNumber})"}',
                                            style: const TextStyle(color: AppColors.accentLight, fontSize: 12),
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
                                    title: 'Attendance Rate',
                                    value: '${_attendanceHistory['attendance_rate'] ?? 100}%',
                                    subtitle: '${_attendanceHistory['present_days'] ?? 0}/${_attendanceHistory['total_days'] ?? 0} Days Present',
                                    icon: Icons.event_available,
                                    color: AppColors.success,
                                    onTap: () {
                                      if (_child != null) {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => ChildAttendanceScreen(child: _child!)));
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: DashboardCard(
                                    title: 'Blood Group',
                                    value: _child?.bloodGroup ?? 'O+',
                                    subtitle: 'Medical Profile',
                                    icon: Icons.health_and_safety,
                                    color: AppColors.error,
                                    onTap: () {
                                      if (_child != null) {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => ParentHealthScreen(child: _child!)));
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            const Text(
                              'Parent Services & Ward Tracking',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 10),

                            _buildActionCard(
                              icon: Icons.badge_outlined,
                              color: AppColors.primary,
                              title: 'Student Institutional Profile',
                              subtitle: 'Admission number, residential dormitory, mentor details',
                              onTap: () {
                                if (_child != null) {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => ChildProfileScreen(child: _child!)));
                                }
                              },
                            ),
                            _buildActionCard(
                              icon: Icons.fact_check_outlined,
                              color: AppColors.success,
                              title: 'Attendance Records',
                              subtitle: 'Monthly daily roll call history & leave tracking',
                              onTap: () {
                                if (_child != null) {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => ChildAttendanceScreen(child: _child!)));
                                }
                              },
                            ),
                            _buildActionCard(
                              icon: Icons.medical_services_outlined,
                              color: AppColors.error,
                              title: 'Health, Vaccines & Checkups',
                              subtitle: 'Doctor visits, prescriptions & dispensary observations',
                              onTap: () {
                                if (_child != null) {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => ParentHealthScreen(child: _child!)));
                                }
                              },
                            ),
                            _buildActionCard(
                              icon: Icons.campaign_outlined,
                              color: Colors.deepPurple,
                              title: tr.translate('announcements'),
                              subtitle: 'School notices, holiday circulars & emergency alerts',
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ParentAnnouncementsScreen())),
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
