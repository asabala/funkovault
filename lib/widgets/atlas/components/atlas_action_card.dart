import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_typography.dart';
import '../atlas_glass_card.dart';

class AtlasActionCard extends StatelessWidget {
  const AtlasActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.highlight,
    this.accentColor = AtlasColors.vaultGold,
    this.onTap,
    this.trailing,
    this.showNavigationChevron = true,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? highlight;
  final Color accentColor;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showNavigationChevron;

  bool get _hasHighlight {
    return highlight != null && highlight!.trim().isNotEmpty;
  }

  bool get _isTappable {
    return onTap != null;
  }

  @override
  Widget build(BuildContext context) {
    final content = AtlasGlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accentColor),
          ),
          const SizedBox(width: AtlasSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AtlasTypography.bodyMedium.copyWith(
                    color: AtlasColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_hasHighlight) ...[
                  const SizedBox(height: AtlasSpacing.xs),
                  Text(
                    highlight!,
                    style: AtlasTypography.bodySmall.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const SizedBox(height: 3),
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AtlasTypography.bodySmall.copyWith(
                    color: AtlasColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AtlasSpacing.sm),
            trailing!,
          ] else if (_isTappable && showNavigationChevron) ...[
            const SizedBox(width: AtlasSpacing.sm),
            Icon(Icons.chevron_right_rounded, color: accentColor),
          ],
        ],
      ),
    );

    if (!_isTappable) {
      return content;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: content,
    );
  }
}
