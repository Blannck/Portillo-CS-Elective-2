import 'package:flutter_test/flutter_test.dart';
import 'package:pokidex_act/main.dart';
import 'package:pokidex_act/models/pokemon.dart';
import 'package:pokidex_act/providers/pokemon_provider.dart';
import 'package:pokidex_act/widgets/pokedex_header.dart';

void main() {
  group('Pokemon Model Tests', () {
    test('Pokemon parses from JSON correctly', () {
      final json = {
        'name': 'bulbasaur',
        'url': 'https://pokeapi.co/api/v2/pokemon/1/',
      };

      final pokemon = Pokemon.fromJson(json);

      expect(pokemon.id, 1);
      expect(pokemon.name, 'bulbasaur');
      expect(pokemon.displayName, 'Bulbasaur');
      expect(pokemon.formattedId, '#001');
      expect(
        pokemon.imageUrl,
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png',
      );
    });
  });

  group('PokemonProvider Search & Filter Tests', () {
    test('Initial provider state is initial with empty list and null selectedPokemon', () {
      final provider = PokemonProvider();
      expect(provider.status, PokemonStateStatus.initial);
      expect(provider.allPokemonList, isEmpty);
      expect(provider.selectedPokemon, isNull);
    });

    test('selectPokemon updates selectedPokemon in app state', () {
      final provider = PokemonProvider();
      const pokemon = Pokemon(id: 25, name: 'pikachu', imageUrl: 'pikachu.png');

      provider.selectPokemon(pokemon);
      expect(provider.selectedPokemon, isNotNull);
      expect(provider.selectedPokemon?.id, 25);
      expect(provider.selectedPokemon?.displayName, 'Pikachu');

      provider.clearSelectedPokemon();
      expect(provider.selectedPokemon, isNull);
    });

    test('Search query and range filter correctly filters list', () {
      final provider = PokemonProvider();
      provider.setSearchQuery('pika');
      expect(provider.searchQuery, 'pika');

      provider.setSortOption(PokemonSortOption.nameAsc);
      expect(provider.sortOption, PokemonSortOption.nameAsc);

      provider.setIdFilter(PokemonIdFilter.range1To10);
      expect(provider.idFilter, PokemonIdFilter.range1To10);
    });
  });

  group('Widget Tests', () {
    testWidgets('PokedexApp loads and renders PokedexHeader', (WidgetTester tester) async {
      await tester.pumpWidget(const PokedexApp());
      await tester.pump();
      expect(find.byType(PokedexHeader), findsOneWidget);
      expect(find.text('POKÉDEX'), findsOneWidget);
    });
  });
}
