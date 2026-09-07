import 'package:flutter/material.dart';

/// Manages the app's [ThemeMode] (light / dark).
///
/// This is a [ChangeNotifier] because the theme mode is mutable state
/// that multiple widgets (the AppBar toggle and [MaterialApp]) must react to.
/// When [toggleTheme] is called, the whole app re-renders with the new theme.
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  /// Current active theme mode.
  ThemeMode get themeMode => _themeMode;

  /// Whether dark mode is currently active.
  bool get isDark => _themeMode == ThemeMode.dark;

  /// Toggles between [ThemeMode.light] and [ThemeMode.dark].
  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
