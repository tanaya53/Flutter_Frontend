import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/language_toggle.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/connection_status_bar.dart';
import '../auth/login_screen.dart';
import 'students/student_list_screen.dart';
import 'staff/staff_approval_screen.dart';
import 'hostel/hostel_overview_screen.dart';
import 'attendance/attendance_overview_screen.dart';
import 'health/health_overview_screen.dart';
import 'scholarships/scholarships_screen.dart';
import 'inventory/inventory_screen.dart';
import 'reports/reports_screen.dart';

class PrincipalDashboard extends StatefulWidget {
  const PrincipalDashboard({super.key});

  @override
  State<PrincipalDashboard> createState() => _PrincipalDashboardState();
}

class _PrincipalDashboardState extends State<PrincipalDashboard> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  Map<String, dynamic> _analytics = {};

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.get(ApiConstants.principalAnalytics);
      if (mounted) {
        setState(() {
          _analytics = res as Map<String, dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
            Text(tr.translate('app_title')),
            if (school != null)
              Text(
                '${school.name} (${school.schoolId})',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.normal, color: Colors.white70),
              ),
          ],
        ),
        backgroundColor: AppColors.primary,
        actions: [
          const LanguageToggle(isDark: true),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'Refresh',
          ),
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
            tooltip: tr.translate('logout'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const ConnectionStatusBar(),
            Expanded(
              child: _isLoading
                  ? const LoadingWidget(message: 'Loading Institutional Dashboard...')
                  : RefreshIndicator(
                      onRefresh: _loadDashboardData,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Principal Welcome Banner
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.primary, AppColors.primaryLight],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: Colors.white.withOpacity(0.2),
                                    child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${tr.translate('dashboard')} • Principal',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.85),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          user?.fullName ?? 'Principal',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'School ID: ${school?.schoolId ?? "N/A"} • ${school?.district ?? ""}',
                                          style: const TextStyle(color: AppColors.accentLight, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Pending User Approvals Action Banner
                            if ((_analytics['pending_staff_approvals'] ?? 0) > 0) ...[
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const StaffApprovalScreen()),
                                  ).then((_) => _loadDashboardData());
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.warning),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.person_add_alt_1, color: AppColors.warning),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          '${_analytics['pending_staff_approvals']} new staff/parent registration request(s) awaiting your approval.',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      const Text(
                                        'Review',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.warning,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Metric Cards Grid
                            const Text(
                              'Key Operational Metrics',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 10),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final crossAxisCount = constraints.maxWidth > 800 ? 4 : (constraints.maxWidth > 500 ? 3 : 2);
                                return GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 1.15,
                                  children: [
                                    DashboardCard(
                                      title: tr.translate('total_students'),
                                      value: '${_analytics['total_students'] ?? 0}',
                                      subtitle: 'M: ${_analytics['male_students'] ?? 0} | F: ${_analytics['female_students'] ?? 0}',
                                      icon: Icons.people_outline,
                                      color: AppColors.primary,
                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentListScreen())),
                                    ),
                                    DashboardCard(
                                      title: tr.translate('attendance_rate'),
                                      value: '${_analytics['attendance_percentage'] ?? 0}%',
                                      subtitle: 'Today: ${_analytics['present_today'] ?? 0} present',
                                      icon: Icons.event_available,
                                      color: AppColors.success,
                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceOverviewScreen())),
                                    ),
                                    DashboardCard(
                                      title: tr.translate('hostel_occupancy'),
                                      value: '${_analytics['hostel_occupancy_percentage'] ?? 0}%',
                                      subtitle: '${_analytics['occupied_beds'] ?? 0}/${_analytics['total_beds'] ?? 0} beds',
                                      icon: Icons.bed_outlined,
                                      color: AppColors.accent,
                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HostelOverviewScreen())),
                                    ),
                                    DashboardCard(
                                      title: tr.translate('health_alerts'),
                                      value: '${_analytics['active_health_alerts'] ?? 0}',
                                      subtitle: 'Requiring Care',
                                      icon: Icons.medical_services_outlined,
                                      color: (_analytics['active_health_alerts'] ?? 0) > 0 ? AppColors.error : AppColors.secondary,
                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthOverviewScreen())),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 20),

                            // Management Modules Quick Navigation
                            const Text(
                              'Institutional Management Modules',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 10),

                            _buildModuleTile(
                              icon: Icons.school_outlined,
                              color: AppColors.primary,
                              title: tr.translate('students'),
                              subtitle: 'Directory, enrollment, mentor assignment & profiles',
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentListScreen())),
                            ),
                            _buildModuleTile(
                              icon: Icons.fact_check_outlined,
                              color: AppColors.success,
                              title: tr.translate('attendance'),
                              subtitle: 'Daily student attendance, hostel roll-call & safety risk detection',
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceOverviewScreen())),
                            ),
                            _buildModuleTile(
                              icon: Icons.hotel_outlined,
                              color: Colors.brown,
                              title: tr.translate('hostel'),
                              subtitle: 'Blocks, dorm rooms, bed occupancy & student leaves',
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HostelOverviewScreen())),
                            ),
                            _buildModuleTile(
                              icon: Icons.health_and_safety_outlined,
                              color: AppColors.error,
                              title: tr.translate('health'),
                              subtitle: 'Medical checkups, vaccinations & emergency dispensary cases',
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthOverviewScreen())),
                            ),
                            _buildModuleTile(
                              icon: Icons.card_giftcard_outlined,
                              color: Colors.deepPurple,
                              title: tr.translate('scholarships'),
                              subtitle: 'Tribal pre-matric grants, uniform & textbook distribution',
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScholarshipsScreen())),
                            ),
                            _buildModuleTile(
                              icon: Icons.inventory_2_outlined,
                              color: Colors.teal,
                              title: tr.translate('inventory'),
                              subtitle: 'Hostel bedding, uniforms, laboratory and athletic assets',
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryScreen())),
                            ),
                            _buildModuleTile(
                              icon: Icons.verified_user_outlined,
                              color: AppColors.warning,
                              title: 'Staff Approvals',
                              subtitle: 'Approve new teachers, hostel wardens and parent accounts',
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffApprovalScreen())),
                            ),
                            _buildModuleTile(
                              icon: Icons.picture_as_pdf_outlined,
                              color: AppColors.primaryLight,
                              title: tr.translate('reports'),
                              subtitle: 'Export official PDF and Excel reports for Tribal Welfare Dept',
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen())),
                            ),
                            const SizedBox(height: 24),
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

  Widget _buildModuleTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
      ),
    );
  }
}
