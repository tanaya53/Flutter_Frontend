import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../models/hostel_model.dart';
import '../../../services/api_service.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/empty_state.dart';

class HostelOverviewScreen extends StatefulWidget {
  const HostelOverviewScreen({super.key});

  @override
  State<HostelOverviewScreen> createState() => _HostelOverviewScreenState();
}

class _HostelOverviewScreenState extends State<HostelOverviewScreen> {
  final ApiService _api = ApiService();
  List<HostelModel> _hostels = [];
  bool _isLoading = true;
  Map<String, dynamic> _summary = {};

  @override
  void initState() {
    super.initState();
    _loadHostelData();
  }

  Future<void> _loadHostelData() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.get(ApiConstants.hostels);
      final sumRes = await _api.get(ApiConstants.hostelSummary);
      if (mounted) {
        setState(() {
          _hostels = (res as List<dynamic>).map((e) => HostelModel.fromJson(e)).toList();
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
        title: Text(tr.translate('hostel')),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadHostelData),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading hostel occupancy...')
          : RefreshIndicator(
              onRefresh: _loadHostelData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.brown.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.brown.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem('Total Beds', '${_summary['total_beds'] ?? 0}', Colors.brown),
                              _buildStatItem('Occupied', '${_summary['occupied_beds'] ?? 0}', AppColors.primary),
                              _buildStatItem('Available', '${_summary['available_beds'] ?? 0}', AppColors.success),
                              _buildStatItem('Occupancy', '${_summary['occupancy_percentage'] ?? 0}%', AppColors.warning),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: ((_summary['occupancy_percentage'] ?? 0) / 100).clamp(0.0, 1.0),
                            backgroundColor: Colors.brown.shade100,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.brown),
                            minHeight: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Hostel Blocks & Dormitories',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 10),

                    if (_hostels.isEmpty)
                      const EmptyState(title: 'No Hostel Blocks Found')
                    else
                      ..._hostels.map((h) => _buildHostelCard(h)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildHostelCard(HostelModel hostel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: CircleAvatar(
          backgroundColor: hostel.blockType == 'BOYS' ? Colors.blue.shade100 : Colors.pink.shade100,
          child: Icon(
            hostel.blockType == 'BOYS' ? Icons.male : Icons.female,
            color: hostel.blockType == 'BOYS' ? Colors.blue.shade800 : Colors.pink.shade800,
          ),
        ),
        title: Text(
          hostel.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          'Warden: ${hostel.wardenName ?? "Assigned"} • Occupancy: ${hostel.occupiedBeds}/${hostel.totalBeds} Beds',
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dormitory Rooms & Bed Allocations:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                if (hostel.rooms.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('No rooms configured in this block.', style: TextStyle(color: AppColors.textMuted)),
                  )
                else
                  ...hostel.rooms.map((room) => _buildRoomTile(room)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomTile(RoomModel room) {
    final isFull = room.availableCount == 0;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Room ${room.roomNumber} (Floor ${room.floor})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isFull ? AppColors.error.withOpacity(0.12) : AppColors.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isFull ? 'FULL' : '${room.availableCount} Available',
                  style: TextStyle(
                    color: isFull ? AppColors.error : AppColors.success,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: room.beds.map((bed) {
              final occupied = bed.isOccupied;
              return Chip(
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                backgroundColor: occupied ? AppColors.primary.withOpacity(0.12) : Colors.grey.shade200,
                side: BorderSide(color: occupied ? AppColors.primary : Colors.grey.shade300),
                label: Text(
                  occupied ? '${bed.bedNumber}: ${bed.studentName ?? "Student"}' : '${bed.bedNumber}: Vacant',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: occupied ? FontWeight.w600 : FontWeight.normal,
                    color: occupied ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
