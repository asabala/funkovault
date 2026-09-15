import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';

class AtlasGlassPanel extends StatelessWidget {
  const AtlasGlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AtlasSpacing.md),
    this.borderRadius = 20,
    this.accentColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final effectiveAccent = accentColor ?? AtlasColors.vaultGold;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: effectiveAccent.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: effectiveAccent.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
