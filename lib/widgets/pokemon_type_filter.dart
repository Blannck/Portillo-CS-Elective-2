import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pokemon_provider.dart';

class PokemonTypeColors {
  static const Map<String, Color> _colors = {
    'normal': Color(0xFFA8A878),
    'fire': Color(0xFFF08030),
    'water': Color(0xFF6890F0),
    'electric': Color(0xFFF8D030),
    'grass': Color(0xFF78C850),
    'ice': Color(0xFF98D8D8),
    'fighting': Color(0xFFC03028),
    'poison': Color(0xFFA040A0),
    'ground': Color(0xFFE0C068),
    'flying': Color(0xFFA890F0),
    'psychic': Color(0xFFF85888),
    'bug': Color(0xFFA8B820),
    'rock': Color(0xFFB8A038),
    'ghost': Color(0xFF705898),
    'dragon': Color(0xFF7038F8),
    'steel': Color(0xFFB8B8D0),
    'fairy': Color(0xFFEE99AC),
  };

  static Color getColor(String type) {
    return _colors[type.toLowerCase()] ?? const Color(0xFF78909C);
  }
}

class PokemonTypeFilterBar extends ConsumerWidget {
  const PokemonTypeFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pokemonProvider);
    final notifier = ref.read(pokemonProvider.notifier);
    final activeType = state.selectedType?.toLowerCase();

    final defaultTypes = [
      'grass',
      'poison',
      'fire',
      'water',
      'bug',
      'normal',
      'electric',
      'ground',
      'flying',
      'fairy',
    ];

    final types = state.availableTypes.isNotEmpty
        ? state.availableTypes
        : defaultTypes;

    final isAllSelected = activeType == null || activeType.isEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                const Icon(
                  Icons.filter_alt_rounded,
                  size: 13,
                  color: Color(0xFF80DEEA),
                ),
                const SizedBox(width: 4),
                const Text(
                  'TYPE FILTER:',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: Color(0xFF80DEEA),
                  ),
                ),
                const SizedBox(width: 6),
                if (!isAllSelected) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: PokemonTypeColors.getColor(
                        activeType,
                      ).withAlpha(50),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: PokemonTypeColors.getColor(activeType),
                      ),
                    ),
                    child: Text(
                      activeType.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: PokemonTypeColors.getColor(activeType),
                      ),
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => notifier.clearTypeFilter(),
                    borderRadius: BorderRadius.circular(6),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: Row(
                        children: [
                          Icon(
                            Icons.close_rounded,
                            size: 12,
                            color: Colors.white70,
                          ),
                          SizedBox(width: 2),
                          Text(
                            'CLEAR FILTER',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  const Spacer(),
                  const Text(
                    'SHOWING ALL',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 6),

          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              children: [
                _buildTypeChip(
                  label: 'ALL',
                  color: const Color(0xFF37474F),
                  isSelected: isAllSelected,
                  onTap: () => notifier.clearTypeFilter(),
                ),

                const SizedBox(width: 6),

                ...types.map((type) {
                  final isSelected = activeType == type;
                  final color = PokemonTypeColors.getColor(type);
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _buildTypeChip(
                      label: type.toUpperCase(),
                      color: color,
                      isSelected: isSelected,
                      onTap: () {
                        if (isSelected) {
                          notifier.clearTypeFilter();
                        } else {
                          notifier.setTypeFilter(type);
                        }
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip({
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withAlpha(45),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white : color.withAlpha(120),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withAlpha(160),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check_rounded, size: 13, color: Colors.white),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.white : Colors.white.withAlpha(220),
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
