import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://bbvnzsbshhnyjiclylat.supabase.co';
  static const String supabasePublishableKey =
      'sb_publishable_skNu3pLy46vry9vCWHiJuw_c_8To_eb';

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabasePublishableKey,
    );
  }

  Future<({List<Product> products, int totalCount})> fetchProducts({
    required double minPrice,
    required double maxPrice,
    required int page,
    required int pageSize,
    String? searchQuery,
    String sortBy = 'id',
    bool ascending = true,
  }) async {
    final from = (page - 1) * pageSize;
    final to = from + pageSize - 1;

    var query = client.from('products').select();

    query = query.gte('price', minPrice).lte('price', maxPrice);

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      query = query.ilike('name', '%${searchQuery.trim()}%');
    }

    final response = await query
        .order(sortBy, ascending: ascending)
        .range(from, to);

    final productList = (response as List)
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();

    int count = 0;
    try {
      var countQuery = client.from('products').count(CountOption.exact);
      countQuery = countQuery.gte('price', minPrice).lte('price', maxPrice);
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        countQuery = countQuery.ilike('name', '%${searchQuery.trim()}%');
      }
      count = await countQuery;
    } catch (_) {
      count = from + productList.length;
    }

    return (products: productList, totalCount: count);
  }

  Future<Product> updateProduct(int id, Map<String, dynamic> updates) async {
    final response = await client
        .from('products')
        .update(updates)
        .eq('id', id)
        .select()
        .single();

    return Product.fromJson(response);
  }

  Future<void> deleteProduct(int id) async {
    await client.from('products').delete().eq('id', id).select();
  }

  Future<Product> insertProduct(Map<String, dynamic> productData) async {
    final response = await client
        .from('products')
        .insert(productData)
        .select()
        .single();

    return Product.fromJson(response);
  }

  Future<void> seedInitialProducts() async {
    final sampleProducts = [
      {
        'name': 'Nike Air Zoom Pegasus',
        'price': 130.00,
        'stock': 15,
        'category_id': 1,
        'description': 'Responsive cushioning for everyday road running.',
        'image_url':
            'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
      },
      {
        'name': 'Adidas Ultraboost Light',
        'price': 190.00,
        'stock': 8,
        'category_id': 1,
        'description': 'Experience epic energy return with lightweight Boost.',
        'image_url': 'https://images.unsplash.com/photo-1587563871167-1ee9c731aefb?w=400',
      },
      {
        'name': 'Classic Canvas Slip-On',
        'price': 45.00,
        'stock': 25,
        'category_id': 1,
        'description': 'Low profile canvas slip-ons for everyday wear.',
        'image_url': 'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?w=400',
      },
      {
        'name': 'Handcrafted Leather Oxford',
        'price': 220.00,
        'stock': 5,
        'category_id': 2,
        'description': 'Full-grain Italian calfskin formal dress shoes.',
        'image_url': 'https://images.unsplash.com/photo-1614252369475-531eba835eb1?w=400',
      },
      {
        'name': 'Trail Master Waterproof Boot',
        'price': 165.00,
        'stock': 12,
        'category_id': 3,
        'description': 'Engineered for grip and ankle support on rocky trails.',
        'image_url': 'https://images.unsplash.com/photo-1520639888713-7851133b1ed0?w=400',
      },
      {
        'name': 'Minimalist Urban Sneaker',
        'price': 85.00,
        'stock': 18,
        'category_id': 1,
        'description': 'Clean Scandinavian design with memory foam insole.',
        'image_url': 'https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=400',
      },
      {
        'name': 'Retro Suede Court Shoe',
        'price': 75.00,
        'stock': 20,
        'category_id': 1,
        'description':
            'Vintage silhouette with soft suede upper and rubber outsole.',
        'image_url': 'https://images.unsplash.com/photo-1575537302964-96cd47c06b1b?w=400',
      },
      {
        'name': 'Air Max Retro High',
        'price': 175.00,
        'stock': 10,
        'category_id': 1,
        'description':
            'Iconic street style with visible air pocket cushioning.',
        'image_url':
            'https://images.unsplash.com/photo-1552346154-21d32810aba3?w=400',
      },
      {
        'name': 'Suede Loafers Casual',
        'price': 95.00,
        'stock': 14,
        'category_id': 2,
        'description': 'Refined casual comfort for smart casual occasions.',
        'image_url': 'https://images.unsplash.com/photo-1582588678413-dbf45f4823e9?w=400',
      },
      {
        'name': 'Alpine Winter Thermal Boot',
        'price': 240.00,
        'stock': 6,
        'category_id': 3,
        'description': 'Sub-zero insulation with waterproof storm guard.',
        'image_url':
            'https://images.unsplash.com/photo-1544441893-675973e31985?w=400',
      },
      {
        'name': 'Street Pro Skate Shoes',
        'price': 60.00,
        'stock': 30,
        'category_id': 1,
        'description': 'Reinforced toe cap with ultra-durable gum sole.',
        'image_url':
            'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=400',
      },
      {
        'name': 'Lightweight Mesh Walker',
        'price': 35.00,
        'stock': 40,
        'category_id': 1,
        'description': 'Maximum breathability for long walking sessions.',
        'image_url': 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=400',
      },
      {
        'name': 'Outdoor Adventure Sandal',
        'price': 50.00,
        'stock': 22,
        'category_id': 4,
        'description': 'Quick-drying straps with arch support for river hikes.',
        'image_url': 'https://images.unsplash.com/photo-1603808033192-082d6919d3e1?w=400',
      },
      {
        'name': 'Chelsea Boot Dark Espresso',
        'price': 185.00,
        'stock': 9,
        'category_id': 2,
        'description': 'Sleek slip-on silhouette in burnished brown leather.',
        'image_url': 'https://images.unsplash.com/photo-1638247025967-b4e38f787b76?w=400',
      },
      {
        'name': 'Court Champion Low Sneaker',
        'price': 70.00,
        'stock': 16,
        'category_id': 1,
        'description': 'Clean monochrome profile with cupsole construction.',
        'image_url':
            'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=400',
      },
      {
        'name': 'Cloud Cushion Pool Slides',
        'price': 25.00,
        'stock': 50,
        'category_id': 4,
        'description': 'Waterproof molded EVA foam for ultimate comfort.',
        'image_url': 'https://images.unsplash.com/photo-1607522370275-f14206abe5d3?w=400',
      },
    ];

    await client.from('products').insert(sampleProducts);
  }
}
