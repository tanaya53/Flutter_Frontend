import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../models/hostel_model.dart';
import '../../../services/api_service.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/empty_state.dart';

class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key});

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  final ApiService _api = ApiService();
  List<MealModel> _meals = [];
  List<FoodStockModel> _stocks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNutritionData();
  }

  Future<void> _loadNutritionData() async {
    setState(() => _isLoading = true);
    try {
      final mealRes = await _api.get(ApiConstants.hostelMeals);
      final stockRes = await _api.get(ApiConstants.foodStocks);

      if (mounted) {
        setState(() {
          _meals = (mealRes as List<dynamic>).map((e) => MealModel.fromJson(e)).toList();
          _stocks = (stockRes as List<dynamic>).map((e) => FoodStockModel.fromJson(e)).toList();
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
        title: const Text('Meals & Nutrition Management'),
        backgroundColor: Colors.brown.shade800,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadNutritionData),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading nutrition & food rations...')
          : RefreshIndicator(
              onRefresh: _loadNutritionData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kitchen Food Inventory Stock
                    const Text(
                      'Mess Ration Stock & Consumption',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 10),
                    if (_stocks.isEmpty)
                      const Text('No kitchen stock items tracked.', style: TextStyle(color: AppColors.textMuted))
                    else
                      ..._stocks.map(
                        (s) => Card(
                          margin: const EdgeInsets.only(bottom: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: s.isLowStock ? AppColors.error.withOpacity(0.12) : AppColors.secondary.withOpacity(0.12),
                              child: Icon(Icons.inventory, color: s.isLowStock ? AppColors.error : AppColors.secondary, size: 20),
                            ),
                            title: Text(s.itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text('Threshold: ${s.lowStockThreshold} ${s.unit}'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: s.isLowStock ? AppColors.error.withOpacity(0.15) : AppColors.success.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${s.quantity} ${s.unit}',
                                style: TextStyle(
                                  color: s.isLowStock ? AppColors.error : AppColors.success,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Daily Meal Log
                    const Text(
                      'Daily Meal Log & Quality Inspection',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 10),

                    if (_meals.isEmpty)
                      const EmptyState(title: 'No Meal Records Logged Today')
                    else
                      ..._meals.map(
                        (m) => Card(
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
                                      m.mealType,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.brown),
                                    ),
                                    Text(
                                      '${m.studentsServed} Students Served',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.secondary),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  m.menuDescription,
                                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Quality Inspection: ${m.qualityStatus} • Date: ${m.date}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
