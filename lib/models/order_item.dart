class OrderItem {
  final int id;
  final int orderId;
  final int? productId;
  final double unitPrice;
  final int quantity;
  final DateTime? createdAt;
  final String? productName;
  final String? productImageUrl;

  const OrderItem({
    required this.id,
    required this.orderId,
    this.productId,
    required this.unitPrice,
    required this.quantity,
    this.createdAt,
    this.productName,
    this.productImageUrl,
  });

  double get subtotal => unitPrice * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    String? pName;
    String? pImage;
    if (json['products'] != null && json['products'] is Map) {
      pName = json['products']['name'] as String?;
      pImage = json['products']['image_url'] as String?;
    }

    return OrderItem(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      orderId: json['order_id'] is int ? json['order_id'] as int : int.parse(json['order_id'].toString()),
      productId: json['product_id'] != null
          ? (json['product_id'] is int ? json['product_id'] as int : int.tryParse(json['product_id'].toString()))
          : null,
      unitPrice: double.tryParse(json['unit_price']?.toString() ?? '') ?? 0.0,
      quantity: json['quantity'] is int ? json['quantity'] as int : int.tryParse(json['quantity']?.toString() ?? '') ?? 1,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      productName: pName,
      productImageUrl: pImage,
    );
  }
}
