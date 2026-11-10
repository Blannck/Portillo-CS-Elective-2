import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/price_slider_filter.dart';
import '../widgets/product_card.dart';
import '../widgets/product_dialogs.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Catalog',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Shop the latest items on our catalog',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort Products',
            onSelected: (val) {
              if (val == 'price_asc') {
                provider.setSorting('price', true);
              } else if (val == 'price_desc') {
                provider.setSorting('price', false);
              } else if (val == 'name_asc') {
                provider.setSorting('name', true);
              } else if (val == 'id_desc') {
                provider.setSorting('id', false);
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'price_asc',
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      size: 16,
                      color:
                          provider.sortBy == 'price' && provider.sortAscending
                          ? theme.colorScheme.primary
                          : null,
                    ),
                    const SizedBox(width: 8),
                    const Text('Price: Low to High'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'price_desc',
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_downward,
                      size: 16,
                      color:
                          provider.sortBy == 'price' && !provider.sortAscending
                          ? theme.colorScheme.primary
                          : null,
                    ),
                    const SizedBox(width: 8),
                    const Text('Price: High to Low'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'name_asc',
                child: Row(
                  children: [
                    Icon(
                      Icons.sort_by_alpha,
                      size: 16,
                      color: provider.sortBy == 'name'
                          ? theme.colorScheme.primary
                          : null,
                    ),
                    const SizedBox(width: 8),
                    const Text('Name: A to Z'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'id_desc',
                child: Row(
                  children: [
                    Icon(
                      Icons.new_releases_outlined,
                      size: 16,
                      color: provider.sortBy == 'id'
                          ? theme.colorScheme.primary
                          : null,
                    ),
                    const SizedBox(width: 8),
                    const Text('Newest First'),
                  ],
                ),
              ),
            ],
          ),

          IconButton(
            icon: const Icon(Icons.cloud_download_outlined),
            tooltip: 'Seed Mock Products to Supabase',
            onPressed: () async {
              final scaffold = ScaffoldMessenger.of(context);
              final ok = await provider.seedSampleData();
              if (ok) {
                scaffold.showSnackBar(
                  const SnackBar(
                    content: Text('Sample products seeded successfully!'),
                  ),
                );
              }
            },
          ),

          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Product',
            onPressed: () => ProductDialogs.showAddProductDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          const PriceSliderFilter(),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.fetchProducts(),
              child: _buildBodyContent(context, provider),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const PaginationBar(),
    );
  }

  Widget _buildBodyContent(BuildContext context, ProductProvider provider) {
    if (provider.isLoading && provider.products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Querying Supabase products...'),
          ],
        ),
      );
    }

    if (provider.errorMessage != null && provider.products.isEmpty) {
      final isTableMissing =
          provider.errorMessage!.contains('PGRST205') ||
          provider.errorMessage!.contains('Could not find the table');

      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isTableMissing
                    ? Icons.table_view_outlined
                    : Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                isTableMissing
                    ? 'Products Table Not Found in Supabase'
                    : 'Error Loading Products',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isTableMissing
                    ? 'The "products" table has not been created yet in your Supabase project.\n\nPlease create the products table in your Supabase SQL editor.'
                    : provider.errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (provider.products.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              const Text(
                'No products match your filters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'No products found between ₱${provider.priceRange.start.toStringAsFixed(0)} and ₱${provider.priceRange.end.toStringAsFixed(0)}'
                '${provider.searchQuery.isNotEmpty ? ' matching "${provider.searchQuery}"' : ''}.\nTry adjusting the price slider.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                icon: const Icon(Icons.cloud_upload_outlined),
                label: const Text('Seed Sample Products'),
                onPressed: () => provider.seedSampleData(),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 4
            : constraints.maxWidth > 600
            ? 3
            : 2;

        return Stack(
          children: [
            GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: provider.products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) {
                final product = provider.products[index];
                return ProductCard(product: product);
              },
            ),
            if (provider.isLoading)
              Container(
                color: Colors.black12,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }
}
