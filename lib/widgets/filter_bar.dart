import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../providers/category_provider.dart';
import '../providers/product_filter_provider.dart';
import 'price_range_sheet.dart';

class FilterBar extends ConsumerStatefulWidget {
  const FilterBar({super.key});

  @override
  ConsumerState<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends ConsumerState<FilterBar> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(productFilterProvider).search;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(productFilterProvider.notifier).setSearch(value);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(productFilterProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          // Search row + Filter sheet button
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search paddles, shoes, balls...',
                    hintStyle: const TextStyle(fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: AppColors.slateMuted),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: _clearSearch,
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Filter modal button
              IconButton.filledTonal(
                icon: Badge(
                  isLabelVisible: filter.minPrice != null ||
                      filter.maxPrice != null ||
                      filter.sortOption.index != 0,
                  child: const Icon(Icons.tune),
                ),
                tooltip: 'Price & Sort Filters',
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (_) => const PriceRangeSheet(),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Horizontal Category Choice Chips
          categoriesAsync.when(
            loading: () => const SizedBox(
              height: 38,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            error: (_, _) => const SizedBox(height: 38),
            data: (categories) {
              return SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: const Text('All'),
                        selected: filter.categoryId == null,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: filter.categoryId == null
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: filter.categoryId == null
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                        onSelected: (_) {
                          ref
                              .read(productFilterProvider.notifier)
                              .setCategoryId(null);
                        },
                      ),
                    ),
                    for (final category in categories)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(category.name),
                          selected: filter.categoryId == category.id,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: filter.categoryId == category.id
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: filter.categoryId == category.id
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                          onSelected: (_) {
                            ref
                                .read(productFilterProvider.notifier)
                                .setCategoryId(category.id);
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
