import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pokemon_provider.dart';
import '../widgets/favorites_panel.dart';
import '../widgets/nickname_dialog.dart';
import '../widgets/pokedex_header.dart';
import '../widgets/pokemon_type_filter.dart';

class PokemonDetailScreen extends ConsumerWidget {
  const PokemonDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pokemonProvider);
    final notifier = ref.read(pokemonProvider.notifier);
    final pokemon = state.selectedPokemon;

    final isFavorite = pokemon != null ? state.isFavorite(pokemon.id) : false;
    final nickname = pokemon != null ? state.getNickname(pokemon.id) : null;

    return Scaffold(
      backgroundColor: const Color(0xFFDC0A2D), // Pokédex Red
      appBar: AppBar(
        title: const Text(
          'SPECIMEN DATA',
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 16,
          ),
        ),
        backgroundColor: const Color(0xFFDC0A2D),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            tooltip: state.isFavoritesPanelExpanded
                ? 'Collapse Favorites'
                : 'Expand Favorites',
            icon: Badge(
              isLabelVisible: state.favorites.isNotEmpty,
              backgroundColor: const Color(0xFFFF1744),
              label: Text(
                '${state.favorites.length}',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
              child: Icon(
                state.isFavoritesPanelExpanded
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: state.isFavoritesPanelExpanded
                    ? const Color(0xFFFF5252)
                    : Colors.white,
                size: 22,
              ),
            ),
            onPressed: () => notifier.toggleFavoritesPanel(),
          ),
          if (pokemon != null) ...[
            IconButton(
              tooltip: isFavorite ? 'Remove Favorite' : 'Mark as Favorite',
              icon: Icon(
                isFavorite
                    ? Icons.bookmark_added_rounded
                    : Icons.bookmark_add_outlined,
                color: isFavorite ? const Color(0xFFFF1744) : Colors.white,
                size: 22,
              ),
              onPressed: () => notifier.toggleFavorite(pokemon.id),
            ),
            IconButton(
              tooltip: 'Edit Nickname',
              icon: const Icon(Icons.edit_note_rounded, color: Colors.white),
              onPressed: () => NicknameDialog.show(context, pokemon),
            ),
          ],
          const Padding(
            padding: EdgeInsets.only(right: 14.0),
            child: PokedexLogo(size: 30),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const FavoritesPanel(),

            Expanded(
              child: pokemon == null
                  ? const Center(
                      child: Text(
                        'NO SPECIMEN LOADED',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 680),
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E272C),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isFavorite
                                        ? const Color(0xFFFF1744).withAlpha(160)
                                        : const Color(0xFF37474F),
                                    width: 4,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black45,
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      color: const Color(0xFF12191D),
                                      child: Row(
                                        children: [
                                          _buildMiniDot(
                                            const Color(0xFFFF1744),
                                          ),
                                          const SizedBox(width: 6),
                                          _buildMiniDot(
                                            const Color(0xFFFFD600),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'POKÉDEX SENSOR FEED',
                                            style: TextStyle(
                                              fontFamily: 'monospace',
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white38,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                          const Spacer(),
                                          if (isFavorite) ...[
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFFFF1744,
                                                ).withAlpha(40),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: const Color(
                                                    0xFFFF1744,
                                                  ),
                                                  width: 1,
                                                ),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.favorite_rounded,
                                                    size: 10,
                                                    color: Color(0xFFFF1744),
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'FAVORITE',
                                                    style: TextStyle(
                                                      fontFamily: 'monospace',
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFFFF8A80),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                          ],
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFF00E676,
                                              ).withAlpha(40),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: const Color(0xFF00E676),
                                                width: 1,
                                              ),
                                            ),
                                            child: const Text(
                                              'ACTIVE',
                                              style: TextStyle(
                                                fontFamily: 'monospace',
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF00E676),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Expanded(
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Hero(
                                            tag: 'pokemon-image-${pokemon.id}',
                                            child: pokemon.imageUrl.isNotEmpty
                                                ? Image.network(
                                                    pokemon.imageUrl,
                                                    fit: BoxFit.contain,
                                                    loadingBuilder:
                                                        (
                                                          context,
                                                          child,
                                                          progress,
                                                        ) {
                                                          if (progress ==
                                                              null) {
                                                            return child;
                                                          }
                                                          return const CircularProgressIndicator(
                                                            color: Colors
                                                                .cyanAccent,
                                                          );
                                                        },
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return const Icon(
                                                            Icons
                                                                .broken_image_rounded,
                                                            size: 100,
                                                            color:
                                                                Colors.white24,
                                                          );
                                                        },
                                                  )
                                                : const Icon(
                                                    Icons
                                                        .image_not_supported_rounded,
                                                    size: 100,
                                                    color: Colors.white24,
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    Container(
                                      margin: const EdgeInsets.fromLTRB(
                                        14,
                                        0,
                                        14,
                                        14,
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF263238),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: const Color(0xFF455A64),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 3,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFF1E272C,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Colors.cyanAccent
                                                        .withAlpha(120),
                                                  ),
                                                ),
                                                child: Text(
                                                  pokemon.formattedId,
                                                  style: const TextStyle(
                                                    fontFamily: 'monospace',
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.cyanAccent,
                                                    letterSpacing: 1.5,
                                                  ),
                                                ),
                                              ),

                                              Wrap(
                                                spacing: 6,
                                                children: pokemon.types.map((
                                                  type,
                                                ) {
                                                  final color =
                                                      PokemonTypeColors.getColor(
                                                        type,
                                                      );
                                                  return Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 3,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: color.withAlpha(
                                                        50,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                      border: Border.all(
                                                        color: color,
                                                        width: 1.2,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      type.toUpperCase(),
                                                      style: TextStyle(
                                                        fontFamily: 'monospace',
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: color,
                                                        letterSpacing: 1,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ],
                                          ),

                                          const Divider(
                                            color: Colors.white12,
                                            height: 18,
                                          ),

                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'ORIGINAL NAME:',
                                                style: TextStyle(
                                                  fontFamily: 'monospace',
                                                  fontSize: 11,
                                                  color: Colors.white54,
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                              Text(
                                                pokemon.displayName
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                  fontFamily: 'monospace',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  letterSpacing: 1.2,
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 8),

                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'CUSTOM NICKNAME:',
                                                style: TextStyle(
                                                  fontFamily: 'monospace',
                                                  fontSize: 11,
                                                  color: Colors.white54,
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                              Text(
                                                nickname != null
                                                    ? '"$nickname"'
                                                    : 'NONE ASSIGNED',
                                                style: TextStyle(
                                                  fontFamily: 'monospace',
                                                  fontSize: 13,
                                                  fontWeight: nickname != null
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                  color: nickname != null
                                                      ? Colors.amberAccent
                                                      : Colors.white38,
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 12),

                                          Row(
                                            children: [
                                              Expanded(
                                                child: OutlinedButton.icon(
                                                  onPressed: () {
                                                    NicknameDialog.show(
                                                      context,
                                                      pokemon,
                                                    );
                                                  },
                                                  icon: const Icon(
                                                    Icons.edit_note_rounded,
                                                    size: 16,
                                                  ),
                                                  label: Text(
                                                    nickname != null
                                                        ? 'EDIT NICKNAME'
                                                        : 'ASSIGN NICKNAME',
                                                    style: const TextStyle(
                                                      fontFamily: 'monospace',
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 0.8,
                                                    ),
                                                  ),
                                                  style: OutlinedButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.amberAccent,
                                                    side: const BorderSide(
                                                      color: Colors.amberAccent,
                                                    ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 8,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              const SizedBox(width: 8),

                                              OutlinedButton.icon(
                                                onPressed: () {
                                                  notifier.toggleFavorite(
                                                    pokemon.id,
                                                  );
                                                },
                                                icon: Icon(
                                                  isFavorite
                                                      ? Icons.favorite_rounded
                                                      : Icons
                                                            .favorite_border_rounded,
                                                  size: 16,
                                                  color: const Color(
                                                    0xFFFF1744,
                                                  ),
                                                ),
                                                label: Text(
                                                  isFavorite
                                                      ? 'FAVORITED'
                                                      : 'FAVORITE',
                                                  style: const TextStyle(
                                                    fontFamily: 'monospace',
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.8,
                                                  ),
                                                ),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: const Color(
                                                    0xFFFF8A80,
                                                  ),
                                                  side: const BorderSide(
                                                    color: Color(0xFFFF1744),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildHardwareButton(
                                    label: 'PREV',
                                    icon: Icons.arrow_back_rounded,
                                    color: const Color(0xFF2B2D42),
                                    onPressed: () =>
                                        notifier.selectPreviousPokemon(),
                                  ),

                                  _buildHardwareButton(
                                    label: 'GRID',
                                    icon: Icons.grid_view_rounded,
                                    color: const Color(0xFF8E061D),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),

                                  _buildHardwareButton(
                                    label: 'NEXT',
                                    icon: Icons.arrow_forward_rounded,
                                    color: const Color(0xFF2B2D42),
                                    onPressed: () =>
                                        notifier.selectNextPokemon(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(180),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildHardwareButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              offset: Offset(0, 3),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
