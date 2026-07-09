import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/atlas_glass_panel.dart';
import '../../widgets/premium/premium_badge.dart';

class HelpRoadmapScreen extends StatelessWidget {
  const HelpRoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Roadmap'),
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
                    Text(
                      'Help & Roadmap',
                      style: AtlasTypography.headingLarge,
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    Text(
                      'Review current focus areas, planned features, Premium direction, and support notes for Atlas.',
                      style: AtlasTypography.bodyMedium.copyWith(
                        color: AtlasColors.textSecondary,
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
                      'Current Focus',
                      style: AtlasTypography.headingSmall,
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    Text(
                      'Atlas is focused on keeping the Vault simple, scalable, beautiful, and useful for real collectors.',
                      style: AtlasTypography.bodyMedium.copyWith(
                        color: AtlasColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.lg),
                    const _RoadmapItem(
                      icon: Icons.inventory_2_outlined,
                      title: 'Vault Review Experience',
                      message:
                      'Entire Vault search, filters, sorting, saved view preferences, and cleanup focus tools are active.',
                      status: 'Active',
                    ),
                    SizedBox(height: AtlasSpacing.sm),
                    const _RoadmapItem(
                      icon: Icons.health_and_safety_outlined,
                      title: 'Vault Health',
                      message:
                      'Vault Health has a dedicated screen, dashboard entry point, Settings entry, and Premium-ready foundation.',
                      status: 'Active',
                    ),
                    SizedBox(height: AtlasSpacing.sm),
                    const _RoadmapItem(
                      icon: Icons.settings_suggest_outlined,
                      title: 'Settings Control Center',
                      message:
                      'Settings is becoming the main control center for profile, Premium, Vault tools, preferences, backup, notifications, and security.',
                      status: 'Active',
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
                      'Coming Soon',
                      style: AtlasTypography.headingSmall,
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    Text(
                      'These features are planned as Atlas grows. Core collecting tools should stay simple and reliable.',
                      style: AtlasTypography.bodyMedium.copyWith(
                        color: AtlasColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.lg),
                    _RoadmapActionRow(
                      icon: Icons.qr_code_scanner_rounded,
                      title: 'Smart Scanner',
                      subtitle:
                      'Barcode scanning stays free. Image and AI-assisted identification can come later.',
                      onTap: () => _showComingSoonMessage(
                        context,
                        'Smart Scanner improvements are coming soon.',
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    _RoadmapActionRow(
                      icon: Icons.bookmark_added_outlined,
                      title: 'Saved Views',
                      subtitle:
                      'Create named Vault views for filters, sorting, rooms, and review workflows.',
                      onTap: () => _showComingSoonMessage(
                        context,
                        'Saved views are coming soon.',
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    _RoadmapActionRow(
                      icon: Icons.calendar_month_outlined,
                      title: 'Drop Calendar',
                      subtitle:
                      'Track future drops, conventions, releases, and collector events.',
                      onTap: () => _showComingSoonMessage(
                        context,
                        'Drop Calendar is coming soon.',
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    _RoadmapActionRow(
                      icon: Icons.groups_outlined,
                      title: 'Community Features',
                      subtitle:
                      'Future social and collector community tools can be added after the core Vault is stronger.',
                      onTap: () => _showComingSoonMessage(
                        context,
                        'Community features are coming soon.',
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
                    Row(
                      children: [
                        Text(
                          'Premium Roadmap',
                          style: AtlasTypography.headingSmall,
                        ),
                        const SizedBox(width: AtlasSpacing.sm),
                        const PremiumBadge(),
                      ],
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    Text(
                      'Premium should enhance Atlas with intelligence, personalization, automation, and deeper insights without locking basic collecting tools.',
                      style: AtlasTypography.bodyMedium.copyWith(
                        color: AtlasColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.lg),
                    const _PremiumRoadmapItem(
                      icon: Icons.health_and_safety_rounded,
                      title: 'Advanced Vault Health',
                      message:
                      'Deeper vault scoring, duplicate intelligence, value cleanup priority, and collection risk insights.',
                    ),
                    SizedBox(height: AtlasSpacing.sm),
                    const _PremiumRoadmapItem(
                      icon: Icons.school_rounded,
                      title: 'Premium Academy',
                      message:
                      'Advanced collecting lessons for variants, stickers, values, counterfeits, and strategy.',
                    ),
                    SizedBox(height: AtlasSpacing.sm),
                    const _PremiumRoadmapItem(
                      icon: Icons.palette_rounded,
                      title: 'Seasonal Themes',
                      message:
                      'Seasonal backgrounds, premium visuals, and collector personalization.',
                    ),
                    SizedBox(height: AtlasSpacing.sm),
                    const _PremiumRoadmapItem(
                      icon: Icons.summarize_rounded,
                      title: 'Collection Reports',
                      message:
                      'Collection summaries, value snapshots, and export-ready reports.',
                    ),
                    SizedBox(height: AtlasSpacing.sm),
                    const _PremiumRoadmapItem(
                      icon: Icons.notifications_active_rounded,
                      title: 'Smart Alerts',
                      message:
                      'Personalized drop alerts, wishlist reminders, value movement, and cleanup nudges.',
                    ),
                    SizedBox(height: AtlasSpacing.sm),
                    const _PremiumRoadmapItem(
                      icon: Icons.auto_awesome_rounded,
                      title: 'Atlas AI Insights',
                      message:
                      'Smarter recommendations, personalized next steps, and collection guidance.',
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
                      'Support Notes',
                      style: AtlasTypography.headingSmall,
                    ),
                    const SizedBox(height: AtlasSpacing.lg),
                    const _SupportNote(
                      icon: Icons.lock_open_rounded,
                      title: 'Core Collecting Stays Free',
                      message:
                      'Adding Pops, using the Vault, searching, wishlist, and barcode scanning should remain part of the basic experience.',
                    ),
                    SizedBox(height: AtlasSpacing.sm),
                    const _SupportNote(
                      icon: Icons.cleaning_services_outlined,
                      title: 'Keep the Dashboard Clean',
                      message:
                      'Large details should move to dedicated screens when the Vault Dashboard starts feeling crowded.',
                    ),
                    SizedBox(height: AtlasSpacing.sm),
                    const _SupportNote(
                      icon: Icons.shield_outlined,
                      title: 'Security First',
                      message:
                      'Account security, backup, and sync should be connected carefully so vault data stays reliable.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AtlasSpacing.lg),
              AtlasGlassPanel(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AtlasColors.vaultGold,
                    ),
                    const SizedBox(width: AtlasSpacing.md),
                    Expanded(
                      child: Text(
                        'Roadmap items are staged as guidance. Features should be built one stable layer at a time and verified with flutter analyze after each change.',
                        style: AtlasTypography.bodySmall.copyWith(
                          color: AtlasColors.textSecondary,
                          height: 1.35,
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

  static void _showComingSoonMessage(
      BuildContext context,
      String message,
      ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}

class _RoadmapItem extends StatelessWidget {
  const _RoadmapItem({
    required this.icon,
    required this.title,
    required this.message,
    required this.status,
  });

  final IconData icon;
  final String title;
  final String message;
  final String status;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
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
                Text(
                  title,
                  style: AtlasTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AtlasSpacing.xs),
                Text(
                  message,
                  style: AtlasTypography.bodySmall.copyWith(
                    color: AtlasColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AtlasSpacing.sm),
          _RoadmapStatusBadge(
            label: status,
          ),
        ],
      ),
    );
  }
}

class _RoadmapActionRow extends StatelessWidget {
  const _RoadmapActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AtlasSpacing.sm),
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
                    Text(
                      title,
                      style: AtlasTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.xs),
                    Text(
                      subtitle,
                      style: AtlasTypography.bodySmall.copyWith(
                        color: AtlasColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AtlasSpacing.sm),
              const Icon(
                Icons.chevron_right_rounded,
                color: AtlasColors.vaultGold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumRoadmapItem extends StatelessWidget {
  const _PremiumRoadmapItem({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
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
                  message,
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
    );
  }
}

class _SupportNote extends StatelessWidget {
  const _SupportNote({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
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
                Text(
                  title,
                  style: AtlasTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AtlasSpacing.xs),
                Text(
                  message,
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
    );
  }
}

class _RoadmapStatusBadge extends StatelessWidget {
  const _RoadmapStatusBadge({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AtlasSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AtlasColors.vaultGold.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AtlasColors.vaultGold.withValues(alpha: 0.34),
        ),
      ),
      child: Text(
        label,
        style: AtlasTypography.bodySmall.copyWith(
          color: AtlasColors.vaultGold,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}