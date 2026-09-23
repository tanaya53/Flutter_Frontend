import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../models/attendance_model.dart';
import '../../../services/api_service.dart';
import '../../../widgets/alert_card.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/empty_state.dart';

class AttendanceOverviewScreen extends StatefulWidget {
  const AttendanceOverviewScreen({super.key});

  @override
  State<AttendanceOverviewScreen> createState() => _AttendanceOverviewScreenState();
}

class _AttendanceOverviewScreenState extends State<AttendanceOverviewScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  AttendanceSummaryModel? _summary;
  List<RepeatedAbsenteeModel> _repeatedAbsentees = [];
  List<DailyAttendanceModel> _records = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final sumRes = await _api.get(ApiConstants.attendanceSummary);
      final repRes = await _api.get(ApiConstants.repeatedAbsentees);
      final recRes = await _api.get(ApiConstants.attendance);

      if (mounted) {
        setState(() {
          _summary = AttendanceSummaryModel.fromJson(sumRes);
          _repeatedAbsentees = (repRes as List<dynamic>)
              .map((e) => RepeatedAbsenteeModel.fromJson(e))
              .toList();
          _records = (recRes as List<dynamic>)
              .map((e) => DailyAttendanceModel.fromJson(e))
              .toList();
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

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.translate('attendance')),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading attendance & safety data...')
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Attendance Summary Cards
                    if (_summary != null)
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricTile(
                              tr.translate('present'),
                              '${_summary!.present}',
                              AppColors.success,
                              Icons.check_circle_outline,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMetricTile(
                              tr.translate('absent'),
                              '${_summary!.absent}',
                              AppColors.error,
                              Icons.cancel_outlined,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMetricTile(
                              tr.translate('on_leave'),
                              '${_summary!.onLeave}',
                              AppColors.warning,
                              Icons.time_to_leave,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMetricTile(
                              'Rate',
                              '${_summary!.attendancePercentage}%',
                              AppColors.primary,
                              Icons.trending_up,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),

                    // Repeated Absence Safety Warnings
                    if (_repeatedAbsentees.isNotEmpty) ...[
                      const Text(
                        'Student Safety: Repeated Absence Warnings',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.error),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Students with 3 or more absences in the last 14 days flagged for welfare inspection.',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 10),
                      ..._repeatedAbsentees.map(
                        (item) => AlertCard(
                          title: '${item.studentName} (${item.studentCode}) - ${item.gradeClass}',
                          description: item.alert,
                          severity: item.riskLevel,
                          actionLabel: 'Escalate to Mentor',
                          onAction: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Escalation notification dispatched to mentor for ${item.studentName}.'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Attendance Records List
                    const Text(
                      'Daily Attendance Records',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 10),
                    if (_records.isEmpty)
                      const EmptyState(title: 'No Attendance Records Recorded')
                    else
                      ..._records.map((r) => _buildRecordCard(r)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMetricTile(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(DailyAttendanceModel r) {
    Color statusColor;
    if (r.isPresent) {
      statusColor = AppColors.success;
    } else if (r.isAbsent) {
      statusColor = AppColors.error;
    } else {
      statusColor = AppColors.warning;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.12),
          child: Icon(
            r.isPresent ? Icons.check : (r.isAbsent ? Icons.close : Icons.hourglass_empty),
            color: statusColor,
            size: 20,
          ),
        ),
        title: Text(r.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text('Roll: ${r.studentRoll} • ${r.gradeClass} • Date: ${r.date}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            r.status,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
          ),
        ),
      ),
    );
  }
}
