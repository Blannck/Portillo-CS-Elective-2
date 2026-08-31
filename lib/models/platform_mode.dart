import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Supported platform presentation modes
enum PlatformMode {
  auto('Auto (System)'),
  material('Material (Android)'),
  cupertino('Cupertino (iOS)'),
  web('Web (Desktop/Browser)');

  const PlatformMode(this.label);
  final String label;
}

/// InheritedWidget to provide the current platform mode down the widget tree
class PlatformModeScope extends InheritedWidget {
  const PlatformModeScope({
    super.key,
    required this.mode,
    required this.onModeChanged,
    required super.child,
  });

  final PlatformMode mode;
  final ValueChanged<PlatformMode> onModeChanged;

  static PlatformModeScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PlatformModeScope>();
    assert(scope != null, 'No PlatformModeScope found in context');
    return scope!;
  }

  /// Whether current active configuration is Cupertino (iOS) style
  bool get isCupertino {
    if (mode == PlatformMode.cupertino) return true;
    if (mode == PlatformMode.material || mode == PlatformMode.web) return false;
    // Auto mode
    return !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS);
  }

  /// Whether current active configuration is Material style
  bool get isMaterial {
    if (mode == PlatformMode.material) return true;
    if (mode == PlatformMode.cupertino) return false;
    if (mode == PlatformMode.web) return true;
    // Auto mode
    return !isCupertino;
  }

  /// Whether current mode enables web-specific interactions (hover states, custom cursors)
  bool get isWeb {
    if (mode == PlatformMode.web) return true;
    if (mode == PlatformMode.auto) return kIsWeb;
    return false;
  }

  @override
  bool updateShouldNotify(PlatformModeScope oldWidget) {
    return mode != oldWidget.mode;
  }
}
