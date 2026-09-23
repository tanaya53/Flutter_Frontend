import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../services/api_service.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/empty_state.dart';

class AcademicRemarksScreen extends StatefulWidget {
  const AcademicRemarksScreen({super.key});

  @override
  State<AcademicRemarksScreen> createState() => _AcademicRemarksScreenState();
}

class _AcademicRemarksScreenState extends State<AcademicRemarksScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _remarks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRemarks();
  }

  Future<void> _loadRemarks() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.get(ApiConstants.remarks);
      if (mounted) {
        setState(() {
          _remarks = res as List<dynamic>;
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
        title: const Text('Academic Remarks & Observations'),
        backgroundColor: AppColors.secondary,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadRemarks),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading academic remarks...')
          : _remarks.isEmpty
              ? const EmptyState(
                  title: 'No Academic Remarks Yet',
                  subtitle: 'Academic remarks added by mentors will appear here.',
                )
              : RefreshIndicator(
                  onRefresh: _loadRemarks,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _remarks.length,
                    itemBuilder: (context, index) {
                      final item = _remarks[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item['student_name'] ?? 'Student',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      item['performance'] ?? 'GOOD',
                                      style: const TextStyle(
                                        color: AppColors.secondary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Subject: ${item['subject']} • ${item['term']} • Teacher: ${item['teacher_name']}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['remark'] ?? '',
                                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
