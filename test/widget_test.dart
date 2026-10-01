import 'package:flutter_test/flutter_test.dart';
import 'package:pokidex_act/main.dart';
import 'package:pokidex_act/models/pokemon.dart';

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

  group('Widget Tests', () {
    testWidgets('PokedexApp loads and renders title', (WidgetTester tester) async {
      await tester.pumpWidget(const PokedexApp());
      expect(find.text('Pokédex (First 30)'), findsOneWidget);
    });
  });
}
