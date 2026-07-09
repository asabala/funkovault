import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import 'backup_sync_settings_screen.dart';
import 'help_roadmap_screen.dart';
import 'import_csv_screen.dart';
import 'notifications_settings_screen.dart';
import 'premium_settings_screen.dart';
import 'security_settings_screen.dart';
import 'vault_preferences_screen.dart';
import '../profile/edit_collector_profile_screen.dart';
import '../vault/vault_health_screen.dart';
import '../vault/vault_maintenance_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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
          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Collector Profile',
            subtitle: 'Update your name, title, bio, and collector details',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditCollectorProfileScreen(),
                ),
              );
            },
          ),
          _SettingsTile(
            icon: Icons.workspace_premium_outlined,
            title: 'Premium',
            subtitle: 'Manage Premium features, upgrades, and advanced tools',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PremiumSettingsScreen(),
                ),
              );
            },
          ),
          const Divider(),

          const _SettingsSectionHeader(
            title: 'Collection Tools',
          ),
          _SettingsTile(
            icon: Icons.upload_file,
            title: 'Import Collection CSV',
            subtitle: 'Import a HobbyDB export',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ImportCsvScreen(),
                ),
              );
            },
          ),
          _SettingsTile(
            icon: Icons.build_circle_outlined,
            title: 'Vault Maintenance',
            subtitle: 'Review, repair, or reset your current collection',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const VaultMaintenanceScreen(),
                ),
              );
            },
          ),
          _SettingsTile(
            icon: Icons.health_and_safety_outlined,
            title: 'Vault Health',
            subtitle: 'Review health score, cleanup priority, and premium health insights',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const VaultHealthScreen(),
                ),
              );
            },
          ),
          const Divider(),

          const _SettingsSectionHeader(
            title: 'Preferences',
          ),
          _SettingsTile(
            icon: Icons.tune_outlined,
            title: 'Vault Preferences',
            subtitle: 'Manage saved views, image defaults, filters, and sorting',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const VaultPreferencesScreen(),
                ),
              );
            },
          ),
          _SettingsTile(
            icon: Icons.cloud_sync_outlined,
            title: 'Backup & Sync',
            subtitle: 'Prepare cloud backup, restore, and sync options',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BackupSyncSettingsScreen(),
                ),
              );
            },
          ),
          _SettingsTile(
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            subtitle: 'Manage future drop alerts, cleanup reminders, and value updates',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsSettingsScreen(),
                ),
              );
            },
          ),
          _SettingsTile(
            icon: Icons.security_outlined,
            title: 'Security',
            subtitle: 'Manage account protection and future two-step verification',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SecuritySettingsScreen(),
                ),
              );
            },
          ),
          const Divider(),

          const _SettingsSectionHeader(
            title: 'Support & About',
          ),
          _SettingsTile(
            icon: Icons.route_outlined,
            title: 'Help & Roadmap',
            subtitle: 'Review planned features, guidance, and future Atlas tools',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HelpRoadmapScreen(),
                ),
              );
            },
          ),
          const ListTile(
            leading: Icon(
              Icons.info_outline,
            ),
            title: Text(
              'Funko Vault',
            ),
            subtitle: Text(
              'Version 1.0',
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
    return AtlasGlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AtlasColors.vaultGold.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.settings_suggest_rounded,
              color: AtlasColors.vaultGold,
            ),
          ),
          const SizedBox(width: AtlasSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Atlas Control Center',
                  style: AtlasTypography.headingSmall,
                ),
                const SizedBox(height: AtlasSpacing.xs),
                Text(
                  'Manage your collector profile, Premium tools, vault health, preferences, backup, and security.',
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

class _SettingsSectionHeader extends StatelessWidget {
  const _SettingsSectionHeader({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        20,
        16,
        8,
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

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
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
    return ListTile(
      leading: Icon(
        icon,
      ),
      title: Text(
        title,
      ),
      subtitle: Text(
        subtitle,
      ),
      trailing: const Icon(
        Icons.chevron_right,
      ),
      onTap: onTap,
    );
  }
}