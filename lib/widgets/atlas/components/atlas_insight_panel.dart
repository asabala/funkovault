import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_typography.dart';

enum AtlasInsightPanelTone {
  intelligence,
  recommendation,
  success,
  warning,
  danger,
  neutral,
}

class AtlasInsightPanel extends StatelessWidget {
  const AtlasInsightPanel({
    super.key,
    required this.title,
    required this.message,
    this.eyebrow,
    this.icon,
    this.symbol,
    this.tone = AtlasInsightPanelTone.intelligence,
    this.badge,
    this.trailing,
    this.onTap,
    this.maxMessageLines,
  }) : assert(
         icon == null || symbol == null,
         'Use either icon or symbol, not both.',
       );

  final String title;
  final String message;
  final String? eyebrow;

  final IconData? icon;
  final String? symbol;

  final AtlasInsightPanelTone tone;

  final Widget? badge;
  final Widget? trailing;

  final VoidCallback? onTap;

  final int? maxMessageLines;

  @override
  Widget build(BuildContext context) {
    final Color accentColor = _accentColorForTone(tone);

    final Widget content = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AtlasSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: accentColor.withValues(alpha: 0.08),
        border: Border.all(color: accentColor.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InsightIdentity(
            icon: icon,
            symbol: symbol,
            accentColor: accentColor,
          ),
          const SizedBox(width: AtlasSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow?.trim().isNotEmpty == true) ...[
                  Text(
                    eyebrow!.trim().toUpperCase(),
                    style: AtlasTypography.bodySmall.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: AtlasSpacing.xs),
                ],
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
                  message,
                  maxLines: maxMessageLines,
                  overflow: maxMessageLines == null
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                  style: AtlasTypography.bodySmall.copyWith(
                    color: AtlasColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AtlasSpacing.sm),
            trailing!,
          ] else if (onTap != null) ...[
            const SizedBox(width: AtlasSpacing.sm),
            Icon(Icons.chevron_right_rounded, color: accentColor),
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

  Color _accentColorForTone(AtlasInsightPanelTone tone) {
    return switch (tone) {
      AtlasInsightPanelTone.intelligence => AtlasColors.intelligenceBlue,
      AtlasInsightPanelTone.recommendation => AtlasColors.vaultGold,
      AtlasInsightPanelTone.success => AtlasColors.success,
      AtlasInsightPanelTone.warning => AtlasColors.warning,
      AtlasInsightPanelTone.danger => AtlasColors.danger,
      AtlasInsightPanelTone.neutral => AtlasColors.textSecondary,
    };
  }
}

class _InsightIdentity extends StatelessWidget {
  const _InsightIdentity({
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
          : Icon(
              icon ?? Icons.auto_awesome_rounded,
              color: accentColor,
              size: 22,
            ),
    );
  }
}
