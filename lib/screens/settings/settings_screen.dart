import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/components/atlas_action_row.dart';
import '../../widgets/atlas/components/atlas_section_header.dart';
import 'backup_sync_settings_screen.dart';
import 'help_roadmap_screen.dart';
import 'import_csv_screen.dart';
import 'notifications_settings_screen.dart';
import 'premium_settings_screen.dart';
import 'security_settings_screen.dart';
import 'vault_preferences_screen.dart';
import '../atlas/ads/atlas_design_system_showcase_screen.dart';
import '../profile/edit_collector_profile_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../security/auth_provider.dart';
import '../vault/vault_health_screen.dart';
import '../vault/vault_maintenance_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(
          bottom: 100,
        ),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AtlasSpacing.md,
              AtlasSpacing.md,
              AtlasSpacing.md,
              AtlasSpacing.sm,
            ),
            child: _SettingsHeaderCard(),
          ),

          const _SettingsSectionHeader(
            title: 'Account',
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AtlasSpacing.md,
            ),
            child: Column(
              children: [
                AtlasActionRow(
                  title: 'Collector Profile',
                  description:
                  'Update your name, title, bio, and collector details.',
                  icon: Icons.person_outline,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const EditCollectorProfileScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: AtlasSpacing.sm,
                ),
                AtlasActionRow(
                  title: 'Premium',
                  description:
                  'Manage Premium features, upgrades, and advanced tools.',
                  icon: Icons.workspace_premium_outlined,
                  accentColor: AtlasColors.vaultGold,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const PremiumSettingsScreen(),
                      ),
                    );
                  },
                ),
                AtlasActionRow(
                  title: 'Premium',
                  description:
                  'Manage Premium features, upgrades, and advanced tools.',
                  icon: Icons.workspace_premium_outlined,
                  accentColor: AtlasColors.vaultGold,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const PremiumSettingsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: AtlasSpacing.sm,
                ),
                if (authProvider.isLoggedIn)
                  AtlasActionRow(
                    title: 'Sign Out',
                    description:
                    'Sign out of your Atlas account on this device.',
                    icon: Icons.logout_rounded,
                    onTap: () async {
                      await authProvider.signOut();

                      if (!context.mounted) {
                        return;
                      }

                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute<void>(
                          builder: (_) => const LoginScreen(),
                        ),
                            (route) => false,
                      );
                    },
                  )
                else
                  AtlasActionRow(
                    title: 'Sign In',
                    description:
                    'Sign in to your Atlas account to restore account features.',
                    icon: Icons.login_rounded,
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute<void>(
                          builder: (_) => const LoginScreen(),
                        ),
                            (route) => false,
                      );
                    },
                  ),
              ],
            ),
          ),

          const _SettingsDivider(),

          const _SettingsSectionHeader(
            title: 'Collection Tools',
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AtlasSpacing.md,
            ),
            child: Column(
              children: [
                AtlasActionRow(
                  title: 'Import Collection CSV',
                  description:
                  'Import a HobbyDB export into your collection.',
                  icon: Icons.upload_file,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const ImportCsvScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: AtlasSpacing.sm,
                ),
                AtlasActionRow(
                  title: 'Vault Maintenance',
                  description:
                  'Review, repair, or reset your current collection.',
                  icon: Icons.build_circle_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const VaultMaintenanceScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: AtlasSpacing.sm,
                ),
                AtlasActionRow(
                  title: 'Vault Health',
                  description:
                  'Review health score, cleanup priority, and Premium health insights.',
                  icon: Icons.health_and_safety_outlined,
                  accentColor: AtlasColors.vaultGold,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const VaultHealthScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const _SettingsDivider(),

          const _SettingsSectionHeader(
            title: 'Preferences',
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AtlasSpacing.md,
            ),
            child: Column(
              children: [
                AtlasActionRow(
                  title: 'Vault Preferences',
                  description:
                  'Manage saved views, image defaults, filters, and sorting.',
                  icon: Icons.tune_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const VaultPreferencesScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: AtlasSpacing.sm,
                ),
                AtlasActionRow(
                  title: 'Backup & Sync',
                  description:
                  'Prepare cloud backup, restore, and sync options.',
                  icon: Icons.cloud_sync_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const BackupSyncSettingsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: AtlasSpacing.sm,
                ),
                AtlasActionRow(
                  title: 'Notifications',
                  description:
                  'Manage future drop alerts, cleanup reminders, and value updates.',
                  icon: Icons.notifications_none_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const NotificationsSettingsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: AtlasSpacing.sm,
                ),
                AtlasActionRow(
                  title: 'Security',
                  description:
                  'Manage account protection and future two-step verification.',
                  icon: Icons.security_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const SecuritySettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const _SettingsDivider(),

          const _SettingsSectionHeader(
            title: 'Developer',
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AtlasSpacing.md,
            ),
            child: AtlasActionRow(
              title: 'ADS Showcase',
              description:
              'Preview Atlas Design System components, maturity, and roadmap.',
              icon: Icons.dashboard_customize_outlined,
              accentColor: AtlasColors.intelligenceBlue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const AtlasDesignSystemShowcaseScreen(),
                  ),
                );
              },
            ),
          ),

          const _SettingsDivider(),

          const _SettingsSectionHeader(
            title: 'Support & About',
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AtlasSpacing.md,
            ),
            child: Column(
              children: [
                AtlasActionRow(
                  title: 'Help & Roadmap',
                  description:
                  'Review planned features, guidance, and future Atlas tools.',
                  icon: Icons.route_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const HelpRoadmapScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: AtlasSpacing.sm,
                ),
                const AtlasActionRow(
                  title: 'Funko Vault',
                  description: 'Version 1.0',
                  icon: Icons.info_outline,
                  showChevron: false,
                  compact: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsHeaderCard extends StatelessWidget {
  const _SettingsHeaderCard();

  @override
  Widget build(BuildContext context) {
    return const AtlasGlassCard(
      accentColor: AtlasColors.vaultGold,
      child: AtlasSectionHeader(
        title: 'Atlas Control Center',
        subtitle:
        'Manage your collector profile, Premium tools, vault health, preferences, backup, and security.',
        icon: Icons.settings_suggest_rounded,
        accentColor: AtlasColors.vaultGold,
      ),
    );
  }
}

class _SettingsSectionHeader extends StatelessWidget {
  const _SettingsSectionHeader({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AtlasSpacing.md,
        AtlasSpacing.lg,
        AtlasSpacing.md,
        AtlasSpacing.sm,
      ),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AtlasSpacing.md,
        AtlasSpacing.lg,
        AtlasSpacing.md,
        0,
      ),
      child: Divider(
        color: AtlasColors.textSecondary.withValues(
          alpha: 0.18,
        ),
      ),
    );
  }
}