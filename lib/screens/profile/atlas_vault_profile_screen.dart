import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../atlas/engines/atlas_achievement_engine.dart';
import '../../atlas/engines/atlas_collector_dna_engine.dart';
import '../../atlas/engines/atlas_confidence_engine.dart';
import '../../atlas/engines/atlas_memory_engine.dart';
import '../../services/app_state.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/atlas_glass_panel.dart';
import '../../widgets/profile/achievements/achievement_preview_card.dart';
import '../../widgets/profile/atlas_identity_card.dart';
import '../../widgets/profile/confidence/atlas_confidence_card.dart';
import '../../widgets/profile/dna/collector_dna_card.dart';
import '../../widgets/profile/health/vault_health_card.dart';
import '../../widgets/profile/memory/memory_preview_card.dart';
import '../../widgets/profile/stats/profile_stat_tile.dart';
import '../../widgets/profile/stats/profile_stats_row.dart';
import '../../widgets/vault_scroll_view.dart';
import '../edit_collector_profile_screen.dart';
import '../../models/collector_profile.dart';

class AtlasVaultProfileScreen extends StatelessWidget {
  const AtlasVaultProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final profile = appState.collectorProfile;
    final pops = appState.selectedCollectionPops;

    const dnaEngine = AtlasCollectorDNAEngine();
    const confidenceEngine = AtlasConfidenceEngine();
    const achievementEngine = AtlasAchievementEngine();
    const memoryEngine = AtlasMemoryEngine();

    final totalPops = pops.length;
    final totalValue = pops.fold<double>(
      0,
          (total, pop) => total + pop.value,
    );

    final uniqueCategories = pops
        .map((pop) => pop.category.trim())
        .where((category) => category.isNotEmpty)
        .toSet()
        .length;

    final wishlistCount = pops.where((pop) => pop.isWishlist).length;
    final grailCount = pops.where((pop) => pop.value >= 100).length;
    final missingValues = pops.where((pop) => pop.value <= 0).length;

    final duplicateMap = <String, int>{};

    for (final pop in pops) {
      final key = pop.collectorIdentity;
      duplicateMap[key] = (duplicateMap[key] ?? 0) + 1;
    }

    final duplicateGroups =
        duplicateMap.values.where((count) => count > 1).length;

    final vaultHealth = totalPops == 0
        ? 100.0
        : (100 - (((duplicateGroups + missingValues) / totalPops) * 100))
        .clamp(0.0, 100.0);

    final dna = dnaEngine.analyze(pops);
    final confidence = confidenceEngine.calculate(pops);
    final achievements = achievementEngine.evaluate(pops);
    final memory = memoryEngine.remember(pops: pops);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Atlas Vault Profile'),
      ),
      body: VaultScrollView(
        children: [
          AtlasIdentityCard(
            profile: profile,
            totalPops: totalPops,
            collectionValue: totalValue,
            uniqueCategories: uniqueCategories,
            onEdit: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditCollectorProfileScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: AtlasSpacing.lg),
          ProfileStatsRow(
            children: [
              ProfileStatTile(
                icon: Icons.inventory_2_outlined,
                value: '$totalPops',
                label: 'Pops',
              ),
              ProfileStatTile(
                icon: Icons.attach_money,
                value: '\$${totalValue.toStringAsFixed(0)}',
                label: 'Value',
              ),
            ],
          ),
          const SizedBox(height: AtlasSpacing.sm),
          ProfileStatsRow(
            children: [
              ProfileStatTile(
                icon: Icons.diamond_outlined,
                value: '$grailCount',
                label: 'Grails',
              ),
              ProfileStatTile(
                icon: Icons.favorite_outline,
                value: '$wishlistCount',
                label: 'Wishlist',
              ),
            ],
          ),
          const SizedBox(height: AtlasSpacing.lg),
          CollectorDnaCard(
            primaryTrait: dna.primaryTrait,
            secondaryTrait: dna.secondaryTrait,
            confidence: dna.confidence,
            summary: dna.summary,
          ),
          const SizedBox(height: AtlasSpacing.lg),
          VaultHealthCard(
            health: vaultHealth,
            message: vaultHealth >= 90
                ? 'Your Vault is in excellent shape.'
                : 'Review duplicates and missing values to improve Vault Health.',
          ),
          const SizedBox(height: AtlasSpacing.lg),
          AtlasConfidenceCard(
            confidence: confidence.score,
            message: confidence.message,
          ),
          const SizedBox(height: AtlasSpacing.lg),
          AchievementPreviewCard(
            achievements: achievements,
          ),
          const SizedBox(height: AtlasSpacing.lg),
          MemoryPreviewCard(
            title: memory.title,
            message: memory.message,
            footer: memory.footer,
          ),
          const SizedBox(height: AtlasSpacing.lg),
          _CollectorDetailsCard(
            profile: profile,
          ),
          const SizedBox(height: AtlasSpacing.lg),
          FilledButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditCollectorProfileScreen(),
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Customize Vault Profile'),
          ),
        ],
      ),
    );
  }
}

class _CollectorDetailsCard extends StatelessWidget {
  const _CollectorDetailsCard({
    required this.profile,
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