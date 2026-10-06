import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/pokemon_provider.dart';
import 'screens/pokemon_grid_screen.dart';

void main() {
  runApp(const PokedexApp());
}

class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PokemonProvider>(
      create: (_) => PokemonProvider(),
      child: MaterialApp(
        title: 'Pokédex',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFDC0A2D),
            primary: const Color(0xFFDC0A2D),
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFDC0A2D),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFDC0A2D),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        home: const PokemonGridScreen(),
      ),
    );
  }
}
