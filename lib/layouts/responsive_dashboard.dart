import 'package:flutter/material.dart';
import 'package:responsive_adaptive_ui/constants/colors.dart';
import 'package:responsive_adaptive_ui/layouts/desktop_layout.dart';
import 'package:responsive_adaptive_ui/layouts/mobile_layout.dart';
import 'package:responsive_adaptive_ui/layouts/tablet_layout.dart';
import 'package:responsive_adaptive_ui/widgets/adaptive_app_bar.dart';
import 'package:responsive_adaptive_ui/widgets/adaptive_nav_drawer.dart';

/// Breakpoints
const double kMobileBreakpoint = 600.0;
const double kTabletBreakpoint = 1050.0;

/// Responsive dashboard root widget using LayoutBuilder to switch layouts
class ResponsiveDashboard extends StatelessWidget {
  const ResponsiveDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= kTabletBreakpoint;
        final isTablet = constraints.maxWidth >= kMobileBreakpoint &&
            constraints.maxWidth < kTabletBreakpoint;

        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          appBar: AdaptiveAppBar(
            title: 'responsivedashboard',
            showDrawerButton: !isDesktop,
            showWindowControls: true,
          ),
          drawer: !isDesktop ? const AdaptiveNavDrawer() : null,
          body: isDesktop
              ? const DesktopLayout()
              : (isTablet ? const TabletLayout() : const MobileLayout()),
        );
      },
    );
  }
}
