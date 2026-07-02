import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../atlas/core/atlas_intelligence.dart';
import '../atlas/repositories/vault_repository.dart';
import '../services/app_state.dart';
import '../theme/atlas_colors.dart';
import '../theme/atlas_icons.dart';
import '../theme/atlas_spacing.dart';
import '../theme/atlas_typography.dart';
import '../widgets/atlas/atlas_glass_card.dart';
import '../widgets/atlas/atlas_glass_panel.dart';
import '../widgets/atlas/atlas_stat_tile.dart';
import '../widgets/home/continue_journey_card.dart';
import 'profile/atlas_vault_profile_screen.dart';
import '../widgets/vault/atlas_mission_card.dart';
import '../widgets/vault/atlas_recommendation_card.dart';
import '../widgets/vault_scroll_view.dart';
import '../widgets/profile/atlas_identity_card.dart';

class AtlasHomeScreen extends StatelessWidget {
  const AtlasHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final profile = appState.collectorProfile;

    const repository = VaultRepository();
    const intelligence = AtlasIntelligence();

    final allPops = repository.allPops(appState);
    final totalValue = repository.totalValue(appState);

    final mission = intelligence.getTodayMission(allPops);
    final recommendation = intelligence.getRecommendation(allPops);
    final confidence = intelligence.getCollectorConfidence(allPops);
    final collectorType = intelligence.getCollectorType(allPops);
    final favoriteCategory = intelligence.getFavoriteCategory(allPops);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Atlas Home'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: AtlasSpacing.md),
            child: Icon(
              AtlasIcons.atlas,
              color: AtlasColors.vaultGold,
            ),
          ),
        ],
      ),
      body: VaultScrollView(
        children: [
          AtlasIdentityCard(
            profile: profile,
            onEdit: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AtlasVaultProfileScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: AtlasSpacing.lg),
          AtlasMissionCard(
            mission: mission,
            collectorType: collectorType,
            confidence: confidence.round(),
            onContinue: () {},
          ),
          const SizedBox(height: AtlasSpacing.lg),
          _HomeStatsCard(
            totalPops: allPops.length,
            totalValue: totalValue,
            confidence: confidence,
          ),
          const SizedBox(height: AtlasSpacing.lg),
          AtlasRecommendationCard(
            message: recommendation,
            confidence: confidence.round(),
            estimatedCost: favoriteCategory,
            difficulty: collectorType,
            onViewDetails: () {},
          ),
          const SizedBox(height: AtlasSpacing.lg),
          ContinueJourneyCard(
            title: 'Collector Vault',
            subtitle:
            'Continue organizing your collection and reviewing your Vault Rooms.',
            onContinue: () {},
          ),
          const SizedBox(height: AtlasSpacing.lg),
          _RecentActivityCard(
            hasActivity: appState.recentActivities.isNotEmpty,
            latestActivity: appState.recentActivities.isEmpty
                ? null
                : appState.recentActivities.first.details,
          ),
        ],
      ),
    );
  }
}

class _HomeStatsCard extends StatelessWidget {
  const _HomeStatsCard({
    required this.totalPops,
    required this.totalValue,
    required this.confidence,
  });

  final int totalPops;
  final double totalValue;
  final double confidence;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: AtlasGlassPanel(
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
                value: '${confidence.toStringAsFixed(0)}%',
                label: 'Confidence',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard({
    required this.hasActivity,
    required this.latestActivity,
  });

  final bool hasActivity;
  final String? latestActivity;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Latest Activity',
            style: AtlasTypography.headingSmall,
          ),
          const SizedBox(height: AtlasSpacing.md),
          AtlasGlassPanel(
            child: Text(
              hasActivity
                  ? latestActivity ?? 'Activity detected.'
                  : 'No recent activity yet. Add your first collectible to start building Atlas Memory.',
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