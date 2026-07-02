import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import 'atlas_glass_card.dart';

class AtlasActionTile extends StatelessWidget {
  const AtlasActionTile({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.accentColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? accentColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final effectiveAccent = accentColor ?? AtlasColors.vaultGold;

    return AtlasGlassCard(
      onTap: onTap,
      accentColor: effectiveAccent,
      borderRadius: 22,
      padding: const EdgeInsets.all(AtlasSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: effectiveAccent,
            size: 28,
          ),
          const SizedBox(height: AtlasSpacing.sm),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AtlasTypography.headingSmall,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AtlasSpacing.xs),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AtlasTypography.bodySmall.copyWith(
                color: AtlasColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}