import 'package:flutter/material.dart';
import 'package:responsive_adaptive_ui/constants/colors.dart';
import 'package:responsive_adaptive_ui/models/platform_mode.dart';
import 'package:responsive_adaptive_ui/widgets/adaptive_card.dart';

/// Tablet / iPad layout: 1x4 grid (4 cards in a row) on top, vertical list of cards below
class TabletLayout extends StatelessWidget {
  const TabletLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final isCupertino = PlatformModeScope.of(context).isCupertino;
    final scrollPhysics = isCupertino
        ? const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics())
        : const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

    return ListView(
      physics: scrollPhysics,
      padding: const EdgeInsets.all(16.0),
      children: [
        // 1x4 Grid of square grey cards
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
    );
  }
}
