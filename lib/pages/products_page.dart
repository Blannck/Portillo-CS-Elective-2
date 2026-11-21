import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../providers/auth_providers.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/cart_icon_badge.dart';
import '../widgets/filter_bar.dart';
import '../widgets/product_card.dart';
import '../widgets/role_badge.dart';
import 'admin/add_edit_product_page.dart';
import 'admin/admin_order_list_page.dart';
import 'admin/category_management_page.dart';
import 'customer/cart_page.dart';
import 'customer/order_history_page.dart';

class ProductsPage extends ConsumerWidget {
  const ProductsPage({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Sign Out'),
        content: const Text(
          'Are you sure you want to sign out?\nYour cart will be emptied.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Role determination via isAdminProvider
    final isAdmin = ref.watch(isAdminProvider).value ?? false;
    final productsAsync = ref.watch(productProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final userEmail = ref.watch(userEmailProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.sports_tennis, color: AppColors.accent, size: 22),
            const SizedBox(width: 8),
            Text(
              isAdmin ? 'PicklePro Admin' : 'PicklePro Shop',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          // Customer: Cart Icon with Badge
          if (!isAdmin) const CartIconBadge(),

          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () => _confirmLogout(context, ref),
          ),
        ],
      ),

      // Side Navigation Drawer
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Profile Header
              Container(
                padding: const EdgeInsets.all(20),
                color: AppColors.courtNavy,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        (profileAsync.value?.firstname?.isNotEmpty == true
                                ? profileAsync.value!.firstname![0]
                                : userEmail?.isNotEmpty == true
                                    ? userEmail![0]
                                    : 'U')
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      profileAsync.value?.fullName ?? 'Pickleball Player',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userEmail ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    RoleBadge(isAdmin: isAdmin),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Navigation Options based on role
              if (!isAdmin) ...[
                ListTile(
                  leading: const Icon(Icons.storefront_outlined,
                      color: AppColors.primary),
                  title: const Text('Product Catalog'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.shopping_cart_outlined,
                      color: AppColors.primary),
                  title: const Text('My Cart'),
                  trailing: Consumer(
                    builder: (_, r, _) {
                      final count = r.watch(cartProvider).totalCount;
                      return count > 0
                          ? Badge.count(count: count)
                          : const SizedBox.shrink();
                    },
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartPage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.receipt_long_outlined,
                      color: AppColors.primary),
                  title: const Text('Order History'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OrderHistoryPage(),
                      ),
                    );
                  },
                ),
              ],

              if (isAdmin) ...[
                ListTile(
                  leading: const Icon(Icons.inventory_2_outlined,
                      color: AppColors.primary),
                  title: const Text('Manage Products'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.category_outlined,
                      color: AppColors.primary),
                  title: const Text('Manage Categories'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CategoryManagementPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.assignment_outlined,
                      color: AppColors.primary),
                  title: const Text('Customer Orders'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminOrderListPage(),
                      ),
                    );
                  },
                ),
              ],

              const Spacer(),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: AppColors.error),
                title: const Text('Sign Out',
                    style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmLogout(context, ref);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),

      // Admin Floating Action Button: redirects to Add Product Form
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddEditProductPage(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Product'),
            )
          : null,

      body: Column(
        children: [
          // Filter & Search Header
          const FilterBar(),

          // Product Catalog Grid
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off,
                          size: 48, color: AppColors.error),
                      const SizedBox(height: 12),
                      Text(
                        'Failed to load catalog: $err',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.error),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.tonal(
                        onPressed: () =>
                            ref.read(productProvider.notifier).refresh(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (products) {
                if (products.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 64,
                            color: AppColors.slateMuted,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No products match your criteria',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.courtNavy,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Try adjusting your search keywords, category, or price range.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.slateMuted),
                          ),
                          const SizedBox(height: 16),
                          if (isAdmin)
                            FilledButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AddEditProductPage(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add First Product'),
                            ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => ref.read(productProvider.notifier).refresh(),
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.62,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: products.length,
                    itemBuilder: (ctx, index) {
                      final product = products[index];
                      return ProductCard(
                        product: product,
                        isAdmin: isAdmin,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
