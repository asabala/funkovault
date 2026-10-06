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
      padding: const EdgeInsets.all(AtlasSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: effectiveAccent),
          const SizedBox(height: AtlasSpacing.sm),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AtlasTypography.headingSmall,
          ),
          const SizedBox(height: AtlasSpacing.xs),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
