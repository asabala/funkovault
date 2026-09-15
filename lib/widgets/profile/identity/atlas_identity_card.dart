import 'package:flutter/material.dart';
import '../banner/atlas_hero_banner.dart';
import '../avatar/atlas_avatar.dart';

import '../../atlas/atlas_glass_card.dart';
import '../../../models/collector_profile.dart';
import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_typography.dart';

class AtlasIdentityCard extends StatelessWidget {
  const AtlasIdentityCard({required this.profile, this.onEdit, super.key});

  final CollectorProfile profile;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Column(
        children: [
          AtlasHeroBanner(bannerUrl: profile.bannerUrl),
          const SizedBox(height: AtlasSpacing.lg),
          AtlasAvatar(
            displayName: profile.displayName,
            avatarUrl: profile.avatarUrl,
          ),
          const SizedBox(height: AtlasSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  profile.displayName,
                  style: AtlasTypography.headingLarge,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onEdit != null) ...[
                const SizedBox(width: AtlasSpacing.xs),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  color: AtlasColors.vaultGold,
                  tooltip: 'Edit Vault Profile',
                ),
              ],
            ],
          ),
          const SizedBox(height: AtlasSpacing.xs),
          Text(
            profile.collectorTitle,
            style: AtlasTypography.bodyMedium.copyWith(
              color: AtlasColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AtlasSpacing.sm),
          Text(
            profile.collectorMotto,
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.vaultGold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AtlasSpacing.lg),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AtlasSpacing.sm,
            runSpacing: AtlasSpacing.sm,
            children: [
              _IdentityBadge(
                icon: Icons.military_tech_outlined,
                label: profile.collectorLevel,
              ),
              _IdentityBadge(
                icon: Icons.public,
                label: '${profile.countryFlag} ${profile.country}',
              ),
              _IdentityBadge(icon: Icons.fingerprint, label: profile.atlasId),
            ],
          ),
          const SizedBox(height: AtlasSpacing.lg),
        ],
      ),
    );
  }
}

class _IdentityBadge extends StatelessWidget {
  const _IdentityBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AtlasColors.vaultGold.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AtlasColors.vaultGold, size: 15),
          const SizedBox(width: 6),
          Text(
            label,
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.vaultGold,
            ),
          ),
        ],
      ),
    );
  }
}
