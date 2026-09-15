import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_typography.dart';

class AtlasSectionHeader extends StatelessWidget {
  const AtlasSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.symbol,
    this.badge,
    this.trailing,
    this.titleStyle,
    this.accentColor = AtlasColors.vaultGold,
    this.showDivider = false,
  }) : assert(
         icon == null || symbol == null,
         'Use either icon or symbol, not both.',
       );

  final String title;
  final String? subtitle;

  final IconData? icon;
  final String? symbol;

  final Widget? badge;
  final Widget? trailing;

  final TextStyle? titleStyle;

  final Color accentColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final String cleanedSubtitle = subtitle?.trim() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null || symbol != null) ...[
              _SectionIdentity(
                icon: icon,
                symbol: symbol,
                accentColor: accentColor,
              ),
              const SizedBox(width: AtlasSpacing.md),
            ],
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              titleStyle ??
                              AtlasTypography.headingSmall.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      if (trailing != null) ...[
                        const SizedBox(width: AtlasSpacing.sm),
                        trailing!,
                      ],
                    ],
                  ),
                  if (cleanedSubtitle.isNotEmpty) ...[
                    const SizedBox(height: AtlasSpacing.xs),
                    Text(
                      cleanedSubtitle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AtlasTypography.bodySmall.copyWith(
                        color: AtlasColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                  if (badge != null) ...[
                    const SizedBox(height: AtlasSpacing.sm),
                    Align(alignment: Alignment.centerLeft, child: badge!),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (showDivider) ...[
          const SizedBox(height: AtlasSpacing.md),
          const Divider(height: 1, color: AtlasColors.divider),
        ],
      ],
    );
  }
}

class _SectionIdentity extends StatelessWidget {
  const _SectionIdentity({
    required this.icon,
    required this.symbol,
    required this.accentColor,
  });

  final IconData? icon;
  final String? symbol;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.24)),
      ),
      child: symbol != null
          ? Text(symbol!, style: const TextStyle(fontSize: 19))
          : Icon(icon, color: accentColor, size: 22),
    );
  }
}
