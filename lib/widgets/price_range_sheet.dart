import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../models/product_filter.dart';
import '../providers/product_filter_provider.dart';

class PriceRangeSheet extends ConsumerStatefulWidget {
  const PriceRangeSheet({super.key});

  @override
  ConsumerState<PriceRangeSheet> createState() => _PriceRangeSheetState();
}

class _PriceRangeSheetState extends ConsumerState<PriceRangeSheet> {
  late RangeValues _currentRange;
  late ProductSortOption _selectedSort;
  static const double minLimit = 0.0;
  static const double maxLimit = 300.0;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(productFilterProvider);
    _currentRange = RangeValues(
      filter.minPrice ?? minLimit,
      filter.maxPrice ?? maxLimit,
    );
    _selectedSort = filter.sortOption;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter & Sort',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentRange = const RangeValues(minLimit, maxLimit);
                    _selectedSort = ProductSortOption.newest;
                  });
                },
                child: const Text('Reset'),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 8),

          // Price Range Title & Values
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Price Range',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(
                '\$${_currentRange.start.toStringAsFixed(0)} - \$${_currentRange.end.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          RangeSlider(
            values: _currentRange,
            min: minLimit,
            max: maxLimit,
            divisions: 30,
            activeColor: AppColors.primary,
            inactiveColor: Colors.grey.shade300,
            labels: RangeLabels(
              '\$${_currentRange.start.toStringAsFixed(0)}',
              '\$${_currentRange.end.toStringAsFixed(0)}',
            ),
            onChanged: (values) {
              setState(() => _currentRange = values);
            },
          ),

          const SizedBox(height: 12),
          const Text(
            'Sort By',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSortChip('Newest', ProductSortOption.newest),
              _buildSortChip(
                  'Price: Low to High', ProductSortOption.priceLowToHigh),
              _buildSortChip(
                  'Price: High to Low', ProductSortOption.priceHighToLow),
              _buildSortChip('Name: A to Z', ProductSortOption.nameAZ),
            ],
          ),

          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              ref.read(productFilterProvider.notifier).setPriceRange(
                    _currentRange.start > minLimit ? _currentRange.start : null,
                    _currentRange.end < maxLimit ? _currentRange.end : null,
                  );
              ref
                  .read(productFilterProvider.notifier)
                  .setSortOption(_selectedSort);
              Navigator.pop(context);
            },
            child: const Text('Apply Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, ProductSortOption option) {
    final isSelected = _selectedSort == option;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary.withAlpha(50),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryDark : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedSort = option);
        }
      },
    );
  }
}
