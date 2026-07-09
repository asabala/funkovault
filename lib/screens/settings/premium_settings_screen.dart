import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/app_state.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/atlas_glass_panel.dart';
import '../../widgets/premium/premium_badge.dart';

class PremiumSettingsScreen extends StatelessWidget {
  const PremiumSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final profile = appState.collectorProfile;
    final isPremium = profile.isPremium;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AtlasSpacing.md,
            AtlasSpacing.md,
            AtlasSpacing.md,
            100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AtlasGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.workspace_premium_rounded,
                          color: AtlasColors.vaultGold,
                        ),
                        const SizedBox(width: AtlasSpacing.sm),
                        Expanded(
                          child: Text(
                            isPremium ? 'Premium Active' : 'Atlas Premium',
                            style: AtlasTypography.headingLarge,
                          ),
                        ),
                        if (isPremium) const PremiumBadge(label: 'Active'),
                      ],
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    Text(
                      isPremium
                          ? 'You have access to advanced Atlas features.'
                          : 'Unlock deeper insights, personalization, reports, and collector intelligence.',
                      style: AtlasTypography.bodyMedium.copyWith(
                        color: AtlasColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.lg),
                    AtlasGlassPanel(
                      child: Row(
                        children: [
                          Icon(
                            isPremium
                                ? Icons.verified_rounded
                                : Icons.lock_outline_rounded,
                            color: AtlasColors.vaultGold,
                          ),
                          const SizedBox(width: AtlasSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isPremium ? 'Premium Plan' : 'Basic Plan',
                                  style: AtlasTypography.bodyMedium.copyWith(
                                    color: AtlasColors.vaultGold,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AtlasSpacing.xs),
                                Text(
                                  isPremium
                                      ? 'Premium tools are enabled for this collector profile.'
                                      : 'Core collecting stays free. Premium adds advanced tools on top.',
                                  style: AtlasTypography.bodySmall.copyWith(
                                    color: AtlasColors.textSecondary,
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
              const SizedBox(height: AtlasSpacing.lg),
              AtlasGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premium Features',
                      style: AtlasTypography.headingSmall,
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    Text(
                      'Premium should enhance the collector experience without locking basic collecting tools.',
                      style: AtlasTypography.bodyMedium.copyWith(
                        color: AtlasColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.lg),
                    const _PremiumFeatureRow(
                      icon: Icons.health_and_safety_rounded,
                      title: 'Advanced Vault Health',
                      description:
                      'Deeper scoring, duplicate intelligence, cleanup priority, and collection risk insights.',
                    ),
                    const _PremiumFeatureRow(
                      icon: Icons.school_rounded,
                      title: 'Premium Academy',
                      description:
                      'Advanced lessons for variants, stickers, values, counterfeits, and collector strategy.',
                    ),
                    const _PremiumFeatureRow(
                      icon: Icons.palette_rounded,
                      title: 'Seasonal Themes',
                      description:
                      'Unlock seasonal backgrounds, premium visuals, and collector personalization.',
                    ),
                    const _PremiumFeatureRow(
                      icon: Icons.summarize_rounded,
                      title: 'Collection Reports',
                      description:
                      'Generate cleaner collection summaries, value snapshots, and export-ready reports.',
                    ),
                    const _PremiumFeatureRow(
                      icon: Icons.notifications_active_rounded,
                      title: 'Smart Alerts',
                      description:
                      'Future alerts for drops, wishlist activity, value changes, and cleanup reminders.',
                    ),
                    const _PremiumFeatureRow(
                      icon: Icons.auto_awesome_rounded,
                      title: 'Atlas AI Insights',
                      description:
                      'Smarter recommendations, collection guidance, and personalized next steps.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AtlasSpacing.lg),
              AtlasGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPremium ? 'Premium Management' : 'Upgrade',
                      style: AtlasTypography.headingSmall,
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    Text(
                      isPremium
                          ? 'Subscription management tools will be added here later.'
                          : 'Upgrade flow is not connected yet. This screen is ready for the future payment and subscription setup.',
                      style: AtlasTypography.bodyMedium.copyWith(
                        color: AtlasColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isPremium
                                    ? 'Premium management is coming soon.'
                                    : 'Premium upgrade flow is coming soon.',
                              ),
                            ),
                          );
                        },
                        icon: Icon(
                          isPremium
                              ? Icons.manage_accounts_rounded
                              : Icons.lock_open_rounded,
                        ),
                        label: Text(
                          isPremium
                              ? 'Manage Premium'
                              : 'Upgrade to Premium',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumFeatureRow extends StatelessWidget {
  const _PremiumFeatureRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AtlasSpacing.md,
      ),
      child: AtlasGlassPanel(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: AtlasColors.vaultGold,
            ),
            const SizedBox(width: AtlasSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AtlasTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const PremiumBadge(),
                    ],
                  ),
                  const SizedBox(height: AtlasSpacing.xs),
                  Text(
                    description,
                    style: AtlasTypography.bodySmall.copyWith(
                      color: AtlasColors.textSecondary,
                      height: 1.35,
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