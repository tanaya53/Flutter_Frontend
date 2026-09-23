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
import 'hostel_rooms_screen.dart';
import 'hostel_attendance_screen.dart';
import 'leave_management_screen.dart';
import 'incidents_screen.dart';
import 'meals_screen.dart';

class WardenDashboard extends StatefulWidget {
  const WardenDashboard({super.key});

  @override
  State<WardenDashboard> createState() => _WardenDashboardState();
}

class _WardenDashboardState extends State<WardenDashboard> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  Map<String, dynamic> _hostelSummary = {};

  @override
  void initState() {
    super.initState();
    _loadWardenData();
  }

  Future<void> _loadWardenData() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.get(ApiConstants.hostelSummary);
      if (mounted) {
        setState(() {
          _hostelSummary = res as Map<String, dynamic>;
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
            const Text('माझी शाळा • Warden Portal'),
            if (school != null)
              Text(
                '${school.name} (${school.schoolId})',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.normal, color: Colors.white70),
              ),
          ],
        ),
        backgroundColor: Colors.brown.shade800,
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
                onRefresh: _loadWardenData,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Warden Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.brown.shade800, Colors.brown.shade600],
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
                              child: const Icon(Icons.night_shelter, color: Colors.white),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.fullName ?? 'Hostel Warden',
                                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Residential Superintendent • ${school?.schoolId ?? ""}',
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
                              title: 'Occupied Beds',
                              value: '${_hostelSummary['occupied_beds'] ?? 0}/${_hostelSummary['total_beds'] ?? 0}',
                              subtitle: '${_hostelSummary['occupancy_percentage'] ?? 0}% Full',
                              icon: Icons.bed_outlined,
                              color: Colors.brown,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HostelRoomsScreen())),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DashboardCard(
                              title: 'Pending Leaves',
                              value: '${_hostelSummary['pending_leave_requests'] ?? 0}',
                              subtitle: 'Leave Requests',
                              icon: Icons.beach_access,
                              color: AppColors.warning,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaveManagementScreen())),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Hostel Operations & Safety Modules',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 10),

                      _buildActionCard(
                        icon: Icons.bed_outlined,
                        color: Colors.brown,
                        title: 'Hostel Rooms & Bed Allocations',
                        subtitle: 'Manage dormitories, bed assignments and vacant cots',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HostelRoomsScreen())),
                      ),
                      _buildActionCard(
                        icon: Icons.checklist_outlined,
                        color: AppColors.primary,
                        title: 'Night Roll Call & Hostel Attendance',
                        subtitle: 'Evening curfew check and accountability of residential students',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HostelAttendanceScreen())),
                      ),
                      _buildActionCard(
                        icon: Icons.flight_takeoff_outlined,
                        color: AppColors.warning,
                        title: 'Student Leave & Movement Passes',
                        subtitle: 'Review parent requests, track departures and returns',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaveManagementScreen())),
                      ),
                      _buildActionCard(
                        icon: Icons.restaurant_menu_outlined,
                        color: AppColors.secondary,
                        title: tr.translate('meal_tracking'),
                        subtitle: 'Daily meal menu, nutrition tracking and kitchen food stocks',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MealsScreen())),
                      ),
                      _buildActionCard(
                        icon: Icons.warning_amber_rounded,
                        color: AppColors.error,
                        title: 'Hostel Incidents & Security Log',
                        subtitle: 'Report maintenance, health, discipline and security issues',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IncidentsScreen())),
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
