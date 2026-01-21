class ProductModel {
  final String id;
  final String categoryId;
  final String name;
  final String price;
  final String image;
  final int status;

  ProductModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    required this.image,
    required this.status,
  });

  factory ProductModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return ProductModel(
      id: id,
      categoryId: map['category_id'] ?? '',
      name: map['name'] ?? '',
      price: map['price'] ?? '0',
      image: map['image'] ?? '',
      status: map['status'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() => {
    'category_id': categoryId,
    'name': name,
    'price': price,
    'image': image,
    'status': status,
  };

  ProductModel copyWith({
    String? id,
    String? categoryId,
    String? name,
    String? price,
    String? image,
    int? status,
  }) {
    return ProductModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      price: price ?? this.price,
      image: image ?? this.image,
      status: status ?? this.status,
    );
  }
}
