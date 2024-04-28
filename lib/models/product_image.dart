import '../core/api_handler/endpoints.dart';

class ProductImage {
  ProductImage({
    required this.id,
    required this.productId,
    required this.image,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  final int id;
  final int productId;
  final String image;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'],
      productId: json['product_id'],
      image: '${ApiEndpoints.productImage}/${json['image']}',
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
