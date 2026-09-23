import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../services/api_service.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/empty_state.dart';

class IncidentsScreen extends StatefulWidget {
  const IncidentsScreen({super.key});

  @override
  State<IncidentsScreen> createState() => _IncidentsScreenState();
}

class _IncidentsScreenState extends State<IncidentsScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _incidents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadIncidents();
  }

  Future<void> _loadIncidents() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.get(ApiConstants.hostelIncidents);
      if (mounted) {
        setState(() {
          _incidents = res as List<dynamic>;
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
        title: const Text('Hostel Incidents & Security Logs'),
        backgroundColor: Colors.brown.shade800,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadIncidents),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading incidents...')
          : _incidents.isEmpty
              ? const EmptyState(
                  title: 'No Hostel Incidents Logged',
                  subtitle: 'Peaceful residential operations. No violations or security breaches reported.',
                  icon: Icons.shield_outlined,
                )
              : RefreshIndicator(
                  onRefresh: _loadIncidents,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _incidents.length,
                    itemBuilder: (context, index) {
                      final item = _incidents[index];
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
                                    item['title'] ?? 'Incident',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      item['incident_type'] ?? 'DISCIPLINARY',
                                      style: const TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item['description'] ?? '',
                                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                              ),
                              if ((item['action_taken'] ?? '').isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  'Action Taken: ${item['action_taken']}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.w600),
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
}
