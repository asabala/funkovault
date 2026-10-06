import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_typography.dart';

enum AtlasChipSize { compact, regular }

class AtlasChip extends StatelessWidget {
  const AtlasChip({
    super.key,
    required this.label,
    this.icon,
    this.accentColor = AtlasColors.vaultGold,
    this.size = AtlasChipSize.regular,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final Color accentColor;
  final AtlasChipSize size;
  final VoidCallback? onTap;

  double get _verticalPadding {
    switch (size) {
      case AtlasChipSize.compact:
        return 3;
      case AtlasChipSize.regular:
        return 5;
    }
  }

  double get _iconSize {
    switch (size) {
      case AtlasChipSize.compact:
        return 14;
      case AtlasChipSize.regular:
        return 15;
    }
  }

  TextStyle get _textStyle {
    switch (size) {
      case AtlasChipSize.compact:
        return AtlasTypography.bodySmall.copyWith(
          color: accentColor,
          fontWeight: FontWeight.bold,
        );

      case AtlasChipSize.regular:
        return AtlasTypography.bodySmall.copyWith(
          color: accentColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: EdgeInsets.symmetric(
        horizontal: AtlasSpacing.sm,
        vertical: _verticalPadding,
      ),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accentColor.withValues(alpha: 0.36)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: accentColor, size: _iconSize),
            const SizedBox(width: AtlasSpacing.xs),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: _textStyle,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return chip;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: chip,
    );
  }
}
