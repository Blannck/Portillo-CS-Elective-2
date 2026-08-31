import 'package:flutter/material.dart';
import 'package:responsive_adaptive_ui/constants/colors.dart';
import 'package:responsive_adaptive_ui/models/platform_mode.dart';
import 'package:responsive_adaptive_ui/widgets/adaptive_card.dart';
import 'package:responsive_adaptive_ui/widgets/adaptive_nav_drawer.dart';

/// Desktop layout: 3-column split view (Left Drawer + Center Grid/List + Right Side Cards)
class DesktopLayout extends StatelessWidget {
  const DesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final isCupertino = PlatformModeScope.of(context).isCupertino;
    final scrollPhysics = isCupertino
        ? const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics())
        : const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Permanent Navigation Drawer
        const AdaptiveNavDrawer(isPermanent: true),

        // Center Column: Main Content (4 square cards + vertical list)
        Expanded(
          flex: 5,
          child: ListView(
            physics: scrollPhysics,
            padding: const EdgeInsets.all(16.0),
            children: [
              // Top 1x4 Grid of square grey cards
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1.0,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return const AdaptiveCard(
                    color: AppColors.primaryCard,
                    borderRadius: 10.0,
                  );
                },
              ),
              const SizedBox(height: 16.0),

              // Vertical list of light grey horizontal cards
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                separatorBuilder: (context, index) => const SizedBox(height: 14.0),
                itemBuilder: (context, index) {
                  return const AdaptiveCard(
                    height: 68.0,
                    color: AppColors.secondaryCard,
                    borderRadius: 10.0,
                  );
                },
              ),
            ],
          ),
        ),

        // Right Column: Stacked 2 large cards
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 16.0, bottom: 16.0),
            child: LayoutBuilder(
              builder: (context, rightConstraints) {
                return ListView(
                  physics: scrollPhysics,
                  children: [
                    // Top large grey card
                    AdaptiveCard(
                      height: 320.0,
                      color: AppColors.primaryCard,
                      borderRadius: 10.0,
                    ),
                    const SizedBox(height: 16.0),

                    // Bottom light grey card
                    AdaptiveCard(
                      height: 200.0,
                      color: AppColors.secondaryCard,
                      borderRadius: 10.0,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
