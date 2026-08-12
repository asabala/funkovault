import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/components/atlas_action_row.dart';
import '../../widgets/atlas/components/atlas_info_banner.dart';
import '../../widgets/atlas/components/atlas_section_header.dart';
import '../../widgets/atlas/components/atlas_status_chip.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Security',
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
              const AtlasGlassCard(
                accentColor: AtlasColors.vaultGold,
                child: AtlasSectionHeader(
                  title: 'Security',
                  subtitle:
                  'Manage account protection, future two-step verification, and security tools.',
                  icon: Icons.security_rounded,
                  accentColor: AtlasColors.vaultGold,
                ),
              ),

              const SizedBox(
                height: AtlasSpacing.lg,
              ),

              AtlasGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AtlasSectionHeader(
                      title: 'Account Protection',
                      subtitle:
                      'Core security stays simple now, with stronger account protection planned as Atlas grows.',
                      icon: Icons.shield_outlined,
                    ),

                    const SizedBox(
                      height: AtlasSpacing.lg,
                    ),

                    AtlasActionRow(
                      title: 'Password',
                      description:
                      'Password management will connect to account auth later.',
                      icon: Icons.password_rounded,
                      badge: const AtlasStatusChip(
                        label: 'Coming Soon',
                        accentColor: AtlasColors.vaultGold,
                        size: AtlasStatusChipSize.compact,
                      ),
                      onTap: () {
                        _showComingSoonMessage(
                          context,
                          'Password management is coming soon.',
                        );
                      },
                    ),

                    const SizedBox(
                      height: AtlasSpacing.sm,
                    ),

                    AtlasActionRow(
                      title: 'Two-Step Verification',
                      description:
                      'Add an extra layer of protection for collector accounts.',
                      icon: Icons.verified_user_outlined,
                      badge: const AtlasStatusChip(
                        label: 'Planned',
                        accentColor: AtlasColors.vaultGold,
                        size: AtlasStatusChipSize.compact,
                      ),
                      onTap: () {
                        _showComingSoonMessage(
                          context,
                          'Two-step verification is planned for a future security update.',
                        );
                      },
                    ),

                    const SizedBox(
                      height: AtlasSpacing.sm,
                    ),

                    AtlasActionRow(
                      title: 'Trusted Devices',
                      description:
                      'Review devices that have access to your vault.',
                      icon: Icons.devices_rounded,
                      badge: const AtlasStatusChip(
                        label: 'Future',
                        accentColor: AtlasColors.vaultGold,
                        size: AtlasStatusChipSize.compact,
                      ),
                      onTap: () {
                        _showComingSoonMessage(
                          context,
                          'Trusted devices are coming in a future update.',
                        );
                      },
                    ),

                    const SizedBox(
                      height: AtlasSpacing.sm,
                    ),

                    AtlasActionRow(
                      title: 'Login Alerts',
                      description:
                      'Receive alerts for important account activity.',
                      icon: Icons.notifications_active_outlined,
                      badge: const AtlasStatusChip(
                        label: 'Future',
                        accentColor: AtlasColors.vaultGold,
                        size: AtlasStatusChipSize.compact,
                      ),
                      onTap: () {
                        _showComingSoonMessage(
                          context,
                          'Login alerts are coming in a future update.',
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: AtlasSpacing.lg,
              ),

              const AtlasGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AtlasSectionHeader(
                      title: 'Security Status',
                      subtitle:
                      'Current protection and planned security capabilities for your Atlas account.',
                      icon: Icons.health_and_safety_outlined,
                    ),

                    SizedBox(
                      height: AtlasSpacing.lg,
                    ),

                    AtlasActionRow(
                      title: 'Basic Protection',
                      description:
                      'Account access is protected by the current sign-in system.',
                      icon: Icons.lock_outline_rounded,
                      showChevron: false,
                      compact: true,
                      badge: AtlasStatusChip(
                        label: 'Active',
                        accentColor: AtlasColors.vaultGold,
                        size: AtlasStatusChipSize.compact,
                      ),
                    ),

                    SizedBox(
                      height: AtlasSpacing.sm,
                    ),

                    AtlasActionRow(
                      title: 'Two-Step Verification',
                      description:
                      'Planned for stronger account protection later.',
                      icon: Icons.shield_outlined,
                      showChevron: false,
                      compact: true,
                      badge: AtlasStatusChip(
                        label: 'Planned',
                        accentColor: AtlasColors.vaultGold,
                        size: AtlasStatusChipSize.compact,
                      ),
                    ),

                    SizedBox(
                      height: AtlasSpacing.sm,
                    ),

                    AtlasActionRow(
                      title: 'Collector Data',
                      description:
                      'Future security tools will focus on keeping vault data protected.',
                      icon: Icons.privacy_tip_outlined,
                      showChevron: false,
                      compact: true,
                      badge: AtlasStatusChip(
                        label: 'Protected',
                        accentColor: AtlasColors.vaultGold,
                        size: AtlasStatusChipSize.compact,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: AtlasSpacing.lg,
              ),

              const AtlasInfoBanner(
                icon: Icons.info_outline_rounded,
                title: 'Security First',
                message:
                'Security features will be connected carefully so account protection stays reliable and does not break the login flow.',
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
        content: Text(
          message,
        ),
      ),
    );
  }
}