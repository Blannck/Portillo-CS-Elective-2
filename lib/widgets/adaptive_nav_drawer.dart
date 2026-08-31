import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_adaptive_ui/constants/colors.dart';
import 'package:responsive_adaptive_ui/models/platform_mode.dart';
import 'package:responsive_adaptive_ui/widgets/adaptive_dialog.dart';

class AdaptiveNavDrawer extends StatefulWidget {
  const AdaptiveNavDrawer({
    super.key,
    this.isPermanent = false,
    this.selectedIndex = 0,
    this.onDestinationSelected,
  });

  final bool isPermanent;
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;

  @override
  State<AdaptiveNavDrawer> createState() => _AdaptiveNavDrawerState();
}

class _AdaptiveNavDrawerState extends State<AdaptiveNavDrawer> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(AdaptiveNavDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _currentIndex = widget.selectedIndex;
    }
  }

  void _handleItemTap(int index, BuildContext context) {
    setState(() => _currentIndex = index);
    widget.onDestinationSelected?.call(index);

    if (!widget.isPermanent) {
      Navigator.of(context).pop();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      if (index == 1) {
        // SETTINGS
        showAdaptiveInfoDialog(
          context: context,
          title: 'Settings',
          content: 'Configure dashboard layout, theme, and responsive preferences.',
        );
      } else if (index == 2) {
        // ABOUT
        showAdaptiveInfoDialog(
          context: context,
          title: 'About Responsive Dashboard',
          content: 'A multi-platform responsive & adaptive UI demonstrating LayoutBuilder and platform widgets.',
        );
      } else if (index == 3) {
        // LOGOUT
        showAdaptiveConfirmDialog(
          context: context,
          title: 'Confirm Logout',
          content: 'Are you sure you want to log out of the dashboard session?',
          confirmText: 'Logout',
          isDestructive: true,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final platformScope = PlatformModeScope.of(context);
    final isCupertino = platformScope.isCupertino;
    final isWeb = platformScope.isWeb;

    final heartIcon = isCupertino
        ? CupertinoIcons.heart_fill
        : Icons.favorite;

    final homeIcon = isCupertino
        ? CupertinoIcons.house_fill
        : Icons.home;

    final settingsIcon = isCupertino
        ? CupertinoIcons.gear_alt_fill
        : Icons.settings;

    final aboutIcon = isCupertino
        ? CupertinoIcons.info_circle_fill
        : Icons.info;

    final logoutIcon = isCupertino
        ? CupertinoIcons.square_arrow_right
        : Icons.logout;

    final drawerContent = Container(
      color: AppColors.drawerBackground,
      child: SafeArea(
        top: !widget.isPermanent,
        bottom: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 36),
            // Centered Heart logo
            Center(
              child: Icon(
                heartIcon,
                size: 48,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 48),

            // Navigation items
            _DrawerMenuItem(
              icon: homeIcon,
              label: 'DASHBOARD',
              isSelected: _currentIndex == 0,
              isWeb: isWeb,
              onTap: () => _handleItemTap(0, context),
            ),
            const SizedBox(height: 8),
            _DrawerMenuItem(
              icon: settingsIcon,
              label: 'SETTINGS',
              isSelected: _currentIndex == 1,
              isWeb: isWeb,
              onTap: () => _handleItemTap(1, context),
            ),
            const SizedBox(height: 8),
            _DrawerMenuItem(
              icon: aboutIcon,
              label: 'ABOUT',
              isSelected: _currentIndex == 2,
              isWeb: isWeb,
              onTap: () => _handleItemTap(2, context),
            ),
            const SizedBox(height: 8),
            _DrawerMenuItem(
              icon: logoutIcon,
              label: 'LOGOUT',
              isSelected: _currentIndex == 3,
              isWeb: isWeb,
              onTap: () => _handleItemTap(3, context),
            ),

            const Spacer(),

            // Platform mode selector at bottom of drawer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
              child: _PlatformSelectorWidget(
                currentMode: platformScope.mode,
                onModeChanged: platformScope.onModeChanged,
                isCupertino: isCupertino,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (widget.isPermanent) {
      return SizedBox(
        width: 250,
        child: drawerContent,
      );
    }

    return Drawer(
      backgroundColor: AppColors.drawerBackground,
      elevation: isCupertino ? 0 : 4,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: drawerContent,
    );
  }
}

class _DrawerMenuItem extends StatefulWidget {
  const _DrawerMenuItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isWeb,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isWeb;
  final VoidCallback onTap;

  @override
  State<_DrawerMenuItem> createState() => _DrawerMenuItemState();
}

class _DrawerMenuItemState extends State<_DrawerMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final effectiveBg = widget.isSelected
        ? Colors.black.withValues(alpha: 0.08)
        : (_isHovered && widget.isWeb
            ? AppColors.drawerHover
            : Colors.transparent);

    return MouseRegion(
      cursor: widget.isWeb ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          splashColor: Colors.black12,
          highlightColor: Colors.black.withValues(alpha: 0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: effectiveBg,
              border: widget.isSelected
                  ? const Border(
                      left: BorderSide(color: Colors.black87, width: 3),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  size: 20,
                  color: widget.isSelected ? Colors.black : const Color(0xFF555555),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                      letterSpacing: 2.2,
                      color: widget.isSelected ? Colors.black : const Color(0xFF555555),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlatformSelectorWidget extends StatelessWidget {
  const _PlatformSelectorWidget({
    required this.currentMode,
    required this.onModeChanged,
    required this.isCupertino,
  });

  final PlatformMode currentMode;
  final ValueChanged<PlatformMode> onModeChanged;
  final bool isCupertino;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                isCupertino ? CupertinoIcons.device_phone_portrait : Icons.devices,
                size: 13,
                color: Colors.black54,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'PLATFORM ADAPTATION',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          DropdownButtonHideUnderline(
            child: DropdownButton<PlatformMode>(
              value: currentMode,
              isDense: true,
              isExpanded: true,
              style: const TextStyle(
                fontSize: 11.5,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              icon: Icon(
                isCupertino ? CupertinoIcons.chevron_down : Icons.arrow_drop_down,
                size: 16,
              ),
              items: PlatformMode.values.map((mode) {
                return DropdownMenuItem(
                  value: mode,
                  child: Text(
                    mode.label,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (newMode) {
                if (newMode != null) onModeChanged(newMode);
              },
            ),
          ),
        ],
      ),
    );
  }
}
