import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../models/student_model.dart';
import '../../../services/api_service.dart';
import '../../../widgets/loading_widget.dart';

class ParentHealthScreen extends StatefulWidget {
  final StudentModel child;

  const ParentHealthScreen({super.key, required this.child});

  @override
  State<ParentHealthScreen> createState() => _ParentHealthScreenState();
}

class _ParentHealthScreenState extends State<ParentHealthScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic> _healthDetail = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHealth();
  }

  Future<void> _loadHealth() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.get(ApiConstants.studentHealthDetail(widget.child.id));
      if (mounted) {
        setState(() {
          _healthDetail = res as Map<String, dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _healthDetail['health_profile'] ?? {};
    final checkups = (_healthDetail['checkups'] as List<dynamic>?) ?? [];
    final vaccines = (_healthDetail['vaccinations'] as List<dynamic>?) ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.child.firstName}\'s Medical Record'),
        backgroundColor: AppColors.info,
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading health records...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Medical Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 10),
                          _info('Blood Group', profile['blood_group'] ?? 'O+'),
                          _info('Known Allergies', profile['allergies'] ?? 'None known'),
                          _info('Chronic Conditions', profile['chronic_conditions'] ?? 'None'),
                          _info('Height / Weight', '${profile['height_cm'] ?? "-"} cm / ${profile['weight_kg'] ?? "-"} kg'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text('Doctor Medical Checkups', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  if (checkups.isEmpty)
                    const Text('No recent doctor checkup records.', style: TextStyle(color: AppColors.textMuted))
                  else
                    ...checkups.map((c) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.medical_services, color: AppColors.info),
                            title: Text(c['doctor_name'] ?? 'Doctor'),
                            subtitle: Text('Findings: ${c['findings']}\nPrescriptions: ${c['prescriptions']}'),
                          ),
                        )),

                  const SizedBox(height: 16),
                  const Text('Vaccination History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  if (vaccines.isEmpty)
                    const Text('No vaccination entries.', style: TextStyle(color: AppColors.textMuted))
                  else
                    ...vaccines.map((v) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.vaccines, color: AppColors.success),
                            title: Text(v['vaccine_name'] ?? ''),
                            subtitle: Text('Dosage: ${v['dosage']} • Date: ${v['administered_date']}'),
                          ),
                        )),
                ],
              ),
            ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 130, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textMuted))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
