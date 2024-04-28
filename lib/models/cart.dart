import 'package:farmers_marketplace/models/product.dart';

import '../core/api_handler/endpoints.dart';

class Cart {
  Cart({
    required this.id,
    required this.userId,
    required this.prodId,
    required this.qty,
    required this.name,
    required this.discount,
    required this.unit,
    required this.image,
    required this.price,
    required this.weight,
  });
  final int id;
  final int userId;
  final int prodId;
  final int qty;
  final String name;
  final double discount;
  final String unit;
  final String image;
  final double price;
  final double weight;

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'],
      userId: json['user_id'],
      prodId: json['prod_id'],
      qty: json['qty'],
      name: json['product_name'],
      discount: json['product_discount'].toDouble(),
      unit: json['unit'],
      image: '${ApiEndpoints.productImage}/${json['main_image']}',
      price: json['price'].toDouble(),
      weight: json['product_weight'].toDouble(),
    );
  }

  factory Cart.fromProduct(Product product, int userId) {
    return Cart(
      id: product.id,
      userId: product.userId ?? userId,
      prodId: product.prodId ?? -1,
      qty: product.cartCount,
      name: product.name,
      discount: product.discount,
      unit: product.unit,
      image: product.image,
      price: product.price,
      weight: product.weight,
    );
  }

  // Product toProduct() {
  //   return Product(
  //     id: id,
  //     categoryId: -1,
  //     name: name,
  //     price: price,
  //     discount: discount,
  //     unit: unit,
  //     weight: weight,
  //     image: image,
  //     description: '',
  //     quantity: -1,
  //     isFeatured: '',
  //     rating: -1,
  //     status: -1,
  //     createdAt: DateTime.now(),
  //     updatedAt: DateTime.now(),
  //     userId: userId,
  //     prodId: prodId,
  //     cartCount: -1,
  //   );
  // }

  Cart copyWith({
    int? id,
    int? userId,
    int? prodId,
    int? qty,
    String? name,
    double? discount,
    String? unit,
    String? image,
    double? price,
    double? weight,
  }) {
    return Cart(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      prodId: prodId ?? this.prodId,
      qty: qty ?? this.qty,
      name: name ?? this.name,
      discount: discount ?? this.discount,
      unit: unit ?? this.unit,
      image: image ?? this.image,
      price: price ?? this.price,
      weight: weight ?? this.weight,
    );
  }
}
