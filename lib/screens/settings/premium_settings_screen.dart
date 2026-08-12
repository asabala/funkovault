import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/app_state.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/components/atlas_action_row.dart';
import '../../widgets/atlas/components/atlas_info_banner.dart';
import '../../widgets/atlas/components/atlas_section_header.dart';
import '../../widgets/premium/premium_badge.dart';

class PremiumSettingsScreen extends StatelessWidget {
  const PremiumSettingsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final profile = appState.collectorProfile;
    final bool isPremium = profile.isPremium;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Premium',
        ),
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
                accentColor: AtlasColors.vaultGold,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AtlasSectionHeader(
                      title: isPremium
                          ? 'Premium Active'
                          : 'Atlas Premium',
                      subtitle: isPremium
                          ? 'You have access to advanced Atlas features.'
                          : 'Unlock deeper insights, personalization, reports, and collector intelligence.',
                      icon: Icons.workspace_premium_rounded,
                      accentColor: AtlasColors.vaultGold,
                      badge: isPremium
                          ? const PremiumBadge(
                        label: 'Active',
                      )
                          : null,
                    ),
                    const SizedBox(
                      height: AtlasSpacing.lg,
                    ),
                    AtlasInfoBanner(
                      icon: isPremium
                          ? Icons.verified_rounded
                          : Icons.lock_outline_rounded,
                      title: isPremium
                          ? 'Premium Plan'
                          : 'Basic Plan',
                      message: isPremium
                          ? 'Premium tools are enabled for this collector profile.'
                          : 'Core collecting stays free. Premium adds advanced tools on top.',
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: AtlasSpacing.lg,
              ),

              AtlasGlassCard(
                accentColor: AtlasColors.vaultGold,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AtlasSectionHeader(
                      title: 'Premium Features',
                      subtitle:
                      'Premium enhances the collector experience without locking basic collecting tools.',
                      icon: Icons.auto_awesome_rounded,
                      accentColor: AtlasColors.vaultGold,
                      badge: PremiumBadge(),
                    ),

                    const SizedBox(
                      height: AtlasSpacing.lg,
                    ),

                    const AtlasActionRow(
                      title: 'Advanced Vault Health',
                      description:
                      'Deeper scoring, duplicate intelligence, cleanup priority, and collection risk insights.',
                      icon: Icons.health_and_safety_rounded,
                      accentColor: AtlasColors.vaultGold,
                      showChevron: false,
                      compact: true,
                    ),

                    const SizedBox(
                      height: AtlasSpacing.sm,
                    ),

                    const AtlasActionRow(
                      title: 'Premium Academy',
                      description:
                      'Advanced lessons for variants, stickers, values, counterfeits, and collector strategy.',
                      icon: Icons.school_rounded,
                      accentColor: AtlasColors.vaultGold,
                      showChevron: false,
                      compact: true,
                    ),

                    const SizedBox(
                      height: AtlasSpacing.sm,
                    ),

                    const AtlasActionRow(
                      title: 'Seasonal Themes',
                      description:
                      'Unlock seasonal backgrounds, premium visuals, and collector personalization.',
                      icon: Icons.palette_rounded,
                      accentColor: AtlasColors.vaultGold,
                      showChevron: false,
                      compact: true,
                    ),

                    const SizedBox(
                      height: AtlasSpacing.sm,
                    ),

                    const AtlasActionRow(
                      title: 'Collection Reports',
                      description:
                      'Generate cleaner collection summaries, value snapshots, and export-ready reports.',
                      icon: Icons.summarize_rounded,
                      accentColor: AtlasColors.vaultGold,
                      showChevron: false,
                      compact: true,
                    ),

                    const SizedBox(
                      height: AtlasSpacing.sm,
                    ),

                    const AtlasActionRow(
                      title: 'Smart Alerts',
                      description:
                      'Future alerts for drops, wishlist activity, value changes, and cleanup reminders.',
                      icon: Icons.notifications_active_rounded,
                      accentColor: AtlasColors.vaultGold,
                      showChevron: false,
                      compact: true,
                    ),

                    const SizedBox(
                      height: AtlasSpacing.sm,
                    ),

                    const AtlasActionRow(
                      title: 'Atlas AI Insights',
                      description:
                      'Smarter recommendations, collection guidance, and personalized next steps.',
                      icon: Icons.auto_awesome_rounded,
                      accentColor: AtlasColors.vaultGold,
                      showChevron: false,
                      compact: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: AtlasSpacing.lg,
              ),

              AtlasGlassCard(
                accentColor: AtlasColors.vaultGold,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AtlasSectionHeader(
                      title: isPremium
                          ? 'Premium Management'
                          : 'Upgrade',
                      subtitle: isPremium
                          ? 'Subscription management tools will be added here later.'
                          : 'Upgrade flow is not connected yet. This screen is ready for the future payment and subscription setup.',
                      icon: isPremium
                          ? Icons.manage_accounts_rounded
                          : Icons.lock_open_rounded,
                      accentColor: AtlasColors.vaultGold,
                    ),

                    const SizedBox(
                      height: AtlasSpacing.lg,
                    ),

                    AtlasActionRow(
                      title: isPremium
                          ? 'Manage Premium'
                          : 'Upgrade to Premium',
                      description: isPremium
                          ? 'Manage your Atlas Premium subscription and account options.'
                          : 'Unlock advanced intelligence, personalization, reports, and Premium tools.',
                      icon: isPremium
                          ? Icons.manage_accounts_rounded
                          : Icons.lock_open_rounded,
                      accentColor: AtlasColors.vaultGold,
                      onTap: () {
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