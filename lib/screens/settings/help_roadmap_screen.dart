import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/components/atlas_action_row.dart';
import '../../widgets/atlas/components/atlas_info_banner.dart';
import '../../widgets/atlas/components/atlas_section_header.dart';
import '../../widgets/atlas/components/atlas_status_chip.dart';
import '../../widgets/premium/premium_badge.dart';

class HelpRoadmapScreen extends StatelessWidget {
  const HelpRoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Roadmap')),
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
              const AtlasGlassCard(
                accentColor: AtlasColors.vaultGold,
                child: AtlasSectionHeader(
                  title: 'Help & Roadmap',
                  subtitle:
                      'Review current focus areas, planned features, Premium direction, and support notes for Atlas.',
                  icon: Icons.route_rounded,
                  accentColor: AtlasColors.vaultGold,
                ),
              ),

              const SizedBox(height: AtlasSpacing.lg),

              const AtlasGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AtlasSectionHeader(
                      title: 'Current Focus',
                      subtitle:
                          'Atlas is focused on keeping the Vault simple, scalable, beautiful, and useful for real collectors.',
                      icon: Icons.track_changes_rounded,
                    ),

                    SizedBox(height: AtlasSpacing.lg),

                    AtlasActionRow(
                      title: 'Vault Review Experience',
                      description:
                          'Entire Vault search, filters, sorting, saved view preferences, and cleanup focus tools are active.',
                      icon: Icons.inventory_2_outlined,
                      showChevron: false,
                      compact: true,
                      badge: AtlasStatusChip(
                        label: 'Active',
                        accentColor: AtlasColors.vaultGold,
                        size: AtlasStatusChipSize.compact,
                      ),
                    ),

                    SizedBox(height: AtlasSpacing.sm),

                    AtlasActionRow(
                      title: 'Vault Health',
                      description:
                          'Vault Health has a dedicated screen, dashboard entry point, Settings entry, and Premium-ready foundation.',
                      icon: Icons.health_and_safety_outlined,
                      showChevron: false,
                      compact: true,
                      badge: AtlasStatusChip(
                        label: 'Active',
                        accentColor: AtlasColors.vaultGold,
                        size: AtlasStatusChipSize.compact,
                      ),
                    ),

                    SizedBox(height: AtlasSpacing.sm),

                    AtlasActionRow(
                      title: 'Settings Control Center',
                      description:
                          'Settings is the main control center for profile, Premium, Vault tools, preferences, backup, notifications, and security.',
                      icon: Icons.settings_suggest_outlined,
                      showChevron: false,
                      compact: true,
                      badge: AtlasStatusChip(
                        label: 'Active',
                        accentColor: AtlasColors.vaultGold,
                        size: AtlasStatusChipSize.compact,
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
                    const AtlasSectionHeader(
                      title: 'Coming Soon',
                      subtitle:
                          'These features are planned as Atlas grows. Core collecting tools should stay simple and reliable.',
                      icon: Icons.upcoming_outlined,
                    ),

                    const SizedBox(height: AtlasSpacing.lg),

                    AtlasActionRow(
                      title: 'Smart Scanner',
                      description:
                          'Barcode scanning stays free. Image and AI-assisted identification can come later.',
                      icon: Icons.qr_code_scanner_rounded,
                      onTap: () {
                        _showComingSoonMessage(
                          context,
                          'Smart Scanner improvements are coming soon.',
                        );
                      },
                    ),

                    const SizedBox(height: AtlasSpacing.sm),

                    AtlasActionRow(
                      title: 'Saved Views',
                      description:
                          'Create named Vault views for filters, sorting, rooms, and review workflows.',
                      icon: Icons.bookmark_added_outlined,
                      onTap: () {
                        _showComingSoonMessage(
                          context,
                          'Saved views are coming soon.',
                        );
                      },
                    ),

                    const SizedBox(height: AtlasSpacing.sm),

                    AtlasActionRow(
                      title: 'Drop Calendar',
                      description:
                          'Track future drops, conventions, releases, and collector events.',
                      icon: Icons.calendar_month_outlined,
                      onTap: () {
                        _showComingSoonMessage(
                          context,
                          'Drop Calendar is coming soon.',
                        );
                      },
                    ),

                    const SizedBox(height: AtlasSpacing.sm),

                    AtlasActionRow(
                      title: 'Community Features',
                      description:
                          'Future social and collector community tools can be added after the core Vault is stronger.',
                      icon: Icons.groups_outlined,
                      onTap: () {
                        _showComingSoonMessage(
                          context,
                          'Community features are coming soon.',
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AtlasSpacing.lg),

              const AtlasGlassCard(
                accentColor: AtlasColors.vaultGold,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AtlasSectionHeader(
                      title: 'Premium Roadmap',
                      subtitle:
                          'Premium should enhance Atlas with intelligence, personalization, automation, and deeper insights without locking basic collecting tools.',
                      icon: Icons.workspace_premium_rounded,
                      accentColor: AtlasColors.vaultGold,
                      badge: PremiumBadge(),
                    ),

                    SizedBox(height: AtlasSpacing.lg),

                    AtlasActionRow(
                      title: 'Advanced Vault Health',
                      description:
                          'Deeper vault scoring, duplicate intelligence, value cleanup priority, and collection risk insights.',
                      icon: Icons.health_and_safety_rounded,
                      accentColor: AtlasColors.vaultGold,
                      showChevron: false,
                      compact: true,
                      badge: PremiumBadge(),
                    ),

                    SizedBox(height: AtlasSpacing.sm),

                    AtlasActionRow(
                      title: 'Premium Academy',
                      description:
                          'Advanced collecting lessons for variants, stickers, values, counterfeits, and strategy.',
                      icon: Icons.school_rounded,
                      accentColor: AtlasColors.vaultGold,
                      showChevron: false,
                      compact: true,
                      badge: PremiumBadge(),
                    ),

                    SizedBox(height: AtlasSpacing.sm),

                    AtlasActionRow(
                      title: 'Seasonal Themes',
                      description:
                          'Seasonal backgrounds, Premium visuals, and collector personalization.',
                      icon: Icons.palette_rounded,
                      accentColor: AtlasColors.vaultGold,
                      showChevron: false,
                      compact: true,
                      badge: PremiumBadge(),
                    ),

                    SizedBox(height: AtlasSpacing.sm),

                    AtlasActionRow(
                      title: 'Collection Reports',
                      description:
                          'Collection summaries, value snapshots, and export-ready reports.',
                      icon: Icons.summarize_rounded,
                      accentColor: AtlasColors.vaultGold,
                      showChevron: false,
                      compact: true,
                      badge: PremiumBadge(),
                    ),

                    SizedBox(height: AtlasSpacing.sm),

                    AtlasActionRow(
                      title: 'Smart Alerts',
                      description:
                          'Personalized drop alerts, wishlist reminders, value movement, and cleanup nudges.',
                      icon: Icons.notifications_active_rounded,
                      accentColor: AtlasColors.vaultGold,
                      showChevron: false,
                      compact: true,
                      badge: PremiumBadge(),
                    ),

                    SizedBox(height: AtlasSpacing.sm),

                    AtlasActionRow(
                      title: 'Atlas AI Insights',
                      description:
                          'Smarter recommendations, personalized next steps, and collection guidance.',
                      icon: Icons.auto_awesome_rounded,
                      accentColor: AtlasColors.vaultGold,
                      showChevron: false,
                      compact: true,
                      badge: PremiumBadge(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AtlasSpacing.lg),

              const AtlasGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AtlasSectionHeader(
                      title: 'Support Notes',
                      subtitle:
                          'Product principles that should stay intact as Atlas grows.',
                      icon: Icons.support_agent_rounded,
                    ),

                    SizedBox(height: AtlasSpacing.lg),

                    AtlasActionRow(
                      title: 'Core Collecting Stays Free',
                      description:
                          'Adding Pops, using the Vault, searching, wishlist, and barcode scanning should remain part of the basic experience.',
                      icon: Icons.lock_open_rounded,
                      showChevron: false,
                      compact: true,
                    ),

                    SizedBox(height: AtlasSpacing.sm),

                    AtlasActionRow(
                      title: 'Keep the Dashboard Clean',
                      description:
                          'Large details should move to dedicated screens when the Vault Dashboard starts feeling crowded.',
                      icon: Icons.cleaning_services_outlined,
                      showChevron: false,
                      compact: true,
                    ),

                    SizedBox(height: AtlasSpacing.sm),

                    AtlasActionRow(
                      title: 'Security First',
                      description:
                          'Account security, backup, and sync should be connected carefully so vault data stays reliable.',
                      icon: Icons.shield_outlined,
                      showChevron: false,
                      compact: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AtlasSpacing.lg),

              const AtlasInfoBanner(
                icon: Icons.info_outline_rounded,
                title: 'Roadmap Guidance',
                message:
                    'Roadmap items are staged as guidance. Features should be built one stable layer at a time and verified with flutter analyze after each change.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showComingSoonMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
