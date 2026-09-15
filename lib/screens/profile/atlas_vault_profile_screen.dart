import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../atlas/coordinator/atlas_dashboard.dart';
import '../../atlas/coordinator/atlas_dashboard_model.dart';
import '../../security/auth_provider.dart';
import '../../services/app_state.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/profile/achievements/achievement_preview_card.dart';
import '../../widgets/profile/confidence/atlas_confidence_card.dart';
import '../../widgets/profile/details/collector_details_card.dart';
import '../../widgets/profile/dna/collector_dna_card.dart';
import '../../widgets/profile/health/vault_health_card.dart';
import '../../widgets/profile/identity/atlas_identity_card.dart';
import '../../widgets/profile/memory/memory_preview_card.dart';
import '../../widgets/profile/score/collector_score_card.dart';
import '../../widgets/profile/stats/profile_stats_card.dart';
import '../../widgets/profile/status/vault_status_card.dart';
import '../../widgets/vault/vault_scroll_view.dart';
import 'edit_collector_profile_screen.dart';

class AtlasVaultProfileScreen extends StatelessWidget {
  const AtlasVaultProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final authProvider = context.watch<AuthProvider>();

    final profile = appState.collectorProfile;
    final authState = authProvider.controller.state;

    const dashboardBuilder = AtlasDashboard();

    final AtlasDashboardModel dashboard = dashboardBuilder.build(appState);

    return Scaffold(
      appBar: AppBar(title: const Text('Atlas Vault Profile')),
      body: VaultScrollView(
        children: [
          AtlasIdentityCard(
            profile: profile,
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
          _AccountIdentityCard(
            isLoggedIn: authProvider.isLoggedIn,
            email: authState.email,
            emailVerified: authState.emailVerified,
          ),
          const SizedBox(height: AtlasSpacing.lg),
          CollectorScoreCard(
            score: dashboard.score.score,
            title: dashboard.score.title,
          ),
          const SizedBox(height: AtlasSpacing.lg),
          VaultStatusCard(isPremium: authProvider.isPremium),
          const SizedBox(height: AtlasSpacing.lg),
          ProfileStatsCard(
            totalPops: dashboard.totalPops,
            totalValue: dashboard.totalValue,
            grailCount: dashboard.grailCount,
            wishlistCount: dashboard.wishlistCount,
          ),
          const SizedBox(height: AtlasSpacing.lg),
          CollectorDnaCard(
            primaryTrait: dashboard.dna.primaryTrait,
            secondaryTrait: dashboard.dna.secondaryTrait,
            confidence: dashboard.dna.confidence,
            summary: dashboard.dna.summary,
          ),
          const SizedBox(height: AtlasSpacing.lg),
          VaultHealthCard(
            health: dashboard.vaultHealth,
            message: dashboard.vaultHealth >= 90
                ? 'Your Vault is in excellent shape.'
                : 'Review duplicates and missing values to improve Vault Health.',
          ),
          const SizedBox(height: AtlasSpacing.lg),
          AtlasConfidenceCard(
            confidence: dashboard.confidence.score,
            message: dashboard.confidence.message,
          ),
          const SizedBox(height: AtlasSpacing.lg),
          AchievementPreviewCard(achievements: dashboard.achievements),
          const SizedBox(height: AtlasSpacing.lg),
          MemoryPreviewCard(
            title: dashboard.memory.title,
            message: dashboard.memory.message,
            footer: dashboard.memory.footer,
          ),
          const SizedBox(height: AtlasSpacing.lg),
          CollectorDetailsCard(profile: profile),
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

class _AccountIdentityCard extends StatelessWidget {
  const _AccountIdentityCard({
    required this.isLoggedIn,
    required this.email,
    required this.emailVerified,
  });

  final bool isLoggedIn;
  final String? email;
  final bool emailVerified;

  @override
  Widget build(BuildContext context) {
    final String accountEmail = email?.trim().isNotEmpty == true
        ? email!.trim()
        : 'No account connected';

    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_circle_outlined,
                color: AtlasColors.vaultGold,
              ),
              const SizedBox(width: AtlasSpacing.sm),
              Expanded(
                child: Text(
                  'Atlas Account',
                  style: AtlasTypography.headingSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: AtlasSpacing.md),
          Text(
            isLoggedIn ? accountEmail : 'Using Atlas as Guest',
            style: AtlasTypography.bodyMedium,
          ),
          const SizedBox(height: AtlasSpacing.xs),
          Text(
            isLoggedIn
                ? emailVerified
                      ? 'Email verified'
                      : 'Email verification pending'
                : 'Sign in to connect this collector profile to an Atlas account.',
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
