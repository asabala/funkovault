import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/atlas_glass_panel.dart';

class BackupSyncSettingsScreen extends StatelessWidget {
  const BackupSyncSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Sync'),
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
                      'Backup & Sync',
                      style: AtlasTypography.headingLarge,
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    Text(
                      'Prepare cloud backup, restore, and multi-device sync options for your vault.',
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
                      'Backup Status',
                      style: AtlasTypography.headingSmall,
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    Text(
                      'Atlas is currently using local vault data. Cloud backup and restore tools will be connected later.',
                      style: AtlasTypography.bodyMedium.copyWith(
                        color: AtlasColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.lg),
                    const _BackupStatusPanel(
                      icon: Icons.storage_rounded,
                      title: 'Local Data',
                      message: 'Your vault is available on this device.',
                      status: 'Active',
                    ),
                    SizedBox(height: AtlasSpacing.sm),
                    const _BackupStatusPanel(
                      icon: Icons.cloud_queue_rounded,
                      title: 'Cloud Backup',
                      message: 'Future backup support will protect your vault in the cloud.',
                      status: 'Coming Soon',
                    ),
                    SizedBox(height: AtlasSpacing.sm),
                    const _BackupStatusPanel(
                      icon: Icons.sync_rounded,
                      title: 'Multi-Device Sync',
                      message: 'Future sync support will help keep devices aligned.',
                      status: 'Future',
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
                      'Future Sync Tools',
                      style: AtlasTypography.headingSmall,
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    Text(
                      'These actions are staged now so backup and sync can be added safely later.',
                      style: AtlasTypography.bodyMedium.copyWith(
                        color: AtlasColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.lg),
                    _BackupActionRow(
                      icon: Icons.cloud_upload_outlined,
                      title: 'Cloud Backup',
                      subtitle: 'Back up your vault to your Atlas account.',
                      onTap: () => _showComingSoonMessage(
                        context,
                        'Cloud backup is coming soon.',
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    _BackupActionRow(
                      icon: Icons.restore_rounded,
                      title: 'Restore Vault',
                      subtitle: 'Restore vault data from a previous backup.',
                      onTap: () => _showComingSoonMessage(
                        context,
                        'Vault restore is coming soon.',
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    _BackupActionRow(
                      icon: Icons.devices_other_rounded,
                      title: 'Sync Devices',
                      subtitle: 'Keep your collection available across devices.',
                      onTap: () => _showComingSoonMessage(
                        context,
                        'Device sync is coming soon.',
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    _BackupActionRow(
                      icon: Icons.file_download_outlined,
                      title: 'Export Backup',
                      subtitle: 'Create an export copy of your collection data.',
                      onTap: () => _showComingSoonMessage(
                        context,
                        'Backup export is coming soon.',
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
                        'Backup and sync should be added carefully so vault data stays safe, recoverable, and consistent across devices.',
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

class _BackupStatusPanel extends StatelessWidget {
  const _BackupStatusPanel({
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
          _BackupStatusBadge(
            label: status,
          ),
        ],
      ),
    );
  }
}

class _BackupActionRow extends StatelessWidget {
  const _BackupActionRow({
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

class _BackupStatusBadge extends StatelessWidget {
  const _BackupStatusBadge({
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