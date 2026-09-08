import 'package:flutter/material.dart';

/// Manages application-wide theme mode state (Light vs. Dark mode).
/// 
/// Notifies listening widgets whenever the theme changes so the UI rebuilds instantly.
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  /// Current active [ThemeMode].
  ThemeMode get themeMode => _themeMode;

  /// Returns true if dark mode is currently active.
  bool get isDark => _themeMode == ThemeMode.dark;

  /// Toggles between light mode and dark mode and notifies listeners.
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }
}

