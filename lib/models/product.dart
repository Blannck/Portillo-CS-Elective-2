/// Immutable model representing an e-commerce product in the store catalog.
class Product {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final double price;
  final double rating;
  final int reviewCount;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.price,
    required this.rating,
    required this.reviewCount,
  });
}

