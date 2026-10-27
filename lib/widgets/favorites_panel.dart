import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';
import '../screens/pokemon_detail_screen.dart';

class FavoritesPanel extends ConsumerWidget {
  const FavoritesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pokemonProvider);
    final notifier = ref.read(pokemonProvider.notifier);
    final isExpanded = state.isFavoritesPanelExpanded;
    final favoriteList = state.favoritePokemonList;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      child: isExpanded
          ? Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E272C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFF1744), width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    color: const Color(0xFF12191D),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.favorite_rounded,
                          color: Color(0xFFFF1744),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'FAVORITE SPECIMENS',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Color(0xFFFF8A80),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF1744).withAlpha(50),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFFF1744),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${favoriteList.length}',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF8A80),
                            ),
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () => notifier.toggleFavoritesPanel(),
                          borderRadius: BorderRadius.circular(6),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'COLLAPSE',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 10,
                                    color: Colors.white54,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                SizedBox(width: 2),
                                Icon(
                                  Icons.keyboard_arrow_up_rounded,
                                  color: Colors.white54,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (favoriteList.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite_border_rounded,
                            size: 36,
                            color: Colors.white.withAlpha(60),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'NO FAVORITES MARKED',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tap the heart icon on any Pokémon card to add it to your favorites.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                              color: Colors.white38,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    SizedBox(
                      height: 110,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        itemCount: favoriteList.length,
                        itemBuilder: (context, index) {
                          final pokemon = favoriteList[index];
                          final nickname = state.getNickname(pokemon.id);
                          return _buildFavoriteChip(
                            context: context,
                            ref: ref,
                            pokemon: pokemon,
                            nickname: nickname,
                          );
                        },
                      ),
                    ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildFavoriteChip({
    required BuildContext context,
    required WidgetRef ref,
    required Pokemon pokemon,
    required String? nickname,
  }) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF263238),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF1744).withAlpha(120),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            ref.read(pokemonProvider.notifier).selectPokemon(pokemon);
            final isOnDetail =
                context.findAncestorWidgetOfExactType<PokemonDetailScreen>() !=
                null;
            if (!isOnDetail) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PokemonDetailScreen(),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: pokemon.imageUrl.isNotEmpty
                      ? Image.network(
                          pokemon.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.catching_pokemon,
                            color: Colors.white24,
                            size: 24,
                          ),
                        )
                      : const Icon(
                          Icons.catching_pokemon,
                          color: Colors.white24,
                          size: 24,
                        ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        pokemon.formattedId,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF80DEEA),
                        ),
                      ),
                      Text(
                        nickname ?? pokemon.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: nickname != null
                              ? Colors.amberAccent
                              : Colors.white,
                        ),
                      ),
                      if (nickname != null)
                        Text(
                          '(${pokemon.displayName})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 9,
                            color: Colors.white54,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                  icon: const Icon(
                    Icons.favorite_rounded,
                    color: Color(0xFFFF1744),
                    size: 18,
                  ),
                  onPressed: () {
                    ref
                        .read(pokemonProvider.notifier)
                        .removeFavorite(pokemon.id);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
