import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../models/health_model.dart';
import '../../../services/api_service.dart';
import '../../../widgets/alert_card.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/empty_state.dart';

class HealthAlertsScreen extends StatefulWidget {
  const HealthAlertsScreen({super.key});

  @override
  State<HealthAlertsScreen> createState() => _HealthAlertsScreenState();
}

class _HealthAlertsScreenState extends State<HealthAlertsScreen> {
  final ApiService _api = ApiService();
  List<EmergencyAlertModel> _alerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.get(ApiConstants.healthAlerts);
      if (mounted) {
        setState(() {
          _alerts = (res as List<dynamic>).map((e) => EmergencyAlertModel.fromJson(e)).toList();
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
        title: const Text('Class Health Alerts'),
        backgroundColor: AppColors.secondary,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAlerts),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Checking student health alerts...')
          : _alerts.isEmpty
              ? const EmptyState(
                  title: 'No Health Alerts',
                  subtitle: 'All students are in good health. No active emergencies.',
                  icon: Icons.favorite_outline,
                )
              : RefreshIndicator(
                  onRefresh: _loadAlerts,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: _alerts.length,
                    itemBuilder: (context, index) {
                      final alert = _alerts[index];
                      return AlertCard(
                        title: '${alert.title} • ${alert.studentName} (${alert.studentClass})',
                        description: alert.description,
                        severity: alert.severity,
                      );
                    },
                  ),
                ),
    );
  }
}
