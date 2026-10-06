import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pokemon_provider.dart';

/// Pokédex-styled search input, filter chips, and sorting controls.
/// All actions mutate and read from the central [PokemonProvider] App State.
class PokedexSearchBar extends StatefulWidget {
  const PokedexSearchBar({super.key});

  @override
  State<PokedexSearchBar> createState() => _PokedexSearchBarState();
}

class _PokedexSearchBarState extends State<PokedexSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final initialQuery = context.read<PokemonProvider>().searchQuery;
    _controller = TextEditingController(text: initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PokemonProvider>();

    // Keep controller synchronized with external App State clears
    if (_controller.text != provider.searchQuery) {
      _controller.value = _controller.value.copyWith(
        text: provider.searchQuery,
        selection: TextSelection.collapsed(offset: provider.searchQuery.length),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFDC0A2D),
      ),
      child: Column(
        children: [
          // Row 1: Search Input + Sort Menu Button
          Row(
            children: [
              // Search Input Box (Pokédex Dark Terminal / Console Bezel)
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B2D42),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF535670),
                      width: 1.5,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _controller,
                    onChanged: (value) => provider.setSearchQuery(value),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    cursorColor: Colors.cyanAccent,
                    decoration: InputDecoration(
                      hintText: 'Search name or #ID (e.g. 025)...',
                      hintStyle: TextStyle(
                        color: Colors.white.withAlpha(140),
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Colors.cyanAccent,
                        size: 20,
                      ),
                      suffixIcon: provider.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.white70,
                                size: 18,
                              ),
                              onPressed: () {
                                _controller.clear();
                                provider.clearSearchQuery();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Sort Menu Button (Hardware Button Aesthetic)
              PopupMenuButton<PokemonSortOption>(
                initialValue: provider.sortOption,
                tooltip: 'Sort Pokémon',
                onSelected: (option) => provider.setSortOption(option),
                itemBuilder: (context) {
                  return PokemonSortOption.values.map((option) {
                    final isSelected = option == provider.sortOption;
                    return PopupMenuItem<PokemonSortOption>(
                      value: option,
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: isSelected ? Colors.redAccent : Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            option.label,
                            style: TextStyle(
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList();
                },
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B2D42),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF535670),
                      width: 1.5,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sort_rounded, color: Colors.amberAccent, size: 20),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_drop_down, color: Colors.white70, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Row 2: Filter Chips (Range Filtering)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: PokemonIdFilter.values.map((filter) {
                final isSelected = filter == provider.idFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: FilterChip(
                    label: Text(filter.label),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.black87 : Colors.white,
                    ),
                    selected: isSelected,
                    onSelected: (_) => provider.setIdFilter(filter),
                    selectedColor: const Color(0xFF52DE97), // Retro digital green
                    backgroundColor: const Color(0xFF8E061D), // Dark crimson
                    checkmarkColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF52DE97)
                            : Colors.white24,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    visualDensity: VisualDensity.compact,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
