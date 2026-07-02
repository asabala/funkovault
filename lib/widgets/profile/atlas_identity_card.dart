import 'package:flutter/material.dart';
import 'banner/atlas_hero_banner.dart';
import 'avatar/atlas_avatar.dart';
import 'score/collector_score_badge.dart';

import '../atlas/atlas_glass_card.dart';
import '../../models/collector_profile.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_icons.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../atlas/engines/atlas_collector_score_engine.dart';


class AtlasIdentityCard extends StatelessWidget {
  const AtlasIdentityCard({
    required this.profile,
    this.totalPops = 0,
    this.collectionValue = 0,
    this.uniqueCategories = 0,
    this.onEdit,
    super.key,
  });

  final CollectorProfile profile;
  final int totalPops;
  final double collectionValue;
  final int uniqueCategories;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    const scoreEngine = AtlasCollectorScoreEngine();

    final score = scoreEngine.calculateScore(
      totalPops: totalPops,
      collectionValue: collectionValue,
      uniqueCategories: uniqueCategories,
    );

    final scoreTitle = scoreEngine.collectorTitleForScore(score);

    return AtlasGlassCard(
      child: Column(
        children: [
          AtlasHeroBanner(
            bannerUrl: profile.bannerUrl,
          ),
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
              _IdentityBadge(
                icon: Icons.fingerprint,
                label: profile.atlasId,
              ),
            ],
          ),
          const SizedBox(height: AtlasSpacing.lg),
          CollectorScoreBadge(
            score: score,
            title: scoreTitle,
          ),
          const SizedBox(height: AtlasSpacing.lg),
          Row(
            children: [
              const Expanded(
                child: _StatusPill(
                  icon: AtlasIcons.intelligence,
                  label: 'Intelligence',
                  value: 'Online',
                ),
              ),
              const SizedBox(width: AtlasSpacing.sm),
              const Expanded(
                child: _StatusPill(
                  icon: Icons.shield_outlined,
                  label: 'Vault',
                  value: 'Secure',
                ),
              ),
            ],
          ),
          const SizedBox(height: AtlasSpacing.sm),
          Row(
            children: [
              const Expanded(
                child: _StatusPill(
                  icon: Icons.cloud_done_outlined,
                  label: 'Sync',
                  value: 'Ready',
                ),
              ),
              const SizedBox(width: AtlasSpacing.sm),
              Expanded(
                child: _StatusPill(
                  icon: profile.isPremium
                      ? Icons.workspace_premium
                      : Icons.lock_open,
                  label: 'Membership',
                  value: profile.isPremium ? 'Premium' : 'Basic',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AtlasSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AtlasColors.vaultGold.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AtlasColors.vaultGold,
            size: 20,
          ),
          const SizedBox(height: AtlasSpacing.xs),
          Text(
            value,
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.vaultGold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
class _IdentityBadge extends StatelessWidget {
  const _IdentityBadge({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
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
          Icon(
            icon,
            color: AtlasColors.vaultGold,
            size: 15,
          ),
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