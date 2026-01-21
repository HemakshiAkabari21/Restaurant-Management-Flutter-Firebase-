import 'package:restaurant_management_fierbase/model/product_model.dart';

class CategoryModel {
  final String id;
  final String masterId;
  final String name;
  final String image;
  final int status;
  final List<String> productIds;
  final List<ProductModel> products;

  CategoryModel({
    required this.id,
    required this.masterId,
    required this.name,
    required this.image,
    required this.status,
    required this.productIds,
    required this.products,
  });

  /// Firebase → Model
  factory CategoryModel.fromMap(String id, Map<dynamic, dynamic> map) {
    final prodIds = map['product_ids'] != null
        ? List<String>.from(map['product_ids'])
        : <String>[];
    return CategoryModel(
      id: id,
      masterId: map['master_id'] ?? '',
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      status: map['status'] ?? 1,
      productIds: prodIds,
      products: map['products'] != null
          ? (map['products'] as List)
          .map((e) => ProductModel.fromMap(e['id'], e))
          .toList()
          : [],

    );
  }

  /// Model → Firebase
  Map<String, dynamic> toMap() {
    return {
      'master_id': masterId,
      'name': name,
      'status': status,
      'image': image,
      'product_ids': productIds,
      'products': products.map((p) => p.toMap()).toList(),
    };
  }

  CategoryModel copyWith({
    String? id,
    String? masterId,
    String? name,
    int? status,
    String? image,
    List<String>? productIds,
    List<ProductModel>? products,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      masterId: masterId ?? this.masterId,
      name: name ?? this.name,
      status: status ?? this.status,
      image: image ?? this.image,
      productIds: productIds ?? this.productIds,
      products: products ?? this.products,
    );
  }
}

