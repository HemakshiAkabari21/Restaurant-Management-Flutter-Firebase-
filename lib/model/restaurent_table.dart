class RestaurantTableModel {
  final String id; // Firebase generated key
  final String tableNo;
  final int capacityPeople;
  final String status;

  RestaurantTableModel({
    required this.id,
    required this.tableNo,
    required this.capacityPeople,
    required this.status,
  });

  /// Convert Firebase map → Model
  factory RestaurantTableModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return RestaurantTableModel(
      id: id,
      tableNo: map['table_no'] ?? '',
      capacityPeople: map['capacity_people'] ?? 0,
      status: map['status'] ?? 'available',
    );
  }

  /// Convert Model → Firebase map
  Map<String, dynamic> toMap() {
    return {
      'table_no': tableNo,
      'capacity_people': capacityPeople,
      'status': status,
    };
  }

  RestaurantTableModel copyWith({
    String? id,
    String? tableNo,
    int? capacityPeople,
    String? status,
  }) {
    return RestaurantTableModel(
      id: id ?? this.id,
      tableNo: tableNo ?? this.tableNo,
      capacityPeople: capacityPeople ?? this.capacityPeople,
      status: status ?? this.status,
    );
  }
}
