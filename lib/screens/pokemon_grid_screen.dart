import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pokemon_provider.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/favorites_panel.dart';
import '../widgets/loading_view.dart';
import '../widgets/pokedex_header.dart';
import '../widgets/pokedex_search_bar.dart';
import '../widgets/pokemon_card.dart';
import 'pokemon_detail_screen.dart';

class PokemonGridScreen extends ConsumerStatefulWidget {
  const PokemonGridScreen({super.key});

  @override
  ConsumerState<PokemonGridScreen> createState() => _PokemonGridScreenState();
}

class _PokemonGridScreenState extends ConsumerState<PokemonGridScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(pokemonProvider);
      if (state.isInitial) {
        ref.read(pokemonProvider.notifier).fetchPokemonList(limit: 30);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pokemonProvider);
    final notifier = ref.read(pokemonProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFDC0A2D),
      body: SafeArea(
        child: Column(
          children: [
            const PokedexHeader(),

            const FavoritesPanel(),

            const PokedexSearchBar(),

            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(14, 4, 14, 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E272C),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF37474F), width: 4),
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
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      color: const Color(0xFF12191D),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: state.isSuccess
                                  ? const Color(0xFF00E676)
                                  : (state.isError
                                        ? const Color(0xFFFF1744)
                                        : const Color(0xFFFFD600)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            state.isSuccess
                                ? 'ENTRIES: ${state.filteredPokemonList.length} / ${state.allPokemon.length}'
                                : (state.isLoading
                                      ? 'SCANNING DATABASE...'
                                      : 'SYSTEM READY'),
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF80DEEA),
                              letterSpacing: 1,
                            ),
                          ),
                          if (state.selectedType != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF80DEEA).withAlpha(40),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                state.selectedType!.toUpperCase(),
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF80DEEA),
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          Text(
                            state.sortOption.label,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: _buildInnerScreen(context, state, notifier),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInnerScreen(
    BuildContext context,
    PokemonState state,
    PokemonNotifier notifier,
  ) {
    if (state.isLoading) {
      return const LoadingView();
    }

    if (state.isError) {
      return ErrorView(
        errorMessage: state.errorMessage,
        onRetry: () => notifier.fetchPokemonList(),
      );
    }

    if (state.isSuccess) {
      final filteredList = state.filteredPokemonList;

      if (filteredList.isEmpty) {
        String description = 'No Pokémon match your current filter query.';
        if (state.selectedType != null) {
          description =
              'No Pokémon found with type "${state.selectedType!.toUpperCase()}".';
        } else if (state.searchQuery.isNotEmpty) {
          description = 'No Pokémon matches "${state.searchQuery}".';
        }

        return EmptyView(
          title: 'NO POKÉMON MATCH',
          description: description,
          buttonLabel: 'RESET SEARCH & FILTERS',
          onRefresh: () {
            notifier.clearSearchQuery();
            notifier.clearTypeFilter();
            notifier.setIdFilter(PokemonIdFilter.all);
          },
        );
      }

      return RefreshIndicator(
        color: const Color(0xFFDC0A2D),
        backgroundColor: Colors.white,
        onRefresh: () => notifier.fetchPokemonList(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= 600;
            final crossAxisCount = isTablet ? 4 : 2;

            return GridView.builder(
              padding: const EdgeInsets.all(12),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: isTablet ? 0.85 : 0.78,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final pokemon = filteredList[index];
                return PokemonCard(
                  pokemon: pokemon,
                  onTap: () {
                    notifier.selectPokemon(pokemon);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PokemonDetailScreen(),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
