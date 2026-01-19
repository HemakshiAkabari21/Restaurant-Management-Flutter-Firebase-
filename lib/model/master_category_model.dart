class MasterCategoryModel {
  final String id;
  final String name;

  MasterCategoryModel({required this.id, required this.name});

  factory MasterCategoryModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return MasterCategoryModel(
      id: id,
      name: map['name'],
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
  };
}
