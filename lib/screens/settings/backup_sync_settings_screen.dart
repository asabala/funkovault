import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/components/atlas_action_row.dart';
import '../../widgets/atlas/components/atlas_info_banner.dart';
import '../../widgets/atlas/components/atlas_section_header.dart';
import '../../widgets/atlas/components/atlas_status_chip.dart';

class BackupSyncSettingsScreen extends StatelessWidget {
  const BackupSyncSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Sync')),
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
                  title: 'Backup & Sync',
                  subtitle:
                      'Prepare cloud backup, restore, and multi-device sync options for your vault.',
                  icon: Icons.cloud_sync_rounded,
                  accentColor: AtlasColors.vaultGold,
                ),
              ),

              const SizedBox(height: AtlasSpacing.lg),

              const AtlasGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AtlasSectionHeader(
                      title: 'Backup Status',
                      subtitle:
                          'Atlas is currently using local vault data. Cloud backup and restore tools will be connected later.',
                      icon: Icons.storage_rounded,
                    ),

                    SizedBox(height: AtlasSpacing.lg),

                    AtlasActionRow(
                      title: 'Local Data',
                      description: 'Your vault is available on this device.',
                      icon: Icons.storage_rounded,
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
                      title: 'Cloud Backup',
                      description:
                          'Future backup support will protect your vault in the cloud.',
                      icon: Icons.cloud_queue_rounded,
                      showChevron: false,
                      compact: true,
                      badge: AtlasStatusChip(
                        label: 'Coming Soon',
                        accentColor: AtlasColors.vaultGold,
                        size: AtlasStatusChipSize.compact,
                      ),
                    ),

                    SizedBox(height: AtlasSpacing.sm),

                    AtlasActionRow(
                      title: 'Multi-Device Sync',
                      description:
                          'Future sync support will help keep devices aligned.',
                      icon: Icons.sync_rounded,
                      showChevron: false,
                      compact: true,
                      badge: AtlasStatusChip(
                        label: 'Future',
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
                      title: 'Future Sync Tools',
                      subtitle:
                          'These actions are staged now so backup and sync can be added safely later.',
                      icon: Icons.cloud_done_outlined,
                    ),

                    const SizedBox(height: AtlasSpacing.lg),

                    AtlasActionRow(
                      title: 'Cloud Backup',
                      description: 'Back up your vault to your Atlas account.',
                      icon: Icons.cloud_upload_outlined,
                      onTap: () {
                        _showComingSoonMessage(
                          context,
                          'Cloud backup is coming soon.',
                        );
                      },
                    ),

                    const SizedBox(height: AtlasSpacing.sm),

                    AtlasActionRow(
                      title: 'Restore Vault',
                      description: 'Restore vault data from a previous backup.',
                      icon: Icons.restore_rounded,
                      onTap: () {
                        _showComingSoonMessage(
                          context,
                          'Vault restore is coming soon.',
                        );
                      },
                    ),

                    const SizedBox(height: AtlasSpacing.sm),

                    AtlasActionRow(
                      title: 'Sync Devices',
                      description:
                          'Keep your collection available across devices.',
                      icon: Icons.devices_other_rounded,
                      onTap: () {
                        _showComingSoonMessage(
                          context,
                          'Device sync is coming soon.',
                        );
                      },
                    ),

                    const SizedBox(height: AtlasSpacing.sm),

                    AtlasActionRow(
                      title: 'Export Backup',
                      description:
                          'Create an export copy of your collection data.',
                      icon: Icons.file_download_outlined,
                      onTap: () {
                        _showComingSoonMessage(
                          context,
                          'Backup export is coming soon.',
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AtlasSpacing.lg),

              const AtlasInfoBanner(
                icon: Icons.info_outline_rounded,
                title: 'Data Safety',
                message:
                    'Backup and sync should be added carefully so vault data stays safe, recoverable, and consistent across devices.',
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
