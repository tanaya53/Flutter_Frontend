import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../models/inventory_model.dart';
import '../../../services/api_service.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/empty_state.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  List<InventoryItemModel> _items = [];
  Map<String, dynamic> _summary = {};

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.get(ApiConstants.inventory);
      final sumRes = await _api.get(ApiConstants.inventorySummary);
      if (mounted) {
        setState(() {
          _items = (res as List<dynamic>).map((e) => InventoryItemModel.fromJson(e)).toList();
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
        title: Text(tr.translate('inventory')),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadInventory),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading inventory stocks...')
          : RefreshIndicator(
              onRefresh: _loadInventory,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.teal.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Total Asset Types', '${_summary['total_items_count'] ?? 0}', Colors.teal),
                          _buildStatItem(
                            'Low Stock Alerts',
                            '${_summary['low_stock_alerts_count'] ?? 0}',
                            (_summary['low_stock_alerts_count'] ?? 0) > 0 ? AppColors.error : AppColors.success,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Institutional Resources & Stock Levels',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 10),

                    if (_items.isEmpty)
                      const EmptyState(title: 'No Inventory Items Found')
                    else
                      ..._items.map((item) => _buildItemCard(item)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildItemCard(InventoryItemModel item) {
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
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: item.isLowStock ? AppColors.error.withOpacity(0.12) : AppColors.success.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.isLowStock ? 'LOW STOCK' : 'IN STOCK',
                    style: TextStyle(
                      color: item.isLowStock ? AppColors.error : AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Category: ${item.category} • Location: ${item.storageLocation.isEmpty ? "School Store" : item.storageLocation}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildQuantityCol('Total', '${item.totalQuantity} ${item.unit}'),
                _buildQuantityCol('Issued', '${item.allocatedQuantity} ${item.unit}'),
                _buildQuantityCol('Available', '${item.availableQuantity} ${item.unit}', isHighlight: true),
                _buildQuantityCol('Alert Threshold', '${item.lowStockThreshold} ${item.unit}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityCol(String label, String value, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isHighlight ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
