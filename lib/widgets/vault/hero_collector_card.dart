import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../atlas/atlas_glass_card.dart';
import '../atlas/atlas_glass_panel.dart';
import '../atlas/atlas_stat_tile.dart';

class HeroCollectorCard extends StatelessWidget {
  const HeroCollectorCard({
    super.key,
    required this.collectorName,
    required this.collectorTitle,
    required this.collectorBio,
    required this.favoriteCategory,
    required this.collectorLevel,
    required this.isPremium,
    required this.totalPops,
    required this.totalValue,
    required this.health,
    this.onEditProfile,
  });

  final String collectorName;
  final String collectorTitle;
  final String collectorBio;
  final String favoriteCategory;
  final String collectorLevel;
  final bool isPremium;
  final int totalPops;
  final double totalValue;
  final double health;
  final VoidCallback? onEditProfile;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 30,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HeroBanner(),

            Padding(
              padding: const EdgeInsets.all(AtlasSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform.translate(
                    offset: const Offset(0, -46),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const _CollectorAvatar(),
                        const SizedBox(width: AtlasSpacing.md),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  collectorName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AtlasTypography.headingLarge,
                                ),
                                const SizedBox(height: AtlasSpacing.xs),
                                Text(
                                  collectorTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AtlasTypography.bodySmall.copyWith(
                                    color: AtlasColors.vaultGold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Icon(
                            Icons.verified,
                            color: AtlasColors.vaultGold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Transform.translate(
                    offset: const Offset(0, -24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: AtlasSpacing.sm,
                          runSpacing: AtlasSpacing.sm,
                          children: [
                            const _HeroBadge(
                              icon: Icons.shield,
                              label: 'Atlas Core • Online',
                            ),
                            _HeroBadge(
                              icon: isPremium
                                  ? Icons.workspace_premium
                                  : Icons.lock_open,
                              label: isPremium ? 'Premium' : 'Basic',
                            ),
                          ],
                        ),

                        const SizedBox(height: AtlasSpacing.md),

                        Text(
                          collectorBio,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: AtlasTypography.bodySmall.copyWith(
                            color: AtlasColors.textSecondary,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: AtlasSpacing.md),

                        Wrap(
                          spacing: AtlasSpacing.sm,
                          runSpacing: AtlasSpacing.sm,
                          children: [
                            _HeroBadge(
                              icon: Icons.military_tech,
                              label: collectorLevel,
                            ),
                            _HeroBadge(
                              icon: Icons.category,
                              label: favoriteCategory,
                            ),
                          ],
                        ),

                        const SizedBox(height: AtlasSpacing.lg),

                        FilledButton.icon(
                          onPressed: onEditProfile,
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Profile'),
                        ),

                        const SizedBox(height: AtlasSpacing.lg),

                        AtlasGlassPanel(
                          child: Row(
                            children: [
                              Expanded(
                                child: AtlasStatTile(
                                  icon: Icons.inventory_2_outlined,
                                  value: '$totalPops',
                                  label: 'Pops',
                                ),
                              ),
                              Expanded(
                                child: AtlasStatTile(
                                  icon: Icons.attach_money,
                                  value: '\$${totalValue.toStringAsFixed(0)}',
                                  label: 'Value',
                                ),
                              ),
                              Expanded(
                                child: AtlasStatTile(
                                  icon: Icons.health_and_safety_outlined,
                                  value: '${health.toStringAsFixed(0)}%',
                                  label: 'Health',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade800,
            Colors.grey.shade900,
            Colors.black,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.18),
            ),
          ),
          Positioned(
            right: 18,
            top: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.36),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: AtlasColors.vaultGold.withValues(alpha: 0.22),
                ),
              ),
              child: Text(
                'Vault Identity',
                style: AtlasTypography.bodySmall.copyWith(
                  color: AtlasColors.vaultGold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectorAvatar extends StatelessWidget {
  const _CollectorAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade900,
        border: Border.all(
          color: AtlasColors.vaultGold.withValues(alpha: 0.55),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.person,
        size: 44,
        color: AtlasColors.vaultGold,
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({
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
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .35),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AtlasColors.vaultGold.withValues(alpha: .25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AtlasColors.vaultGold,
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