import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/pokemon_grid_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    publishableKey: dotenv.get('SUPABASE_ANON_KEY'),
  );

  runApp(const ProviderScope(child: PokedexApp()));
}

class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
    );
  }
}
