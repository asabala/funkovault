import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_typography.dart';
import '../../atlas/atlas_glass_card.dart';

class VaultHealthCard extends StatelessWidget {
  const VaultHealthCard({
    required this.health,
    required this.message,
    super.key,
  });

  final double health;
  final String message;

  @override
  Widget build(BuildContext context) {
    final safeHealth = health.clamp(0.0, 100.0);

    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vault Health',
            style: AtlasTypography.headingSmall,
          ),
          const SizedBox(height: AtlasSpacing.md),
          Text(
            '${safeHealth.toStringAsFixed(0)}%',
            style: AtlasTypography.headingLarge.copyWith(
              color: AtlasColors.vaultGold,
            ),
          ),
          const SizedBox(height: AtlasSpacing.sm),
          LinearProgressIndicator(
            value: safeHealth / 100,
          ),
          const SizedBox(height: AtlasSpacing.md),
          Text(
            message,
            style: AtlasTypography.bodyMedium.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}