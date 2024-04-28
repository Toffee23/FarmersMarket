import '../core/api_handler/endpoints.dart';

class Order {
  Order({
    required this.id,
    required this.userId,
    required this.prodId,
    required this.qty,
    required this.orderId,
    required this.orderStatus,
    required this.trackOrder,
    required this.isRated,
    required this.createdAt,
    required this.productName,
    required this.price,
    required this.imageUrl,
  });
  final int id; // "id": 83,
  final int userId; // "user_id": 16,
  final int prodId; // "prod_id": 1,
  final int qty; // "qty": 1,
  final String orderId; // "order_id": "379490",
  final String orderStatus; // "order_status": "completed",
  final int trackOrder; // "track_order": 4,
  final bool isRated; // "is_rated": 1,
  final DateTime createdAt; // "created_at": "2024-02-21 15:35:09",
  final String productName; // "product_name": "Groundnut (75cl, 1 Bottle)",
  final double price; // "price": 1900,
  final String imageUrl; // "main_image": "groundnut-bottle.jpg-864.jpg"

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['user_id'],
      prodId: json['prod_id'],
      qty: json['qty'],
      orderId: json['order_id'],
      orderStatus: json['order_status'],
      trackOrder: json['track_order'],
      isRated: json['is_rated'] == 0 ? false : true,
      createdAt: DateTime.parse(json['created_at']),
      productName: json['product_name'],
      price: json['price'].toDouble(),
      imageUrl: '${ApiEndpoints.productImage}/${json['main_image']}',
    );
  }
}
