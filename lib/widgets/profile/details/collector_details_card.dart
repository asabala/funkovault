import 'package:flutter/material.dart';

import '../../../models/collector_profile.dart';
import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_typography.dart';
import '../../atlas/atlas_glass_card.dart';
import '../../atlas/atlas_glass_panel.dart';

class CollectorDetailsCard extends StatelessWidget {
  const CollectorDetailsCard({
    required this.profile,
    super.key,
  });

  final CollectorProfile profile;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Collector Story',
            style: AtlasTypography.headingSmall,
          ),
          const SizedBox(height: AtlasSpacing.md),
          AtlasGlassPanel(
            child: Column(
              children: [
                _ProfileInfoRow(
                  icon: Icons.fingerprint,
                  label: 'Atlas ID',
                  value: profile.atlasId,
                ),
                const SizedBox(height: AtlasSpacing.md),
                _ProfileInfoRow(
                  icon: Icons.calendar_month_outlined,
                  label: 'Member Since',
                  value: profile.joinYear.toString(),
                ),
                const SizedBox(height: AtlasSpacing.md),
                _ProfileInfoRow(
                  icon: Icons.category_outlined,
                  label: 'Favorite Category',
                  value: profile.favoriteCategory,
                ),
                const SizedBox(height: AtlasSpacing.md),
                _ProfileInfoRow(
                  icon: Icons.auto_awesome_outlined,
                  label: 'Favorite Franchise',
                  value: profile.favoriteFranchise,
                ),
                const SizedBox(height: AtlasSpacing.md),
                _ProfileInfoRow(
                  icon: Icons.diamond_outlined,
                  label: 'Dream Grail',
                  value: profile.dreamGrail,
                ),
              ],
            ),
          ),
          const SizedBox(height: AtlasSpacing.md),
          AtlasGlassPanel(
            child: Text(
              profile.bio,
              style: AtlasTypography.bodyMedium.copyWith(
                color: AtlasColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AtlasColors.vaultGold,
          size: 22,
        ),
        const SizedBox(width: AtlasSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AtlasTypography.bodySmall.copyWith(
                  color: AtlasColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? 'Not set yet' : value,
                style: AtlasTypography.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}