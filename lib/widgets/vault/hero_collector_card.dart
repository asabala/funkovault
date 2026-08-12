import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../atlas/atlas_glass_card.dart';
import '../atlas/atlas_glass_panel.dart';
import '../atlas/atlas_stat_tile.dart';
import '../atlas/components/atlas_status_chip.dart';

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
              padding: const EdgeInsets.all(
                AtlasSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform.translate(
                    offset: const Offset(0, -46),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const _CollectorAvatar(),
                        const SizedBox(
                          width: AtlasSpacing.md,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              bottom: 6,
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  collectorName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AtlasTypography.headingLarge,
                                ),
                                const SizedBox(
                                  height: AtlasSpacing.xs,
                                ),
                                Text(
                                  collectorTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                  AtlasTypography.bodySmall.copyWith(
                                    color: AtlasColors.vaultGold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(
                            bottom: 8,
                          ),
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
                            const AtlasStatusChip(
                              label: 'Atlas Core • Online',
                              icon: Icons.shield,
                              accentColor: AtlasColors.vaultGold,
                              size: AtlasStatusChipSize.compact,
                            ),
                            AtlasStatusChip(
                              label: isPremium ? 'Premium' : 'Basic',
                              icon: isPremium
                                  ? Icons.workspace_premium_rounded
                                  : Icons.lock_open_rounded,
                              accentColor: AtlasColors.vaultGold,
                              size: AtlasStatusChipSize.compact,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: AtlasSpacing.md,
                        ),
                        Text(
                          collectorBio,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: AtlasTypography.bodySmall.copyWith(
                            color: AtlasColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(
                          height: AtlasSpacing.md,
                        ),
                        Wrap(
                          spacing: AtlasSpacing.sm,
                          runSpacing: AtlasSpacing.sm,
                          children: [
                            AtlasStatusChip(
                              label: collectorLevel,
                              icon: Icons.military_tech_rounded,
                              accentColor: AtlasColors.vaultGold,
                              size: AtlasStatusChipSize.compact,
                            ),
                            AtlasStatusChip(
                              label: favoriteCategory,
                              icon: Icons.category_rounded,
                              accentColor: AtlasColors.vaultGold,
                              size: AtlasStatusChipSize.compact,
                            ),
                          ],
                        ),
                        if (onEditProfile != null) ...[
                          const SizedBox(
                            height: AtlasSpacing.lg,
                          ),
                          FilledButton.icon(
                            onPressed: onEditProfile,
                            icon: const Icon(
                              Icons.edit_rounded,
                            ),
                            label: const Text(
                              'Edit Profile',
                            ),
                          ),
                        ],
                        const SizedBox(
                          height: AtlasSpacing.lg,
                        ),
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
                                  icon: Icons.attach_money_rounded,
                                  value:
                                  '\$${totalValue.toStringAsFixed(0)}',
                                  label: 'Value',
                                ),
                              ),
                              Expanded(
                                child: AtlasStatTile(
                                  icon:
                                  Icons.health_and_safety_outlined,
                                  value:
                                  '${health.toStringAsFixed(0)}%',
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
              color: Colors.black.withValues(
                alpha: 0.18,
              ),
            ),
          ),
          Positioned(
            right: 18,
            top: 18,
            child: AtlasStatusChip(
              label: 'Vault Identity',
              icon: Icons.badge_outlined,
              accentColor: AtlasColors.vaultGold,
              size: AtlasStatusChipSize.compact,
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
          color: AtlasColors.vaultGold.withValues(
            alpha: 0.55,
          ),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.45,
            ),
            blurRadius: 18,
            offset: const Offset(
              0,
              8,
            ),
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