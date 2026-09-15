import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_typography.dart';
import '../atlas_glass_panel.dart';

class AtlasActionRow extends StatelessWidget {
  const AtlasActionRow({
    super.key,
    required this.title,
    required this.description,
    this.icon,
    this.symbol,
    this.badge,
    this.accentColor = AtlasColors.intelligenceBlue,
    this.onTap,
    this.showChevron = true,
    this.compact = false,
  }) : assert(
         icon == null || symbol == null,
         'Use either icon or symbol, not both.',
       );

  final String title;
  final String description;

  final IconData? icon;
  final String? symbol;

  final Widget? badge;

  final Color accentColor;
  final VoidCallback? onTap;

  final bool showChevron;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final Widget content = AtlasGlassPanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ActionIdentity(
            icon: icon,
            symbol: symbol,
            accentColor: accentColor,
            compact: compact,
          ),
          SizedBox(width: compact ? AtlasSpacing.sm : AtlasSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AtlasTypography.bodyMedium.copyWith(
                          color: AtlasColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: AtlasSpacing.sm),
                      badge!,
                    ],
                  ],
                ),
                const SizedBox(height: AtlasSpacing.xs),
                Text(
                  description,
                  maxLines: compact ? 2 : null,
                  overflow: compact
                      ? TextOverflow.ellipsis
                      : TextOverflow.visible,
                  style: AtlasTypography.bodySmall.copyWith(
                    color: AtlasColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (showChevron && onTap != null) ...[
            const SizedBox(width: AtlasSpacing.sm),
            Padding(
              padding: EdgeInsets.only(top: compact ? 4 : 7),
              child: Icon(Icons.chevron_right_rounded, color: accentColor),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: content,
      ),
    );
  }
}

class _ActionIdentity extends StatelessWidget {
  const _ActionIdentity({
    required this.icon,
    required this.symbol,
    required this.accentColor,
    required this.compact,
  });

  final IconData? icon;
  final String? symbol;
  final Color accentColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double size = compact ? 38 : 42;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(compact ? 12 : 14),
        border: Border.all(color: accentColor.withValues(alpha: 0.22)),
      ),
      child: symbol != null
          ? Text(symbol!, style: TextStyle(fontSize: compact ? 17 : 19))
          : Icon(
              icon ?? Icons.arrow_forward_rounded,
              color: accentColor,
              size: compact ? 20 : 22,
            ),
    );
  }
}
