/// Represents a single product in the store.
///
/// This is an immutable data class — all fields are final.
/// ProductCard widgets that display this never need to mutate it,
/// which is why ProductCard is a StatelessWidget.
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
