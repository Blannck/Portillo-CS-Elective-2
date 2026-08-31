import 'package:flutter/material.dart';
import 'package:responsive_adaptive_ui/constants/colors.dart';
import 'package:responsive_adaptive_ui/layouts/responsive_dashboard.dart';
import 'package:responsive_adaptive_ui/models/platform_mode.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ResponsiveAdaptiveApp());
}

class ResponsiveAdaptiveApp extends StatefulWidget {
  const ResponsiveAdaptiveApp({
    super.key,
    this.initialPlatformMode = PlatformMode.auto,
  });

  final PlatformMode initialPlatformMode;

  @override
  State<ResponsiveAdaptiveApp> createState() => _ResponsiveAdaptiveAppState();
}

class _ResponsiveAdaptiveAppState extends State<ResponsiveAdaptiveApp> {
  late PlatformMode _platformMode;

  @override
  void initState() {
    super.initState();
    _platformMode = widget.initialPlatformMode;
  }

  void _handlePlatformModeChanged(PlatformMode newMode) {
    setState(() {
      _platformMode = newMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    TargetPlatform effectivePlatform;
    switch (_platformMode) {
      case PlatformMode.cupertino:
        effectivePlatform = TargetPlatform.iOS;
      case PlatformMode.material:
        effectivePlatform = TargetPlatform.android;
      case PlatformMode.web:
        effectivePlatform = TargetPlatform.fuchsia;
      case PlatformMode.auto:
        effectivePlatform = Theme.of(context).platform;
    }

    return PlatformModeScope(
      mode: _platformMode,
      onModeChanged: _handlePlatformModeChanged,
      child: MaterialApp(
        title: 'Responsive & Adaptive Dashboard',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          platform: effectivePlatform,
          scaffoldBackgroundColor: AppColors.scaffoldBackground,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.grey,
            brightness: Brightness.light,
            surface: AppColors.scaffoldBackground,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.appBarBackground,
            foregroundColor: AppColors.appBarTitle,
            elevation: 0,
          ),
        ),
        home: const ResponsiveDashboard(),
      ),
    );
  }
}
