import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokidex_act/main.dart';
import 'package:pokidex_act/models/pokemon.dart';
import 'package:pokidex_act/providers/pokemon_provider.dart';
import 'package:pokidex_act/screens/pokemon_detail_screen.dart';
import 'package:pokidex_act/widgets/favorites_panel.dart';
import 'package:pokidex_act/widgets/nickname_dialog.dart';
import 'package:pokidex_act/widgets/pokedex_header.dart';
import 'package:pokidex_act/widgets/pokemon_card.dart';
import 'package:pokidex_act/widgets/pokemon_type_filter.dart';

void main() {
  group('Feature 1: Pokémon Model & Type Parsing Tests', () {
    test('Pokemon parses from JSON and formats correctly', () {
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

    test('Pokemon parses types from detail JSON correctly', () {
      final detailJson = {
        'id': 6,
        'name': 'charizard',
        'sprites': {
          'other': {
            'official-artwork': {
              'front_default': 'https://example.com/charizard.png',
            },
          },
        },
        'types': [
          {
            'slot': 1,
            'type': {'name': 'fire', 'url': 'https://pokeapi.co/api/v2/type/10/'},
          },
          {
            'slot': 2,
            'type': {
              'name': 'flying',
              'url': 'https://pokeapi.co/api/v2/type/3/',
            },
          },
        ],
      };

      final pokemon = Pokemon.fromDetailJson(detailJson);
      expect(pokemon.id, 6);
      expect(pokemon.name, 'charizard');
      expect(pokemon.types, ['fire', 'flying']);
      expect(pokemon.imageUrl, 'https://example.com/charizard.png');
    });
  });

  group('Feature 2: Pokémon Nickname Editor State Tests', () {
    test('Allows assigning, editing, and removing custom nicknames in state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(pokemonProvider.notifier);

      // Initially no nickname
      expect(container.read(pokemonProvider).getNickname(25), isNull);

      // Assign nickname
      notifier.setNickname(25, 'Sparky');
      expect(container.read(pokemonProvider).getNickname(25), 'Sparky');

      // Edit nickname
      notifier.setNickname(25, 'Volt Master');
      expect(container.read(pokemonProvider).getNickname(25), 'Volt Master');

      // Remove nickname
      notifier.removeNickname(25);
      expect(container.read(pokemonProvider).getNickname(25), isNull);
    });

    test('Nickname search query filters Pokémon matching custom nickname', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(pokemonProvider.notifier);
      final pikachu = const Pokemon(
        id: 25,
        name: 'pikachu',
        imageUrl: '',
        types: ['electric'],
      );
      final bulbasaur = const Pokemon(
        id: 1,
        name: 'bulbasaur',
        imageUrl: '',
        types: ['grass', 'poison'],
      );

      notifier.selectPokemon(pikachu);
      container.read(pokemonProvider.notifier).state = container
          .read(pokemonProvider)
          .copyWith(allPokemon: [bulbasaur, pikachu]);

      notifier.setNickname(25, 'ThunderGod');
      notifier.setSearchQuery('ThunderGod');

      final filtered = container.read(pokemonProvider).filteredPokemonList;
      expect(filtered.length, 1);
      expect(filtered.first.id, 25);
    });
  });

  group('Feature 3 & 4: Favorites & Heart Indicator State Tests', () {
    test('Allows adding, removing, and toggling favorites with immediate updates', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(pokemonProvider.notifier);

      const pikachu = Pokemon(id: 25, name: 'pikachu', imageUrl: '');
      const charmander = Pokemon(id: 4, name: 'charmander', imageUrl: '');

      container.read(pokemonProvider.notifier).state = container
          .read(pokemonProvider)
          .copyWith(allPokemon: [pikachu, charmander]);

      // Initially empty
      expect(container.read(pokemonProvider).isFavorite(25), isFalse);
      expect(container.read(pokemonProvider).favoritePokemonList, isEmpty);

      // Toggle favorite ON
      notifier.toggleFavorite(25);
      expect(container.read(pokemonProvider).isFavorite(25), isTrue);
      expect(container.read(pokemonProvider).favoritePokemonList.length, 1);
      expect(container.read(pokemonProvider).favoritePokemonList.first.id, 25);

      // Add another favorite
      notifier.addFavorite(4);
      expect(container.read(pokemonProvider).isFavorite(4), isTrue);
      expect(container.read(pokemonProvider).favoritePokemonList.length, 2);

      // Toggle favorite OFF
      notifier.toggleFavorite(25);
      expect(container.read(pokemonProvider).isFavorite(25), isFalse);
      expect(container.read(pokemonProvider).favoritePokemonList.length, 1);
      expect(container.read(pokemonProvider).favoritePokemonList.first.id, 4);

      // Remove favorite
      notifier.removeFavorite(4);
      expect(container.read(pokemonProvider).favoritePokemonList, isEmpty);
    });

    test('Retractable favorites panel expands and collapses in app state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(pokemonProvider.notifier);

      expect(container.read(pokemonProvider).isFavoritesPanelExpanded, isFalse);

      notifier.toggleFavoritesPanel();
      expect(container.read(pokemonProvider).isFavoritesPanelExpanded, isTrue);

      notifier.setFavoritesPanelExpanded(false);
      expect(container.read(pokemonProvider).isFavoritesPanelExpanded, isFalse);
    });
  });

  group('Feature 5: Pokémon Type Filter State Tests', () {
    test('Filters Pokémon by actual type and allows clearing the filter', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(pokemonProvider.notifier);

      const charmander = Pokemon(
        id: 4,
        name: 'charmander',
        imageUrl: '',
        types: ['fire'],
      );
      const squirtle = Pokemon(
        id: 7,
        name: 'squirtle',
        imageUrl: '',
        types: ['water'],
      );
      const bulbasaur = Pokemon(
        id: 1,
        name: 'bulbasaur',
        imageUrl: '',
        types: ['grass', 'poison'],
      );

      container.read(pokemonProvider.notifier).state = container
          .read(pokemonProvider)
          .copyWith(allPokemon: [bulbasaur, charmander, squirtle]);

      // Available types detected correctly
      expect(
        container.read(pokemonProvider).availableTypes,
        containsAll(['fire', 'water', 'grass', 'poison']),
      );

      // Filter by Fire
      notifier.setTypeFilter('fire');
      expect(container.read(pokemonProvider).selectedType, 'fire');
      var filtered = container.read(pokemonProvider).filteredPokemonList;
      expect(filtered.length, 1);
      expect(filtered.first.name, 'charmander');

      // Filter by Water
      notifier.setTypeFilter('water');
      filtered = container.read(pokemonProvider).filteredPokemonList;
      expect(filtered.length, 1);
      expect(filtered.first.name, 'squirtle');

      // Clear filter
      notifier.clearTypeFilter();
      expect(container.read(pokemonProvider).selectedType, isNull);
      filtered = container.read(pokemonProvider).filteredPokemonList;
      expect(filtered.length, 3);
    });
  });

  group('UI & Widget Integration Tests', () {
    testWidgets(
        'PokedexApp initializes and renders Pokédex header, favorites toggle, and search UI',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: PokedexApp(),
        ),
      );
      await tester.pump();

      expect(find.byType(PokedexHeader), findsOneWidget);
      expect(find.text('FAVORITES'), findsOneWidget);
      expect(find.byType(PokemonTypeFilterBar), findsOneWidget);
      expect(find.byType(FavoritesPanel), findsOneWidget);
    });

    testWidgets('Tapping favorites in header expands panel and shows empty state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: PokedexApp(),
        ),
      );
      await tester.pump();

      // Tap FAVORITES toggle button in header
      await tester.tap(find.text('FAVORITES'));
      await tester.pumpAndSettle();

      // Verified: empty message displayed when no favorites have been favorited
      expect(find.text('NO FAVORITES MARKED'), findsOneWidget);
    });

    testWidgets('PokemonCard renders original name and toggles favorite heart',
        (WidgetTester tester) async {
      const pikachu = Pokemon(
        id: 25,
        name: 'pikachu',
        imageUrl: '',
        types: ['electric'],
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PokemonCard(pokemon: pikachu),
            ),
          ),
        ),
      );
      await tester.pump();

      // Verifies original name display
      expect(find.text('Pikachu'), findsOneWidget);

      // Heart icon exists
      final heartFinder = find.byIcon(Icons.favorite_border_rounded);
      expect(heartFinder, findsOneWidget);

      // Tap heart to add to favorites
      await tester.tap(heartFinder);
      await tester.pumpAndSettle();

      // Heart updates immediately to filled
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    });

    testWidgets('PokemonDetailScreen renders details and supports nickname editor',
        (WidgetTester tester) async {
      const pikachu = Pokemon(
        id: 25,
        name: 'pikachu',
        imageUrl: '',
        types: ['electric'],
      );

      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(pokemonProvider.notifier).selectPokemon(pikachu);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: PokemonDetailScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('PIKACHU'), findsOneWidget);
      expect(find.text('NONE ASSIGNED'), findsOneWidget);

      // Tap ASSIGN NICKNAME button to open NicknameDialog
      await tester.tap(find.text('ASSIGN NICKNAME'));
      await tester.pumpAndSettle();

      expect(find.byType(NicknameDialog), findsOneWidget);
      expect(find.text('NICKNAME EDITOR'), findsOneWidget);
    });
  });
}
