import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../services/poke_api_service.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/pokemon_card.dart';

class PokemonGridScreen extends StatefulWidget {
  const PokemonGridScreen({super.key});

  @override
  State<PokemonGridScreen> createState() => _PokemonGridScreenState();
}

class _PokemonGridScreenState extends State<PokemonGridScreen> {
  final PokeApiService _pokeApiService = PokeApiService();

  late Future<List<Pokemon>> _pokemonFuture;

  @override
  void initState() {
    super.initState();
    _fetchPokemon();
  }

  void _fetchPokemon() {
    _pokemonFuture = _pokeApiService.fetchPokemonList(limit: 30);
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _fetchPokemon();
    });
    try {
      await _pokemonFuture;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.catching_pokemon, color: Colors.white, size: 28),
            const SizedBox(width: 8),
            const Text(
              'Pokédex (First 30)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reload Pokémon',
            onPressed: _handleRefresh,
          ),
        ],
      ),
      body: FutureBuilder<List<Pokemon>>(
        future: _pokemonFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView(
              message: 'Fetching Pokémon from PokéAPI...',
            );
          }

          if (snapshot.hasError) {
            final error = snapshot.error;
            final message = error != null
                ? error.toString().replaceFirst('Exception: ', '')
                : 'An unknown error occurred';
            return ErrorView(errorMessage: message, onRetry: _handleRefresh);
          }

          if (snapshot.hasData) {
            final pokemonList = snapshot.data!;

            if (pokemonList.isEmpty) {
              return EmptyView(onRefresh: _handleRefresh);
            }

            return RefreshIndicator(
              color: Colors.redAccent,
              onRefresh: _handleRefresh,
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: pokemonList.length,
                itemBuilder: (context, index) {
                  return PokemonCard(pokemon: pokemonList[index]);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
