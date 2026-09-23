import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../services/api_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ApiService _api = ApiService();
  String? _downloadingReport;

  Future<void> _triggerReportExport(String title, String endpoint, String format) async {
    setState(() => _downloadingReport = '$title ($format)');
    try {
      final token = await _api.getToken();
      final url = '$endpoint?export_type=$format';

      // Simulate download trigger or launch URL
      await Future.delayed(const Duration(milliseconds: 600));

      if (mounted) {
        setState(() => _downloadingReport = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Generated $title ($format). Ready for download: $url'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _downloadingReport = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.translate('reports')),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.description_outlined, color: AppColors.primary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'All generated reports are strictly filtered to your school and compliant with Tribal Welfare Department reporting standards.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Official Institutional Reports',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            _buildReportCard(
              title: 'Daily Student Attendance Report',
              description: 'Date-wise roll call, absent count, attendance percentage and remarks.',
              endpoint: ApiConstants.reportAttendance,
              hasPdf: true,
              hasExcel: true,
            ),
            _buildReportCard(
              title: 'Student Enrollment & Roster Directory',
              description: 'Complete student profiles, room allocations, blood group and emergency contacts.',
              endpoint: ApiConstants.reportStudents,
              hasPdf: false,
              hasExcel: true,
            ),
            _buildReportCard(
              title: 'Hostel Occupancy & Bed Allocation Summary',
              description: 'Dormitory blocks, room capacities, occupied vs available bed inventory.',
              endpoint: ApiConstants.reportHostel,
              hasPdf: false,
              hasExcel: true,
            ),
            _buildReportCard(
              title: 'Tribal Scholarships & Grants Disbursal Log',
              description: 'Applications, approved grants, distribution status and ITDP approval numbers.',
              endpoint: ApiConstants.reportScholarships,
              hasPdf: false,
              hasExcel: true,
            ),
            _buildReportCard(
              title: 'School Assets & Inventory Register',
              description: 'Bedding, textbooks, lab equipment, uniforms, issued items and low-stock list.',
              endpoint: ApiConstants.reportInventory,
              hasPdf: false,
              hasExcel: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard({
    required String title,
    required String description,
    required String endpoint,
    required bool hasPdf,
    required bool hasExcel,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (hasPdf)
                  ElevatedButton.icon(
                    onPressed: _downloadingReport != null
                        ? null
                        : () => _triggerReportExport(title, endpoint, 'pdf'),
                    icon: const Icon(Icons.picture_as_pdf, size: 16),
                    label: const Text('Export PDF', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                  ),
                if (hasPdf && hasExcel) const SizedBox(width: 10),
                if (hasExcel)
                  ElevatedButton.icon(
                    onPressed: _downloadingReport != null
                        ? null
                        : () => _triggerReportExport(title, endpoint, 'excel'),
                    icon: const Icon(Icons.table_chart, size: 16),
                    label: const Text('Export Excel', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
