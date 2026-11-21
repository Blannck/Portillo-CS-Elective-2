import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/theme_provider.dart';
import 'services/auth_gate.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Safely attempt to load .env asset
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Could not load .env file, falling back to defaults: $e');
  }

  // Obtain Supabase credentials from .env or default constants
  final supabaseUrl = dotenv.maybeGet('SUPABASE_URL') ??
      const String.fromEnvironment(
        'SUPABASE_URL',
        defaultValue: 'https://bbvnzsbshhnyjiclylat.supabase.co',
      );

  final supabaseAnonKey = dotenv.maybeGet('SUPABASE_ANON_KEY') ??
      const String.fromEnvironment(
        'SUPABASE_ANON_KEY',
        defaultValue: 'sb_publishable_skNu3pLy46vry9vCWHiJuw_c_8To_eb',
      );

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabaseAnonKey,
  );

  runApp(
    const ProviderScope(
      child: PickleProShopApp(),
    ),
  );
}

class PickleProShopApp extends ConsumerWidget {
  const PickleProShopApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'PicklePro E-Commerce',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      home: const AuthGate(),
    );
  }
}
