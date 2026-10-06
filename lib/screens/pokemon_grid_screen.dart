import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pokemon_provider.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/pokedex_header.dart';
import '../widgets/pokedex_search_bar.dart';
import '../widgets/pokemon_card.dart';
import 'pokemon_detail_screen.dart';

class PokemonGridScreen extends StatefulWidget {
  const PokemonGridScreen({super.key});

  @override
  State<PokemonGridScreen> createState() => _PokemonGridScreenState();
}

class _PokemonGridScreenState extends State<PokemonGridScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PokemonProvider>();
      if (provider.isInitial) {
        provider.fetchPokemonList(limit: 30);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PokemonProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFDC0A2D),
      body: SafeArea(
        child: Column(
          children: [
            PokedexHeader(
              isRefreshing: provider.isLoading,
              onRefresh: () => provider.refresh(),
            ),

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
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF00E676),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            provider.isSuccess
                                ? 'ENTRIES: ${provider.filteredPokemonList.length} / ${provider.allPokemonList.length}'
                                : 'SYSTEM READY',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF80DEEA),
                              letterSpacing: 1,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            provider.sortOption.label,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(child: _buildInnerScreen(context, provider)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInnerScreen(BuildContext context, PokemonProvider provider) {
    if (provider.isLoading) {
      return const LoadingView();
    }

    if (provider.isError) {
      return ErrorView(
        errorMessage: provider.errorMessage,
        onRetry: () => provider.refresh(),
      );
    }

    if (provider.isSuccess) {
      final filteredList = provider.filteredPokemonList;

      if (filteredList.isEmpty) {
        return EmptyView(
          title: 'NO POKÉMON MATCH',
          description: provider.searchQuery.isNotEmpty
              ? 'No Pokémon matches "${provider.searchQuery}".'
              : 'No entries found in this filter range.',
          buttonLabel: 'RESET SEARCH & FILTER',
          onRefresh: () {
            provider.clearSearchQuery();
            provider.setIdFilter(PokemonIdFilter.all);
          },
        );
      }

      return RefreshIndicator(
        color: const Color(0xFFDC0A2D),
        backgroundColor: Colors.white,
        onRefresh: () => provider.refresh(),
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
                childAspectRatio: isTablet ? 0.9 : 0.85,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final pokemon = filteredList[index];
                return PokemonCard(
                  pokemon: pokemon,
                  onTap: () {
                    provider.selectPokemon(pokemon);
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
