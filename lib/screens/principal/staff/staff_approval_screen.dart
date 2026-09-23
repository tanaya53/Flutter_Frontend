import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../services/api_service.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/empty_state.dart';

class StaffApprovalScreen extends StatefulWidget {
  const StaffApprovalScreen({super.key});

  @override
  State<StaffApprovalScreen> createState() => _StaffApprovalScreenState();
}

class _StaffApprovalScreenState extends State<StaffApprovalScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.get(ApiConstants.joinRequests);
      if (mounted) {
        setState(() {
          _requests = res as List<dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _processRequest(int id, String action) async {
    try {
      await _api.post(ApiConstants.approveUser(id), {'action': action});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(action == 'APPROVE' ? 'User approved successfully!' : 'User request rejected.'),
            backgroundColor: action == 'APPROVE' ? AppColors.success : AppColors.error,
          ),
        );
        _loadRequests();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff & User Approvals'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadRequests),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading pending requests...')
          : _requests.isEmpty
              ? const EmptyState(
                  title: 'No Pending Join Requests',
                  subtitle: 'All staff and parent registration requests have been processed.',
                  icon: Icons.check_circle_outline,
                )
              : RefreshIndicator(
                  onRefresh: _loadRequests,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      final item = _requests[index];
                      final isPending = item['status'] == 'PENDING';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors.primary.withOpacity(0.12),
                                    child: Icon(
                                      _getRoleIcon(item['requested_role']),
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['applicant_name'] ?? item['applicant_username'] ?? '',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        Text(
                                          'Role: ${item['requested_role'].toString().toUpperCase()} • User: ${item['applicant_username']}',
                                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(item['status']).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      item['status'] ?? '',
                                      style: TextStyle(
                                        color: _getStatusColor(item['status']),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text('Mobile: ${item['applicant_phone'] ?? "N/A"}'),
                              if ((item['applicant_email'] ?? '').isNotEmpty)
                                Text('Email: ${item['applicant_email']}'),
                              const SizedBox(height: 12),

                              if (isPending) ...[
                                const Divider(color: AppColors.border),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () => _processRequest(item['id'], 'REJECT'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.error,
                                        side: const BorderSide(color: AppColors.error),
                                      ),
                                      child: Text(tr.translate('reject')),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton(
                                      onPressed: () => _processRequest(item['id'], 'APPROVE'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.success,
                                      ),
                                      child: Text(tr.translate('approve')),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  IconData _getRoleIcon(String? role) {
    switch (role) {
      case 'teacher':
        return Icons.cast_for_education;
      case 'warden':
        return Icons.night_shelter_outlined;
      case 'parent':
        return Icons.family_restroom;
      default:
        return Icons.person;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'APPROVED':
        return AppColors.success;
      case 'REJECTED':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }
}
