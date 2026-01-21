import 'package:restaurant_management_fierbase/model/category_model.dart';

class MasterCategoryModel {
  final String id;
  final String name;
  final String image;
  final List<String> categoryIds; // NEW: list of category IDs under this master
  final List<CategoryModel> categories; // optional: cached list of category objects

  MasterCategoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.categoryIds,
    required this.categories,
  });

  factory MasterCategoryModel.fromMap(String id, Map<dynamic, dynamic> map) {
    final catIds = map['category_ids'] != null
        ? List<String>.from(map['category_ids'])
        : <String>[];

    return MasterCategoryModel(
      id: id,
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      categoryIds: catIds,
      categories: map['categories'] != null
          ? (map['categories'] as List)
          .map((e) => CategoryModel.fromMap(e['id'], e))
          .toList()
          : [],
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'image': image,
    'category_ids': categoryIds,
    'categories': categories.map((c) => c.toMap()).toList(),
  };

  MasterCategoryModel copyWith({
    String? id,
    String? name,
    String? image,
    List<String>? categoryIds,
    List<CategoryModel>? categories,
  }) {
    return MasterCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      categoryIds: categoryIds ?? this.categoryIds,
      categories: categories ?? this.categories,
    );
  }
}
