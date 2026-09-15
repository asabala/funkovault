import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../atlas/atlas_glass_card.dart';

class VaultRoomCard extends StatelessWidget {
  const VaultRoomCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.lastAdded,
    this.accentColor,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? lastAdded;
  final Color? accentColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final effectiveAccent = accentColor ?? AtlasColors.vaultGold;

    return AtlasGlassCard(
      onTap: onTap,
      accentColor: effectiveAccent,
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 34, color: effectiveAccent),

          const SizedBox(height: AtlasSpacing.md),

          Text(
            title,
            textAlign: TextAlign.center,
            style: AtlasTypography.headingSmall,
          ),

          const SizedBox(height: AtlasSpacing.xs),

          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),

          if (lastAdded != null) ...[
            const SizedBox(height: AtlasSpacing.md),

            Divider(color: Colors.white.withValues(alpha: 0.08)),

            const SizedBox(height: AtlasSpacing.xs),

            Text(
              'Last Added',
              style: AtlasTypography.bodySmall.copyWith(
                color: AtlasColors.textSecondary,
              ),
            ),

            const SizedBox(height: AtlasSpacing.xs),

            Text(
              lastAdded!,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AtlasTypography.bodySmall.copyWith(color: effectiveAccent),
            ),
          ],
        ],
      ),
    );
  }
}
