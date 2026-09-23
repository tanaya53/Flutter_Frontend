class BedModel {
  final int id;
  final int roomId;
  final String bedNumber;
  final int? allocatedStudentId;
  final String? studentName;
  final String? studentRoll;
  final bool isOccupied;

  BedModel({
    required this.id,
    required this.roomId,
    required this.bedNumber,
    this.allocatedStudentId,
    this.studentName,
    this.studentRoll,
    required this.isOccupied,
  });

  factory BedModel.fromJson(Map<String, dynamic> json) {
    return BedModel(
      id: json['id'] ?? 0,
      roomId: json['room'] ?? 0,
      bedNumber: json['bed_number'] ?? '',
      allocatedStudentId: json['allocated_student'],
      studentName: json['student_name'],
      studentRoll: json['student_roll'],
      isOccupied: json['is_occupied'] ?? false,
    );
  }
}

class RoomModel {
  final int id;
  final String roomNumber;
  final int floor;
  final int capacity;
  final int occupiedCount;
  final int availableCount;
  final List<BedModel> beds;

  RoomModel({
    required this.id,
    required this.roomNumber,
    required this.floor,
    required this.capacity,
    required this.occupiedCount,
    required this.availableCount,
    required this.beds,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] ?? 0,
      roomNumber: json['room_number'] ?? '',
      floor: json['floor'] ?? 1,
      capacity: json['capacity'] ?? 6,
      occupiedCount: json['occupied_count'] ?? 0,
      availableCount: json['available_count'] ?? 0,
      beds: (json['beds'] as List<dynamic>?)
              ?.map((b) => BedModel.fromJson(b))
              .toList() ??
          [],
    );
  }
}

class HostelModel {
  final int id;
  final String name;
  final String blockType;
  final String? wardenName;
  final int totalCapacity;
  final int totalBeds;
  final int occupiedBeds;
  final List<RoomModel> rooms;

  HostelModel({
    required this.id,
    required this.name,
    required this.blockType,
    this.wardenName,
    required this.totalCapacity,
    required this.totalBeds,
    required this.occupiedBeds,
    required this.rooms,
  });

  factory HostelModel.fromJson(Map<String, dynamic> json) {
    return HostelModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      blockType: json['block_type'] ?? 'BOYS',
      wardenName: json['warden_name'],
      totalCapacity: json['total_capacity'] ?? 0,
      totalBeds: json['total_beds'] ?? 0,
      occupiedBeds: json['occupied_beds'] ?? 0,
      rooms: (json['rooms'] as List<dynamic>?)
              ?.map((r) => RoomModel.fromJson(r))
              .toList() ??
          [],
    );
  }

  int get availableBeds => (totalBeds - occupiedBeds).clamp(0, totalBeds);
  double get occupancyRate =>
      totalBeds > 0 ? (occupiedBeds / totalBeds * 100) : 0.0;
}

class MealModel {
  final int id;
  final String date;
  final String mealType;
  final String menuDescription;
  final int studentsServed;
  final String qualityStatus;

  MealModel({
    required this.id,
    required this.date,
    required this.mealType,
    required this.menuDescription,
    required this.studentsServed,
    required this.qualityStatus,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      mealType: json['meal_type'] ?? 'LUNCH',
      menuDescription: json['menu_description'] ?? '',
      studentsServed: json['students_served'] ?? 0,
      qualityStatus: json['quality_status'] ?? 'Good',
    );
  }
}

class FoodStockModel {
  final int id;
  final String itemName;
  final double quantity;
  final String unit;
  final double lowStockThreshold;
  final bool isLowStock;

  FoodStockModel({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.lowStockThreshold,
    required this.isLowStock,
  });

  factory FoodStockModel.fromJson(Map<String, dynamic> json) {
    return FoodStockModel(
      id: json['id'] ?? 0,
      itemName: json['item_name'] ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] ?? 'kg',
      lowStockThreshold: (json['low_stock_threshold'] as num?)?.toDouble() ?? 10.0,
      isLowStock: json['is_low_stock'] ?? false,
    );
  }
}
