import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final String? productName;
  final int? categoryId;
  final BoxFit fit;
  final double? width;
  final double? height;

  const ProductImage({
    super.key,
    this.imageUrl,
    this.productName,
    this.categoryId,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  /// Intelligently resolves the right pickleball asset based on product name or category
  String getAppropriateAsset() {
    final nameLower = (productName ?? '').toLowerCase();

    // Check distinctive product types first so names containing "Pro" or
    // "Carbon" are not mistaken for the wrong category.
    if (nameLower.contains('shoe') || nameLower.contains('footwear')) {
      return 'assets/images/court_shoes.png';
    }
    if (nameLower.contains('ball') ||
        nameLower.contains('x-40') ||
        nameLower.contains('dura')) {
      return 'assets/images/pickleballs.png';
    }
    if (nameLower.contains('bag') ||
        nameLower.contains('backpack') ||
        nameLower.contains('duffle')) {
      return 'assets/images/backpack.png';
    }
    if (nameLower.contains('net') || nameLower.contains('court equipment')) {
      return 'assets/images/court_net.png';
    }
    if (nameLower.contains('pro') ||
        nameLower.contains('joola') ||
        nameLower.contains('crbn') ||
        nameLower.contains('franklin')) {
      return 'assets/images/paddle_pro.png';
    }
    if (nameLower.contains('paddle') ||
        nameLower.contains('vanguard') ||
        nameLower.contains('carbon') ||
        nameLower.contains('selkirk')) {
      return 'assets/images/paddle_carbon.png';
    }

    // Check by category ID
    switch (categoryId) {
      case 1: // Paddles
        return 'assets/images/paddle_carbon.png';
      case 2: // Shoes
        return 'assets/images/court_shoes.png';
      case 3: // Pickleballs
        return 'assets/images/pickleballs.png';
      case 4: // Bags & Backpacks
        return 'assets/images/backpack.png';
      case 5: // Apparel & Accessories
        return 'assets/images/paddle_pro.png';
      case 6: // Court Equipment
        return 'assets/images/court_net.png';
      default:
        return 'assets/images/paddle_carbon.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final fallbackAsset = getAppropriateAsset();
    final url = (imageUrl ?? '').trim();

    // 1. Direct local asset specified
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => _buildFallback(fallbackAsset),
      );
    }

    // 2. HTTP / HTTPS Network image with automatic fallback
    if (url.startsWith('http://') || url.startsWith('https://')) {
      // Legacy seeded Unsplash links did not reliably match the product.
      // Use the local, category-correct asset instead of those mismatched URLs.
      if (url.contains('images.unsplash.com')) {
        return _buildFallback(fallbackAsset);
      }

      return Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (ctx, child, progress) {
          if (progress == null) return child;
          return Container(
            width: width,
            height: height,
            color: Colors.grey.shade100,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
        errorBuilder: (_, _, _) => _buildFallback(fallbackAsset),
      );
    }

    // 3. Empty or null URL -> render appropriate pickleball asset immediately
    return _buildFallback(fallbackAsset);
  }

  Widget _buildFallback(String assetPath) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => Container(
        width: width,
        height: height,
        color: Colors.grey.shade100,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sports_tennis, size: 36, color: AppColors.primary),
              SizedBox(height: 4),
              Text(
                'PicklePro',
                style: TextStyle(
                  color: AppColors.slateMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
