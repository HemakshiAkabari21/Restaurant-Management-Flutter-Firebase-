class CategoryModel {
  final String id;
  final String masterId;
  final String name;
  final int status;

  CategoryModel({
    required this.id,
    required this.masterId,
    required this.name,
    required this.status,
  });

  /// Firebase → Model
  factory CategoryModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return CategoryModel(
      id: id,
      masterId: map['master_id'] ?? '',
      name: map['name'] ?? '',
      status: map['status'] ?? 1,
    );
  }

  /// Model → Firebase
  Map<String, dynamic> toMap() {
    return {
      'master_id': masterId,
      'name': name,
      'status': status,
    };
  }

  CategoryModel copyWith({
    String? id,
    String? masterId,
    String? name,
    int? status,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      masterId: masterId ?? this.masterId,
      name: name ?? this.name,
      status: status ?? this.status,
    );
  }
}
