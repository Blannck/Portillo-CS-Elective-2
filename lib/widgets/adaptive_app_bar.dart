import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_adaptive_ui/constants/colors.dart';
import 'package:responsive_adaptive_ui/models/platform_mode.dart';

class AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AdaptiveAppBar({
    super.key,
    this.title = 'responsivedashboard',
    this.showDrawerButton = true,
    this.showWindowControls = true,
    this.onMenuPressed,
  });

  final String title;
  final bool showDrawerButton;
  final bool showWindowControls;
  final VoidCallback? onMenuPressed;

  @override
  Size get preferredSize => const Size.fromHeight(48.0);

  @override
  Widget build(BuildContext context) {
    final platformScope = PlatformModeScope.of(context);
    final isCupertino = platformScope.isCupertino;
    final isWeb = platformScope.isWeb;

    final menuIcon = isCupertino ? CupertinoIcons.bars : Icons.menu;

    return Container(
      height: preferredSize.height + MediaQuery.paddingOf(context).top,
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top,
        left: 12,
        right: 12,
      ),
      color: AppColors.appBarBackground,
      child: NavigationToolbar(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showWindowControls) ...[
              const _WindowDot(color: Color(0xFFFF5F56)), // Close (Red)
              const SizedBox(width: 6),
              const _WindowDot(color: Color(0xFFFFBD2E)), // Minimize (Yellow)
              const SizedBox(width: 6),
              const _WindowDot(color: Color(0xFF27C93F)), // Maximize (Green)
              const SizedBox(width: 12),
            ],
            if (showDrawerButton)
              Builder(
                builder: (scaffoldContext) {
                  return IconButton(
                    icon: Icon(menuIcon, color: Colors.white, size: 20),
                    tooltip: 'Open Navigation Drawer',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: () {
                      if (onMenuPressed != null) {
                        onMenuPressed!();
                      } else {
                        Scaffold.of(scaffoldContext).openDrawer();
                      }
                    },
                  );
                },
              ),
          ],
        ),
        middle: Text(
          title,
          style: const TextStyle(
            color: AppColors.appBarTitle,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        trailing: _PlatformBadgeMenu(
          currentMode: platformScope.mode,
          isCupertino: isCupertino,
          isWeb: isWeb,
          onSelected: platformScope.onModeChanged,
        ),
      ),
    );
  }
}

class _WindowDot extends StatelessWidget {
  const _WindowDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _PlatformBadgeMenu extends StatelessWidget {
  const _PlatformBadgeMenu({
    required this.currentMode,
    required this.isCupertino,
    required this.isWeb,
    required this.onSelected,
  });

  final PlatformMode currentMode;
  final bool isCupertino;
  final bool isWeb;
  final ValueChanged<PlatformMode> onSelected;

  @override
  Widget build(BuildContext context) {
    final modeShortName = switch (currentMode) {
      PlatformMode.auto => 'Auto',
      PlatformMode.material => 'Material',
      PlatformMode.cupertino => 'Cupertino',
      PlatformMode.web => 'Web',
    };

    return PopupMenuButton<PlatformMode>(
      tooltip: 'Switch Platform Adaptation Mode',
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      offset: const Offset(0, 32),
      onSelected: onSelected,
      itemBuilder: (context) => PlatformMode.values.map((mode) {
        final isSelected = mode == currentMode;
        return PopupMenuItem<PlatformMode>(
          value: mode,
          child: Row(
            children: [
              Icon(
                switch (mode) {
                  PlatformMode.auto => Icons.auto_mode,
                  PlatformMode.material => Icons.android,
                  PlatformMode.cupertino => CupertinoIcons.device_phone_portrait,
                  PlatformMode.web => Icons.web,
                },
                size: 16,
                color: isSelected ? Colors.blue : Colors.black87,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  mode.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.blue : Colors.black87,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check, size: 16, color: Colors.blue),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24, width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              switch (currentMode) {
                PlatformMode.auto => Icons.tune,
                PlatformMode.material => Icons.android,
                PlatformMode.cupertino => CupertinoIcons.device_phone_portrait,
                PlatformMode.web => Icons.mouse,
              },
              color: Colors.white70,
              size: 12,
            ),
            const SizedBox(width: 4),
            Text(
              modeShortName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.arrow_drop_down,
              color: Colors.white70,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
