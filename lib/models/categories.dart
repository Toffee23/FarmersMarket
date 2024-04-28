import '../core/api_handler/endpoints.dart';

class Category {
  Category({
    required this.id,
    required this.name,
    required this.image,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String name;
  final String image;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      image: '${ApiEndpoints.categoryImage}/${json['category_image']}',
      status: json['status'],
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? ''),
    );
  }
}
