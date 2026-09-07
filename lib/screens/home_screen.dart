import 'package:flutter/material.dart';

import '../data/products_data.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../widgets/shopify_app_bar.dart';

/// The main landing screen showing all products in a responsive grid.
///
/// [StatefulWidget] justification:
///   - Owns [_searchQuery] — changes on every keystroke, triggers grid filter.
///   - Owns [_selectedCategory] — changes on chip tap, drives category filter.
///   Both of these mutations require [setState] to rebuild the product grid.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory; // null = "All"

  /// Unique sorted category list derived from the product catalogue.
  static final List<String> _categories =
      ({for (final p in kProducts) p.category}).toList()..sort();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> get _filteredProducts {
    return kProducts.where((p) {
      final matchesCat =
          _selectedCategory == null || p.category == _selectedCategory;
      final q = _searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q);
      return matchesCat && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filteredProducts;

    // Key that changes whenever the active filter changes — drives AnimatedSwitcher.
    final filterKey = '${_selectedCategory ?? 'all'}-$_searchQuery';

    return Scaffold(
      appBar: const ShopifyAppBar(title: 'Shopify'),
      body: CustomScrollView(
        slivers: [
          // ── Hero banner ──────────────────────────────────────────────────
          SliverToBoxAdapter(child: _HeroBanner()),

          // ── Search & Filter bar ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  // Search field
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Search products…',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Compact Filter dropdown
                  _CompactCategoryFilter(
                    categories: _categories,
                    selectedCategory: _selectedCategory,
                    onSelected: (cat) =>
                        setState(() => _selectedCategory = cat),
                  ),
                ],
              ),
            ),
          ),

          // ── Section heading with animated item count ──────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            _selectedCategory ??
                                (_searchQuery.isEmpty
                                    ? 'All Products'
                                    : 'Results for "$_searchQuery"'),
                            style: theme.textTheme.headlineSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_selectedCategory != null) ...[
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => setState(() => _selectedCategory = null),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Icon(
                                Icons.cancel_outlined,
                                size: 16,
                                color: theme.colorScheme.onSurface.withAlpha(140),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Animated count so the number cross-fades when filter changes
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      '${filtered.length} items',
                      key: ValueKey(filtered.length),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Responsive animated product grid ──────────────────────────────
          // SliverLayoutBuilder detects available width:
          //   < 600dp  → 2 columns (phone)
          //   ≥ 600dp  → 3+ columns (tablet/desktop)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount =
                    constraints.crossAxisExtent < 600 ? 2 : 3;

                if (filtered.isEmpty) {
                  return SliverToBoxAdapter(child: _EmptyState());
                }

                return SliverToBoxAdapter(
                  // AnimatedSwitcher fades the whole grid in/out whenever
                  // the active filter key changes (category or search query).
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: child,
                    ),
                    child: GridView.builder(
                      // Key changes force AnimatedSwitcher to treat this as
                      // a new widget tree and play the cross-fade animation.
                      key: ValueKey(filterKey),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.62,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) => _AnimatedGridItem(
                        // ValueKey ties each card to its product, so Flutter
                        // knows exactly which item appeared / disappeared when
                        // the list is filtered.
                        key: ValueKey(filtered[index].id),
                        index: index,
                        child: ProductCard(product: filtered[index]),
                      ),
                    ),
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

// ── Compact Minimalist Category Dropdown ─────────────────────────────────────

/// A compact button with an aesthetic dropdown menu for category filtering.
///
/// [StatelessWidget] — reads active state and triggers callback on selection.
class _CompactCategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onSelected;

  const _CompactCategoryFilter({
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasActiveFilter = selectedCategory != null;
    final effectiveValue = selectedCategory ?? '__all__';

    return PopupMenuButton<String>(
      tooltip: 'Filter by category',
      initialValue: effectiveValue,
      onSelected: (val) {
        if (val == '__all__') {
          onSelected(null);
        } else {
          onSelected(val);
        }
      },
      elevation: 3,
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor, width: 0.8),
      ),
      color: theme.cardTheme.color,
      itemBuilder: (context) {
        return [
          PopupMenuItem<String>(
            value: '__all__',
            child: Row(
              children: [
                Icon(
                  Icons.apps_rounded,
                  size: 16,
                  color: !hasActiveFilter
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withAlpha(150),
                ),
                const SizedBox(width: 10),
                Text(
                  'All Categories',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: !hasActiveFilter ? FontWeight.w600 : FontWeight.w400,
                    color: !hasActiveFilter
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                if (!hasActiveFilter)
                  Icon(Icons.check_rounded, size: 16, color: theme.colorScheme.primary),
              ],
            ),
          ),
          const PopupMenuDivider(height: 1),
          ...categories.map((cat) {
            final isSelected = selectedCategory == cat;
            return PopupMenuItem<String>(
              value: cat,
              child: Row(
                children: [
                  Icon(
                    _iconForCategory(cat),
                    size: 16,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withAlpha(150),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    cat,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    Icon(Icons.check_rounded, size: 16, color: theme.colorScheme.primary),
                ],
              ),
            );
          }),
        ];
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: hasActiveFilter
              ? theme.colorScheme.primary.withAlpha(20)
              : (theme.brightness == Brightness.dark
                  ? const Color(0xFF21262D)
                  : const Color(0xFFF1F1F1)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasActiveFilter ? theme.colorScheme.primary : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune_rounded,
              size: 18,
              color: hasActiveFilter
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withAlpha(180),
            ),
            const SizedBox(width: 6),
            Text(
              selectedCategory ?? 'Filter',
              style: TextStyle(
                fontSize: 13,
                fontWeight: hasActiveFilter ? FontWeight.w600 : FontWeight.w500,
                color: hasActiveFilter
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withAlpha(200),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: hasActiveFilter
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withAlpha(140),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'apparel':
        return Icons.checkroom_rounded;
      case 'accessories':
        return Icons.watch_outlined;
      case 'footwear':
        return Icons.skateboarding_rounded;
      case 'home & kitchen':
        return Icons.coffee_rounded;
      case 'electronics':
        return Icons.headphones_rounded;
      default:
        return Icons.label_outline_rounded;
    }
  }
}

// ── Staggered grid item ───────────────────────────────────────────────────────

/// Wraps each product card with a staggered fade + slide-up entrance animation.
///
/// [StatefulWidget] justification:
///   - Owns an [AnimationController] that drives the enter animation.
///   - Uses a [Future.delayed] stagger based on [index] so cards ripple in
///     sequentially rather than all appearing at once.
///   - The animation runs once on first build and is not driven by user input.
class _AnimatedGridItem extends StatefulWidget {
  final int index;
  final Widget child;

  const _AnimatedGridItem({
    required this.index,
    required this.child,
    super.key,
  });

  @override
  State<_AnimatedGridItem> createState() => _AnimatedGridItemState();
}

class _AnimatedGridItemState extends State<_AnimatedGridItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    // Stagger: each successive item starts slightly later (max 180 ms delay).
    // Items 0-5 stagger visually; items beyond index 5 all share the max delay
    // so the effect is snappy rather than dragging on for 12 items.
    final delay =
        Duration(milliseconds: (widget.index * 40).clamp(0, 180));
    Future.delayed(delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ── Hero Banner ───────────────────────────────────────────────────────────────
class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      constraints: const BoxConstraints(minHeight: 160),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF004C3F), const Color(0xFF008060)]
              : [const Color(0xFF008060), const Color(0xFF00A67E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(20),
                ),
              ),
            ),
            Positioned(
              right: 40,
              bottom: -30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(15),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'New Arrivals',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white.withAlpha(204),
                      letterSpacing: 1.5,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Shop the Latest\nCollection',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Shop Now',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF008060),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 60,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text('Try a different search or category',
              style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
