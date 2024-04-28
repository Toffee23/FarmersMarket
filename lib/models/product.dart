import 'package:farmers_marketplace/core/api_handler/endpoints.dart';

class Product {
  Product({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    required this.discount,
    required this.unit,
    required this.weight,
    required this.image,
    required this.description,
    required this.quantity,
    required this.isFeatured,
    required this.rating,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.prodId,
    required this.cartCount,
  });

  final int id;
  final int categoryId;
  final String name;
  final double price;
  final double discount;
  final String unit;
  final double weight;
  final String image;
  final String description;
  final int quantity;
  final String isFeatured;
  final int rating;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? userId;
  final int? prodId;
  final int cartCount;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      categoryId: json['category_id'],
      name: json['product_name'],
      price: json['price'].toDouble(),
      discount: json['product_discount'].toDouble(),
      unit: json['unit'],
      weight: json['product_weight'].toDouble(),
      image: '${ApiEndpoints.productImage}/${json['main_image']}',
      description: json['description'],
      quantity: json['quantity'],
      isFeatured: json['is_featured'],
      rating: json['rating'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      userId: json['user_id'],
      prodId: json['prod_id'],
      cartCount: json['qty'] ?? 0,
    );
  }

  Product copyWith({int? cartCount}) {
    return Product(
      id: id,
      categoryId: categoryId,
      name: name,
      price: price,
      discount: discount,
      unit: unit,
      weight: weight,
      image: image,
      description: description,
      quantity: quantity,
      isFeatured: isFeatured,
      rating: rating,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      userId: userId,
      prodId: prodId,
      cartCount: cartCount ?? this.cartCount,
    );
  }
}
