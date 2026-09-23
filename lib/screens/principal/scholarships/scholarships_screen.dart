import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../models/scholarship_model.dart';
import '../../../services/api_service.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/empty_state.dart';

class ScholarshipsScreen extends StatefulWidget {
  const ScholarshipsScreen({super.key});

  @override
  State<ScholarshipsScreen> createState() => _ScholarshipsScreenState();
}

class _ScholarshipsScreenState extends State<ScholarshipsScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  List<ScholarshipModel> _scholarships = [];
  List<WelfareSchemeModel> _schemes = [];
  Map<String, dynamic> _summary = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final scRes = await _api.get(ApiConstants.scholarships);
      final schRes = await _api.get(ApiConstants.welfareSchemes);
      final sumRes = await _api.get(ApiConstants.scholarshipSummary);

      if (mounted) {
        setState(() {
          _scholarships = (scRes as List<dynamic>).map((e) => ScholarshipModel.fromJson(e)).toList();
          _schemes = (schRes as List<dynamic>).map((e) => WelfareSchemeModel.fromJson(e)).toList();
          _summary = sumRes as Map<String, dynamic>;
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
        title: Text(tr.translate('scholarships')),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading scholarships & welfare schemes...')
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.deepPurple.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Applications', '${_summary['total_scholarship_applications'] ?? 0}', Colors.deepPurple),
                          _buildStatItem('Approved', '${_summary['approved_count'] ?? 0}', AppColors.success),
                          _buildStatItem('Pending', '${_summary['pending_review_count'] ?? 0}', AppColors.warning),
                          _buildStatItem('Active Schemes', '${_summary['active_welfare_schemes'] ?? 0}', AppColors.primary),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Welfare Schemes (Uniforms, Books, etc.)
                    const Text(
                      'Welfare Schemes & Direct Benefit Distribution',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 10),
                    ..._schemes.map((sch) => _buildSchemeCard(sch)),
                    const SizedBox(height: 20),

                    // Individual Student Scholarships
                    const Text(
                      'Student Scholarship Applications',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 10),
                    if (_scholarships.isEmpty)
                      const EmptyState(title: 'No Scholarships Recorded')
                    else
                      ..._scholarships.map((s) => _buildScholarshipCard(s)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildSchemeCard(WelfareSchemeModel sch) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    sch.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    sch.status,
                    style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Target: ${sch.targetClass} • Distributed: ${sch.totalDistributed}/${sch.totalEligible}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (sch.completionPercentage / 100).clamp(0.0, 1.0),
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
              minHeight: 6,
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${sch.completionPercentage}% Distributed',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScholarshipCard(ScholarshipModel s) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(s.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(
          '${s.schemeName}\nClass: ${s.studentClass} • Amount: ₹${s.amount.toStringAsFixed(0)}',
          style: const TextStyle(fontSize: 12),
        ),
        isThreeLine: true,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: s.status == 'APPROVED' ? AppColors.success.withOpacity(0.15) : AppColors.warning.withOpacity(0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            s.status,
            style: TextStyle(
              color: s.status == 'APPROVED' ? AppColors.success : AppColors.warning,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}
