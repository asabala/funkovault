import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_motion.dart';
import '../../theme/atlas_spacing.dart';

class AtlasGlassCard extends StatefulWidget {
  const AtlasGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AtlasSpacing.lg),
    this.borderRadius = 28,
    this.accentColor,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? accentColor;
  final VoidCallback? onTap;

  @override
  State<AtlasGlassCard> createState() => _AtlasGlassCardState();
}

class _AtlasGlassCardState extends State<AtlasGlassCard> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (widget.onTap == null) return;

    setState(() {
      _isPressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final effectiveAccent = widget.accentColor ?? AtlasColors.vaultGold;

    return AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
      duration: AtlasMotion.pressDuration,
      curve: AtlasMotion.pressCurve,
      child: AnimatedContainer(
        duration: AtlasMotion.hoverDuration,
        curve: AtlasMotion.pressCurve,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: effectiveAccent.withValues(
                alpha: _isPressed ? 0.20 : 0.08,
              ),
              blurRadius: _isPressed ? 28 : 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: InkWell(
            onTap: widget.onTap,
            onHighlightChanged: _setPressed,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: effectiveAccent.withValues(
                    alpha: _isPressed ? 0.42 : 0.24,
                  ),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey.shade900,
                    AtlasColors.card,
                    Colors.black,
                  ],
                ),
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
