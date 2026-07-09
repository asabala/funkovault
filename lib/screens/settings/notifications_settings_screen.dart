import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/atlas_glass_panel.dart';
import '../../widgets/premium/premium_badge.dart';

class NotificationsSettingsScreen extends StatelessWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
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
                      'Notifications',
                      style: AtlasTypography.headingLarge,
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    Text(
                      'Prepare future alerts for drops, wishlist activity, cleanup reminders, value updates, and Premium smart alerts.',
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
                      'Notification Status',
                      style: AtlasTypography.headingSmall,
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    Text(
                      'Notifications are not connected yet. This screen is ready for future push notifications, in-app alerts, and collector reminders.',
                      style: AtlasTypography.bodyMedium.copyWith(
                        color: AtlasColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.lg),
                    const _NotificationStatusPanel(
                      icon: Icons.notifications_none_rounded,
                      title: 'In-App Notifications',
                      message: 'Future alerts can appear inside Atlas.',
                      status: 'Planned',
                    ),
                    SizedBox(height: AtlasSpacing.sm),
                    const _NotificationStatusPanel(
                      icon: Icons.phone_android_rounded,
                      title: 'Push Notifications',
                      message: 'Future mobile alerts can notify collectors outside the app.',
                      status: 'Future',
                    ),
                    SizedBox(height: AtlasSpacing.sm),
                    const _NotificationStatusPanel(
                      icon: Icons.workspace_premium_rounded,
                      title: 'Premium Smart Alerts',
                      message: 'Advanced alert logic can be added for Premium collectors.',
                      status: 'Premium',
                      isPremium: true,
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
                      'Future Notification Types',
                      style: AtlasTypography.headingSmall,
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    Text(
                      'These alert types are staged now so notification logic can be added cleanly later.',
                      style: AtlasTypography.bodyMedium.copyWith(
                        color: AtlasColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.lg),
                    _NotificationTypeRow(
                      icon: Icons.event_available_rounded,
                      title: 'Drop Alerts',
                      subtitle: 'Get future alerts for releases, drops, and collector events.',
                      onTap: () => _showComingSoonMessage(
                        context,
                        'Drop alerts are coming soon.',
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    _NotificationTypeRow(
                      icon: Icons.favorite_border_rounded,
                      title: 'Wishlist Alerts',
                      subtitle: 'Track future wishlist activity, availability, and reminders.',
                      onTap: () => _showComingSoonMessage(
                        context,
                        'Wishlist alerts are coming soon.',
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    _NotificationTypeRow(
                      icon: Icons.cleaning_services_rounded,
                      title: 'Cleanup Reminders',
                      subtitle: 'Get reminders for missing values, review tasks, and vault cleanup.',
                      onTap: () => _showComingSoonMessage(
                        context,
                        'Cleanup reminders are coming soon.',
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    _NotificationTypeRow(
                      icon: Icons.trending_up_rounded,
                      title: 'Value Updates',
                      subtitle: 'Prepare alerts for future value changes and pricing movement.',
                      onTap: () => _showComingSoonMessage(
                        context,
                        'Value update alerts are coming soon.',
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    _NotificationTypeRow(
                      icon: Icons.auto_awesome_rounded,
                      title: 'Premium Smart Alerts',
                      subtitle: 'Unlock smarter collector alerts, priority reminders, and personalized updates.',
                      isPremium: true,
                      onTap: () => _showComingSoonMessage(
                        context,
                        'Premium smart alerts are coming soon.',
                      ),
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
                        'Notifications should be added carefully so collectors only get useful alerts and the app never feels noisy.',
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

class _NotificationStatusPanel extends StatelessWidget {
  const _NotificationStatusPanel({
    required this.icon,
    required this.title,
    required this.message,
    required this.status,
    this.isPremium = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final String status;
  final bool isPremium;

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
          isPremium
              ? const PremiumBadge()
              : _NotificationStatusBadge(
            label: status,
          ),
        ],
      ),
    );
  }
}

class _NotificationTypeRow extends StatelessWidget {
  const _NotificationTypeRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isPremium = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isPremium;

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
                        if (isPremium) const PremiumBadge(),
                      ],
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

class _NotificationStatusBadge extends StatelessWidget {
  const _NotificationStatusBadge({
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