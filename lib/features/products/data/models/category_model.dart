class CategoryModel {
  final String id;
  final String name;

  const CategoryModel({
    required this.id,
    required this.name,
  });

  factory CategoryModel.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return CategoryModel(
      id: id,
      name: data['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
    };
  }
}