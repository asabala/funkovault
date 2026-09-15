import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_typography.dart';

enum AtlasStatusChipSize { compact, regular }

class AtlasStatusChip extends StatelessWidget {
  const AtlasStatusChip({
    super.key,
    required this.label,
    this.icon,
    this.symbol,
    this.accentColor = AtlasColors.intelligenceBlue,
    this.backgroundColor,
    this.textColor = AtlasColors.textPrimary,
    this.size = AtlasStatusChipSize.regular,
    this.onTap,
  }) : assert(
         icon == null || symbol == null,
         'Use either icon or symbol, not both.',
       );

  final String label;
  final IconData? icon;
  final String? symbol;

  final Color accentColor;
  final Color? backgroundColor;
  final Color textColor;

  final AtlasStatusChipSize size;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry padding = switch (size) {
      AtlasStatusChipSize.compact => const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      AtlasStatusChipSize.regular => const EdgeInsets.symmetric(
        horizontal: AtlasSpacing.sm,
        vertical: 7,
      ),
    };

    final double iconSize = size == AtlasStatusChipSize.compact ? 14 : 16;

    final double symbolSize = size == AtlasStatusChipSize.compact ? 13 : 15;

    final TextStyle textStyle = AtlasTypography.bodySmall.copyWith(
      color: textColor,
      fontWeight: FontWeight.w600,
    );

    final Widget chip = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? accentColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accentColor.withValues(alpha: 0.26)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (symbol != null) ...[
            Text(symbol!, style: TextStyle(fontSize: symbolSize)),
            const SizedBox(width: 5),
          ] else if (icon != null) ...[
            Icon(icon, size: iconSize, color: accentColor),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textStyle,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return chip;
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: chip,
      ),
    );
  }
}
