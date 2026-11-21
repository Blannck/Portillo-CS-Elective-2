class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final String? imageUrl;
  final int? categoryId;
  final DateTime? createdAt;

  const Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    this.imageUrl,
    this.categoryId,
    this.createdAt,
  });

  bool get isOutOfStock => stock <= 0;
  bool get isLowStock => stock > 0 && stock <= 5;

  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? imageUrl,
    int? categoryId,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      name: (json['name'] ?? '') as String,
      description: json['description'] as String?,
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      stock: json['stock'] is int ? json['stock'] as int : int.tryParse(json['stock']?.toString() ?? '') ?? 0,
      imageUrl: json['image_url'] as String?,
      categoryId: json['category_id'] != null
          ? (json['category_id'] is int ? json['category_id'] as int : int.tryParse(json['category_id'].toString()))
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson({bool includeId = true}) {
    final data = <String, dynamic>{
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'image_url': imageUrl,
      'category_id': categoryId,
    };
    if (includeId && id != 0) {
      data['id'] = id;
    }
    return data;
  }
}
