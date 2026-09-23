import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../models/health_model.dart';
import '../../../services/api_service.dart';
import '../../../widgets/alert_card.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/empty_state.dart';

class HealthOverviewScreen extends StatefulWidget {
  const HealthOverviewScreen({super.key});

  @override
  State<HealthOverviewScreen> createState() => _HealthOverviewScreenState();
}

class _HealthOverviewScreenState extends State<HealthOverviewScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  Map<String, dynamic> _summary = {};
  List<EmergencyAlertModel> _alerts = [];
  List<HealthRecordModel> _records = [];

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  Future<void> _loadHealthData() async {
    setState(() => _isLoading = true);
    try {
      final sumRes = await _api.get(ApiConstants.healthSummary);
      final alertRes = await _api.get(ApiConstants.healthAlerts);
      final recRes = await _api.get(ApiConstants.healthProfiles);

      if (mounted) {
        setState(() {
          _summary = sumRes as Map<String, dynamic>;
          _alerts = (alertRes as List<dynamic>).map((e) => EmergencyAlertModel.fromJson(e)).toList();
          _records = (recRes as List<dynamic>).map((e) => HealthRecordModel.fromJson(e)).toList();
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
        title: Text(tr.translate('health')),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadHealthData),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading health records...')
          : RefreshIndicator(
              onRefresh: _loadHealthData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Health Summary Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.error.withOpacity(0.25)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Active Emergencies', '${_summary['active_emergency_cases'] ?? 0}', AppColors.error),
                          _buildStatItem('Needing Care', '${_summary['students_requiring_attention'] ?? 0}', AppColors.warning),
                          _buildStatItem('Recent Checkups', '${_summary['recent_checkups_30d'] ?? 0}', AppColors.success),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Active Emergency Medical Alerts
                    if (_alerts.isNotEmpty) ...[
                      const Text(
                        'Active Emergency Medical Alerts',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.error),
                      ),
                      const SizedBox(height: 10),
                      ..._alerts.map(
                        (alert) => AlertCard(
                          title: '${alert.title} • ${alert.studentName} (${alert.studentClass})',
                          description: alert.description,
                          severity: alert.severity,
                          actionLabel: 'Dispensary Protocol',
                          onAction: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Dispensary protocol and doctor visit acknowledged.'),
                                backgroundColor: AppColors.secondary,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Student Health Profiles Directory
                    const Text(
                      'Student Health Profiles & Medical History',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 10),

                    if (_records.isEmpty)
                      const EmptyState(title: 'No Health Records Found')
                    else
                      ..._records.map(
                        (rec) => Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.error.withOpacity(0.12),
                              child: Text(
                                rec.bloodGroup,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.error),
                              ),
                            ),
                            title: Text(rec.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text(
                              'Allergies: ${rec.allergies}\nConditions: ${rec.chronicConditions}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            isThreeLine: true,
                            trailing: rec.emergencyNotes.isNotEmpty
                                ? const Tooltip(
                                    message: 'Special Emergency Notes Available',
                                    child: Icon(Icons.info, color: AppColors.warning, size: 20),
                                  )
                                : null,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      ],
    );
  }
}
