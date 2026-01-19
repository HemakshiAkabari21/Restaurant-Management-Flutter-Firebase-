class ProductModel {
  final String id;
  final String categoryId;
  final String name;
  final String price;
  final int status;

  ProductModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    required this.status,
  });

  /// Firebase → Model
  factory ProductModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return ProductModel(
      id: id,
      categoryId: map['category_id'] ?? '',
      name: map['name'] ?? '',
      price: map['price'] ?? '0',
      status: map['status'] ?? 1,
    );
  }

  /// Model → Firebase
  Map<String, dynamic> toMap() {
    return {
      'category_id': categoryId,
      'name': name,
      'price': price,
      'status': status,
    };
  }

  ProductModel copyWith({
    String? id,
    String? categoryId,
    String? name,
    String? price,
    int? status,
  }) {
    return ProductModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      price: price ?? this.price,
      status: status ?? this.status,
    );
  }
}
