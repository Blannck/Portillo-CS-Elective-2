import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';

class PriceSliderFilter extends StatefulWidget {
  const PriceSliderFilter({super.key});

  @override
  State<PriceSliderFilter> createState() => _PriceSliderFilterState();
}

class _PriceSliderFilterState extends State<PriceSliderFilter> {
  late TextEditingController _searchController;
  RangeValues? _localRange;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final currentRange = _localRange ?? provider.priceRange;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant
              .withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search products by name...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        provider.setSearchQuery('');
                      },
                    )
                  : null,
              isDense: true,
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (val) {
              provider.setSearchQuery(val);
            },
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.tune,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Price Filter Range',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '₱${currentRange.start.toStringAsFixed(0)} - ₱${currentRange.end.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          RangeSlider(
            values: currentRange,
            min: ProductProvider.minPriceBound,
            max: ProductProvider.maxPriceBound,
            divisions: 60,
            labels: RangeLabels(
              '₱${currentRange.start.toStringAsFixed(0)}',
              '₱${currentRange.end.toStringAsFixed(0)}',
            ),
            activeColor: Theme.of(context).colorScheme.primary,
            inactiveColor: Theme.of(context).colorScheme.outlineVariant,
            onChanged: (RangeValues newRange) {
              setState(() {
                _localRange = newRange;
              });
            },
            onChangeEnd: (RangeValues newRange) {
              _localRange = null;
              provider.updatePriceRange(newRange);
            },
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPresetChip(context, provider, 'All Prices', 0, 300),
                const SizedBox(width: 8),
                _buildPresetChip(context, provider, '< ₱50', 0, 50),
                const SizedBox(width: 8),
                _buildPresetChip(context, provider, '₱50 - ₱100', 50, 100),
                const SizedBox(width: 8),
                _buildPresetChip(context, provider, '₱100 - ₱200', 100, 200),
                const SizedBox(width: 8),
                _buildPresetChip(context, provider, '₱200+', 200, 300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(
    BuildContext context,
    ProductProvider provider,
    String label,
    double min,
    double max,
  ) {
    final isSelected =
        provider.priceRange.start == min && provider.priceRange.end == max;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _localRange = null;
        });
        provider.updatePriceRange(RangeValues(min, max));
      },
    );
  }
}
