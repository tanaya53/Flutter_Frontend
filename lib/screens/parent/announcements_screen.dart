import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../models/announcement_model.dart';
import '../../../services/api_service.dart';
import '../../../widgets/alert_card.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/empty_state.dart';

class ParentAnnouncementsScreen extends StatefulWidget {
  const ParentAnnouncementsScreen({super.key});

  @override
  State<ParentAnnouncementsScreen> createState() => _ParentAnnouncementsScreenState();
}

class _ParentAnnouncementsScreenState extends State<ParentAnnouncementsScreen> {
  final ApiService _api = ApiService();
  List<AnnouncementModel> _announcements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.get(ApiConstants.announcements);
      if (mounted) {
        setState(() {
          _announcements = (res as List<dynamic>).map((e) => AnnouncementModel.fromJson(e)).toList();
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
        title: const Text('School Notices & Alerts'),
        backgroundColor: AppColors.info,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAnnouncements),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading school announcements...')
          : _announcements.isEmpty
              ? const EmptyState(
                  title: 'No Active Notices',
                  subtitle: 'Official announcements from the Principal will appear here.',
                  icon: Icons.notifications_off_outlined,
                )
              : RefreshIndicator(
                  onRefresh: _loadAnnouncements,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: _announcements.length,
                    itemBuilder: (context, index) {
                      final item = _announcements[index];
                      if (item.isEmergency) {
                        return AlertCard(
                          title: item.title,
                          description: item.message,
                          severity: 'CRITICAL',
                        );
                      }

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
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                  ),
                                  Text(
                                    item.createdAt.split('T').first,
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.message,
                                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.3),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Issued by: ${item.createdByName ?? "Principal Office"}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
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
