import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../services/api_service.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/empty_state.dart';

class LeaveManagementScreen extends StatefulWidget {
  const LeaveManagementScreen({super.key});

  @override
  State<LeaveManagementScreen> createState() => _LeaveManagementScreenState();
}

class _LeaveManagementScreenState extends State<LeaveManagementScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _leaves = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaves();
  }

  Future<void> _loadLeaves() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.get(ApiConstants.hostelLeaves);
      if (mounted) {
        setState(() {
          _leaves = res as List<dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateLeaveStatus(int id, String status) async {
    try {
      await _api.post(ApiConstants.processLeave(id), {'status': status});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Leave marked as $status'), backgroundColor: AppColors.success),
        );
        _loadLeaves();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating leave: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Leaves & Passes'),
        backgroundColor: Colors.brown.shade800,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadLeaves),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading leave applications...')
          : _leaves.isEmpty
              ? const EmptyState(title: 'No Active Leave Requests')
              : RefreshIndicator(
                  onRefresh: _loadLeaves,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _leaves.length,
                    itemBuilder: (context, index) {
                      final item = _leaves[index];
                      final status = item['status'];

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
                                  Text(
                                    item['student_name'] ?? 'Student',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(status).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        color: _getStatusColor(status),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Duration: ${item['start_date']} to ${item['end_date']}',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Text('Reason: ${item['reason']}', style: const TextStyle(fontSize: 13)),
                              if ((item['escort_name'] ?? '').isNotEmpty)
                                Text('Escort: ${item['escort_name']} (${item['escort_contact']})', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                              const SizedBox(height: 10),

                              if (status == 'PENDING')
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () => _updateLeaveStatus(item['id'], 'REJECTED'),
                                      child: const Text('Reject'),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () => _updateLeaveStatus(item['id'], 'APPROVED'),
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                                      child: const Text('Approve Leave'),
                                    ),
                                  ],
                                ),
                              if (status == 'APPROVED')
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _updateLeaveStatus(item['id'], 'RETURNED'),
                                    icon: const Icon(Icons.check, size: 16),
                                    label: const Text('Mark Student Returned'),
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                                  ),
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

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'APPROVED':
        return AppColors.success;
      case 'REJECTED':
        return AppColors.error;
      case 'RETURNED':
        return AppColors.primary;
      default:
        return AppColors.warning;
    }
  }
}
