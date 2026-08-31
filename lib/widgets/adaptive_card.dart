import 'package:flutter/material.dart';
import 'package:responsive_adaptive_ui/models/platform_mode.dart';

/// Wireframe card widget that adapts to web hover states and platform styling
class AdaptiveCard extends StatefulWidget {
  const AdaptiveCard({
    super.key,
    required this.color,
    this.height,
    this.width,
    this.borderRadius = 8.0,
    this.child,
    this.onTap,
  });

  final Color color;
  final double? height;
  final double? width;
  final double borderRadius;
  final Widget? child;
  final VoidCallback? onTap;

  @override
  State<AdaptiveCard> createState() => _AdaptiveCardState();
}

class _AdaptiveCardState extends State<AdaptiveCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isWeb = PlatformModeScope.of(context).isWeb;
    final isCupertino = PlatformModeScope.of(context).isCupertino;

    final radius = BorderRadius.circular(widget.borderRadius);

    Widget cardContent = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: widget.width,
      height: widget.height,
      transform: _isHovered && isWeb
          ? Matrix4.translationValues(0.0, -2.0, 0.0)
          : Matrix4.identity(),
      decoration: BoxDecoration(
        color: _isHovered && isWeb ? widget.color.withValues(alpha: 0.9) : widget.color,
        borderRadius: radius,
        boxShadow: _isHovered && isWeb
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : (isCupertino
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ]),
      ),
      child: widget.child,
    );

    if (widget.onTap != null || isWeb) {
      cardContent = MouseRegion(
        cursor: isWeb ? SystemMouseCursors.click : MouseCursor.defer,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
