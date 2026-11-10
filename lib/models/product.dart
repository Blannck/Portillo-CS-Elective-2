class Product {
  final int id;
  final String name;
  final double price;
  final int stock;
  final int? categoryId;
  final String? description;
  final String? imageUrl;
  final DateTime? createdAt;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.stock = 0,
    this.categoryId,
    this.description,
    this.imageUrl,
    this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] as String? ?? 'Unnamed Product',
      price: json['price'] != null ? (json['price'] as num).toDouble() : 0.0,
      stock: json['stock'] is int ? json['stock'] as int : int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      categoryId: json['category_id'] != null ? (json['category_id'] as num).toInt() : null,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson({bool includeId = true}) {
    final data = <String, dynamic>{
      'name': name,
      'price': price,
      'stock': stock,
      'category_id': categoryId,
      'description': description,
      'image_url': imageUrl,
    };
    if (includeId && id > 0) {
      data['id'] = id;
    }
    return data;
  }

  Product copyWith({
    int? id,
    String? name,
    double? price,
    int? stock,
    int? categoryId,
    String? description,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
