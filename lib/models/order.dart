import 'order_item.dart';

class Order {
  final int id;
  final String userId;
  final String status;
  final double total;
  final DateTime createdAt;
  final List<OrderItem> items;
  final String? customerEmail;
  final String? customerName;

  const Order({
    required this.id,
    required this.userId,
    required this.status,
    required this.total,
    required this.createdAt,
    this.items = const [],
    this.customerEmail,
    this.customerName,
  });

  Order copyWith({
    int? id,
    String? userId,
    String? status,
    double? total,
    DateTime? createdAt,
    List<OrderItem>? items,
    String? customerEmail,
    String? customerName,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
      customerEmail: customerEmail ?? this.customerEmail,
      customerName: customerName ?? this.customerName,
    );
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    List<OrderItem> parsedItems = [];
    if (json['order_items'] != null && json['order_items'] is List) {
      parsedItems = (json['order_items'] as List)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    String? email;
    String? name;
    if (json['profiles'] != null && json['profiles'] is Map) {
      email = json['profiles']['email'] as String?;
      final first = json['profiles']['firstname'] ?? '';
      final last = json['profiles']['lastname'] ?? '';
      name = '$first $last'.trim();
      if (name.isEmpty) name = null;
    }

    return Order(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      userId: json['user_id'] as String,
      status: (json['status'] ?? 'completed') as String,
      total: double.tryParse(json['total']?.toString() ?? '') ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      items: parsedItems,
      customerEmail: email,
      customerName: name,
    );
  }
}
