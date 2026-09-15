import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/components/atlas_action_row.dart';
import '../../widgets/atlas/components/atlas_info_banner.dart';
import '../../widgets/atlas/components/atlas_section_header.dart';
import '../../widgets/atlas/components/atlas_status_chip.dart';
import '../../widgets/premium/premium_badge.dart';

class NotificationsSettingsScreen extends StatelessWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
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
                  title: 'Notifications',
                  subtitle:
                      'Prepare future alerts for drops, wishlist activity, cleanup reminders, value updates, and Premium smart alerts.',
                  icon: Icons.notifications_active_rounded,
                  accentColor: AtlasColors.vaultGold,
                ),
              ),

              const SizedBox(height: AtlasSpacing.lg),

              const AtlasGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AtlasSectionHeader(
                      title: 'Notification Status',
                      subtitle:
                          'Notifications are not connected yet. This screen is ready for future push notifications, in-app alerts, and collector reminders.',
                      icon: Icons.notifications_none_rounded,
                    ),

                    SizedBox(height: AtlasSpacing.lg),

                    AtlasActionRow(
                      title: 'In-App Notifications',
                      description: 'Future alerts can appear inside Atlas.',
                      icon: Icons.notifications_none_rounded,
                      showChevron: false,
                      compact: true,
                      badge: AtlasStatusChip(
                        label: 'Planned',
                        accentColor: AtlasColors.vaultGold,
                        size: AtlasStatusChipSize.compact,
                      ),
                    ),

                    SizedBox(height: AtlasSpacing.sm),

                    AtlasActionRow(
                      title: 'Push Notifications',
                      description:
                          'Future mobile alerts can notify collectors outside the app.',
                      icon: Icons.phone_android_rounded,
                      showChevron: false,
                      compact: true,
                      badge: AtlasStatusChip(
                        label: 'Future',
                        accentColor: AtlasColors.vaultGold,
                        size: AtlasStatusChipSize.compact,
                      ),
                    ),

                    SizedBox(height: AtlasSpacing.sm),

                    AtlasActionRow(
                      title: 'Premium Smart Alerts',
                      description:
                          'Advanced alert logic can be added for Premium collectors.',
                      icon: Icons.workspace_premium_rounded,
                      accentColor: AtlasColors.vaultGold,
                      showChevron: false,
                      compact: true,
                      badge: PremiumBadge(),
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
                      title: 'Future Notification Types',
                      subtitle:
                          'These alert types are staged now so notification logic can be added cleanly later.',
                      icon: Icons.notifications_active_outlined,
                    ),

                    const SizedBox(height: AtlasSpacing.lg),

                    AtlasActionRow(
                      title: 'Drop Alerts',
                      description:
                          'Get future alerts for releases, drops, and collector events.',
                      icon: Icons.event_available_rounded,
                      onTap: () {
                        _showComingSoonMessage(
                          context,
                          'Drop alerts are coming soon.',
                        );
                      },
                    ),

                    const SizedBox(height: AtlasSpacing.sm),

                    AtlasActionRow(
                      title: 'Wishlist Alerts',
                      description:
                          'Track future wishlist activity, availability, and reminders.',
                      icon: Icons.favorite_border_rounded,
                      onTap: () {
                        _showComingSoonMessage(
                          context,
                          'Wishlist alerts are coming soon.',
                        );
                      },
                    ),

                    const SizedBox(height: AtlasSpacing.sm),

                    AtlasActionRow(
                      title: 'Cleanup Reminders',
                      description:
                          'Get reminders for missing values, review tasks, and vault cleanup.',
                      icon: Icons.cleaning_services_rounded,
                      onTap: () {
                        _showComingSoonMessage(
                          context,
                          'Cleanup reminders are coming soon.',
                        );
                      },
                    ),

                    const SizedBox(height: AtlasSpacing.sm),

                    AtlasActionRow(
                      title: 'Value Updates',
                      description:
                          'Prepare alerts for future value changes and pricing movement.',
                      icon: Icons.trending_up_rounded,
                      onTap: () {
                        _showComingSoonMessage(
                          context,
                          'Value update alerts are coming soon.',
                        );
                      },
                    ),

                    const SizedBox(height: AtlasSpacing.sm),

                    AtlasActionRow(
                      title: 'Premium Smart Alerts',
                      description:
                          'Unlock smarter collector alerts, priority reminders, and personalized updates.',
                      icon: Icons.auto_awesome_rounded,
                      accentColor: AtlasColors.vaultGold,
                      badge: const PremiumBadge(),
                      onTap: () {
                        _showComingSoonMessage(
                          context,
                          'Premium smart alerts are coming soon.',
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AtlasSpacing.lg),

              const AtlasInfoBanner(
                icon: Icons.info_outline_rounded,
                title: 'Useful, Not Noisy',
                message:
                    'Notifications should be added carefully so collectors only get useful alerts and the app never feels noisy.',
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
