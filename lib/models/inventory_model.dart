class InventoryItemModel {
  final int id;
  final String name;
  final String category;
  final int totalQuantity;
  final int allocatedQuantity;
  final int availableQuantity;
  final String unit;
  final int lowStockThreshold;
  final bool isLowStock;
  final String storageLocation;

  InventoryItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.totalQuantity,
    required this.allocatedQuantity,
    required this.availableQuantity,
    required this.unit,
    required this.lowStockThreshold,
    required this.isLowStock,
    required this.storageLocation,
  });

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    return InventoryItemModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? 'GENERAL',
      totalQuantity: json['total_quantity'] ?? 0,
      allocatedQuantity: json['allocated_quantity'] ?? 0,
      availableQuantity: json['available_quantity'] ?? 0,
      unit: json['unit'] ?? 'Units',
      lowStockThreshold: json['low_stock_threshold'] ?? 10,
      isLowStock: json['is_low_stock'] ?? false,
      storageLocation: json['storage_location'] ?? '',
    );
  }
}
