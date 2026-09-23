import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../models/hostel_model.dart';
import '../../../services/api_service.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/empty_state.dart';

class HostelRoomsScreen extends StatefulWidget {
  const HostelRoomsScreen({super.key});

  @override
  State<HostelRoomsScreen> createState() => _HostelRoomsScreenState();
}

class _HostelRoomsScreenState extends State<HostelRoomsScreen> {
  final ApiService _api = ApiService();
  List<HostelModel> _hostels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHostels();
  }

  Future<void> _loadHostels() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.get(ApiConstants.hostels);
      if (mounted) {
        setState(() {
          _hostels = (res as List<dynamic>).map((e) => HostelModel.fromJson(e)).toList();
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
        title: const Text('Hostel Rooms & Bed Allocations'),
        backgroundColor: Colors.brown.shade800,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadHostels),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading hostel rooms...')
          : _hostels.isEmpty
              ? const EmptyState(title: 'No Hostel Blocks Configured')
              : RefreshIndicator(
                  onRefresh: _loadHostels,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: _hostels.length,
                    itemBuilder: (context, index) {
                      final h = _hostels[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    h.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.brown.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${h.occupiedBeds}/${h.totalBeds} BEDS',
                                      style: TextStyle(
                                        color: Colors.brown.shade900,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ...h.rooms.map((r) => _buildRoomDetails(r)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildRoomDetails(RoomModel room) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Room ${room.roomNumber} (Capacity: ${room.capacity})',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              Text(
                '${room.availableCount} Vacant',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: room.availableCount > 0 ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: room.beds.map((b) {
              return Chip(
                avatar: Icon(
                  b.isOccupied ? Icons.person : Icons.hotel,
                  size: 16,
                  color: b.isOccupied ? Colors.white : Colors.black54,
                ),
                backgroundColor: b.isOccupied ? AppColors.primary : Colors.grey.shade200,
                label: Text(
                  b.isOccupied ? '${b.bedNumber}: ${b.studentName}' : '${b.bedNumber}: Empty',
                  style: TextStyle(
                    color: b.isOccupied ? Colors.white : Colors.black87,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
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
