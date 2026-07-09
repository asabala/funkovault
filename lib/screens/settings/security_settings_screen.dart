import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/atlas_glass_panel.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security'),
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
                      'Security',
                      style: AtlasTypography.headingLarge,
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    Text(
                      'Manage account protection, future two-step verification, and security tools.',
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
                      'Account Protection',
                      style: AtlasTypography.headingSmall,
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    Text(
                      'Core security stays simple now, with stronger account protection planned as Atlas grows.',
                      style: AtlasTypography.bodyMedium.copyWith(
                        color: AtlasColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.lg),
                    _SecuritySettingsRow(
                      icon: Icons.password_rounded,
                      title: 'Password',
                      subtitle: 'Password management will connect to account auth later.',
                      status: 'Coming Soon',
                      onTap: () => _showComingSoonMessage(
                        context,
                        'Password management is coming soon.',
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    _SecuritySettingsRow(
                      icon: Icons.verified_user_outlined,
                      title: 'Two-Step Verification',
                      subtitle: 'Add an extra layer of protection for collector accounts.',
                      status: 'Planned',
                      onTap: () => _showComingSoonMessage(
                        context,
                        'Two-step verification is planned for a future security update.',
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    _SecuritySettingsRow(
                      icon: Icons.devices_rounded,
                      title: 'Trusted Devices',
                      subtitle: 'Review devices that have access to your vault.',
                      status: 'Future',
                      onTap: () => _showComingSoonMessage(
                        context,
                        'Trusted devices are coming in a future update.',
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    _SecuritySettingsRow(
                      icon: Icons.notifications_active_outlined,
                      title: 'Login Alerts',
                      subtitle: 'Receive alerts for important account activity.',
                      status: 'Future',
                      onTap: () => _showComingSoonMessage(
                        context,
                        'Login alerts are coming in a future update.',
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
                      'Security Status',
                      style: AtlasTypography.headingSmall,
                    ),
                    const SizedBox(height: AtlasSpacing.lg),
                    const _SecurityStatusItem(
                      icon: Icons.lock_outline_rounded,
                      title: 'Basic Protection',
                      message: 'Account access is protected by the current sign-in system.',
                    ),
                    SizedBox(height: AtlasSpacing.sm),
                    const _SecurityStatusItem(
                      icon: Icons.shield_outlined,
                      title: 'Two-Step Verification',
                      message: 'Planned for stronger account protection later.',
                    ),
                    SizedBox(height: AtlasSpacing.sm),
                    const _SecurityStatusItem(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Collector Data',
                      message: 'Future security tools will focus on keeping vault data protected.',
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
                        'Security features will be connected carefully so account protection stays reliable and does not break the login flow.',
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

class _SecuritySettingsRow extends StatelessWidget {
  const _SecuritySettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
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
              _SecurityStatusBadge(
                label: status,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecurityStatusBadge extends StatelessWidget {
  const _SecurityStatusBadge({
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

class _SecurityStatusItem extends StatelessWidget {
  const _SecurityStatusItem({
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