import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../atlas/catalog/controllers/atlas_catalog_maintenance_controller.dart';
import '../../services/app_state.dart';
import '../../services/duplicate_review_service.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/components/atlas_action_row.dart';
import '../../widgets/atlas/components/atlas_info_banner.dart';
import '../../widgets/atlas/components/atlas_section_header.dart';
import '../../widgets/atlas/components/atlas_status_chip.dart';
import '../../widgets/vault/vault_scroll_view.dart';
import 'possible_duplicates_screen.dart';

class VaultMaintenanceScreen extends StatefulWidget {
  const VaultMaintenanceScreen({
    super.key,
  });

  @override
  State<VaultMaintenanceScreen> createState() {
    return _VaultMaintenanceScreenState();
  }
}

class _VaultMaintenanceScreenState
    extends State<VaultMaintenanceScreen> {
  final AtlasCatalogMaintenanceController _catalogController =
  AtlasCatalogMaintenanceController();

  bool _isCatalogSyncing = false;
  DateTime? _lastCatalogSyncAt;
  String? _catalogSyncError;

  Future<void> _syncAtlasCatalog() async {
    if (_isCatalogSyncing) {
      return;
    }

    setState(() {
      _isCatalogSyncing = true;
      _catalogSyncError = null;
    });

    try {
      await _catalogController.syncCatalog();

      if (!mounted) {
        return;
      }

      setState(() {
        _lastCatalogSyncAt = DateTime.now();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Atlas catalog sync completed successfully.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      final String message =
      _catalogSyncErrorMessage(error);

      setState(() {
        _catalogSyncError = message;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCatalogSyncing = false;
        });
      }
    }
  }

  String _catalogSyncErrorMessage(Object error) {
    final String errorText =
    error.toString().trim();

    if (errorText.isEmpty) {
      return 'Atlas catalog sync failed. Please try again.';
    }

    return 'Atlas catalog sync failed: $errorText';
  }

  String _formatSyncDateTime(DateTime value) {
    final DateTime localValue =
    value.toLocal();

    final String month =
    localValue.month.toString().padLeft(2, '0');

    final String day =
    localValue.day.toString().padLeft(2, '0');

    final String year =
    localValue.year.toString();

    final int hourValue = localValue.hour == 0
        ? 12
        : (localValue.hour > 12
        ? localValue.hour - 12
        : localValue.hour);

    final String hour =
    hourValue.toString();

    final String minute =
    localValue.minute.toString().padLeft(2, '0');

    final String period =
    localValue.hour >= 12 ? 'PM' : 'AM';

    return '$month/$day/$year at $hour:$minute $period';
  }

  Future<void> _confirmClearCollection(
      BuildContext context,
      ) async {
    final AppState appState =
    context.read<AppState>();

    final String collectionName =
        appState.selectedCollection;

    final int popCount =
        appState.popsForCollection(collectionName).length;

    final bool? confirmed =
    await showDialog<bool>(
      context: context,
      builder: (
          BuildContext dialogContext,
          ) {
        return AlertDialog(
          title: const Text(
            'Clear Current Collection?',
          ),
          content: Text(
            'This will remove $popCount Pops from "$collectionName". '
                'This should only be used if you want to start fresh before '
                're-importing your CSV.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Clear Collection',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final bool cleared =
    await appState.clearCollection(
      collectionName,
    );

    if (!context.mounted) {
      return;
    }

    if (!cleared) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not clear "$collectionName" because that collection no longer exists.',
          ),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Cleared $popCount Pops from $collectionName.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppState appState =
    context.watch<AppState>();

    final String collectionName =
        appState.selectedCollection;

    final pops =
        appState.selectedCollectionPops;

    final int popCount = pops.length;

    final duplicateReport =
    const DuplicateReviewService()
        .buildReport(pops);

    final String catalogStatus =
    _isCatalogSyncing
        ? 'Syncing'
        : _catalogSyncError != null
        ? 'Failed'
        : _lastCatalogSyncAt != null
        ? 'Completed'
        : 'Ready';

    final Color catalogStatusColor =
    _catalogSyncError != null
        ? AtlasColors.warning
        : AtlasColors.vaultGold;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vault Maintenance',
        ),
      ),
      body: VaultScrollView(
        children: [
          AtlasGlassCard(
            accentColor: AtlasColors.vaultGold,
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const AtlasSectionHeader(
                  title: 'Vault Maintenance',
                  subtitle:
                  'Review, repair, or reset your current collection before importing new CSV data.',
                  icon:
                  Icons.build_circle_outlined,
                  accentColor:
                  AtlasColors.vaultGold,
                ),

                const SizedBox(
                  height: AtlasSpacing.lg,
                ),

                AtlasActionRow(
                  title: collectionName,
                  description:
                  '$popCount Pops currently saved in this collection.',
                  icon:
                  Icons.inventory_2_outlined,
                  showChevron: false,
                  compact: true,
                  badge: AtlasStatusChip(
                    label: '$popCount Pops',
                    accentColor:
                    AtlasColors.vaultGold,
                    size:
                    AtlasStatusChipSize.compact,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: AtlasSpacing.lg,
          ),

          AtlasGlassCard(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const AtlasSectionHeader(
                  title: 'Atlas Catalog',
                  subtitle:
                  'Synchronize the bundled Pop Vinyl catalog with the Atlas catalog stored in Supabase.',
                  icon:
                  Icons.cloud_sync_rounded,
                ),

                const SizedBox(
                  height: AtlasSpacing.lg,
                ),

                AtlasActionRow(
                  title: 'Catalog Status',
                  description:
                  _lastCatalogSyncAt != null
                      ? 'Last completed ${_formatSyncDateTime(_lastCatalogSyncAt!)}'
                      : 'Atlas Catalog is ready for synchronization.',
                  icon: _isCatalogSyncing
                      ? Icons.sync_rounded
                      : _catalogSyncError != null
                      ? Icons.error_outline_rounded
                      : Icons.cloud_done_outlined,
                  showChevron: false,
                  compact: true,
                  badge: AtlasStatusChip(
                    label: catalogStatus,
                    accentColor:
                    catalogStatusColor,
                    size:
                    AtlasStatusChipSize.compact,
                  ),
                ),

                if (_catalogSyncError != null) ...[
                  const SizedBox(
                    height: AtlasSpacing.md,
                  ),
                  AtlasInfoBanner(
                    icon:
                    Icons.error_outline_rounded,
                    title:
                    'Catalog Sync Failed',
                    message:
                    _catalogSyncError!,
                    accentColor:
                    AtlasColors.warning,
                  ),
                ],

                const SizedBox(
                  height: AtlasSpacing.lg,
                ),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isCatalogSyncing
                        ? null
                        : _syncAtlasCatalog,
                    icon: _isCatalogSyncing
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : const Icon(
                      Icons.sync_rounded,
                    ),
                    label: Text(
                      _isCatalogSyncing
                          ? 'Syncing Atlas Catalog...'
                          : 'Sync Atlas Catalog',
                    ),
                  ),
                ),

                const SizedBox(
                  height: AtlasSpacing.md,
                ),

                const AtlasInfoBanner(
                  icon:
                  Icons.schedule_rounded,
                  title:
                  'Catalog Sync',
                  message:
                  'The sync may take some time depending on the number of catalog products being processed. Do not close the app while the sync is running.',
                ),
              ],
            ),
          ),

          const SizedBox(
            height: AtlasSpacing.lg,
          ),

          AtlasGlassCard(
            accentColor:
            AtlasColors.vaultGold,
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const AtlasSectionHeader(
                  title:
                  'Atlas Identity Intelligence',
                  subtitle:
                  'Atlas analyzes your collection for exact duplicates and related collectible releases before you make cleanup decisions. Nothing is changed automatically.',
                  icon:
                  Icons.manage_search_rounded,
                  accentColor:
                  AtlasColors.vaultGold,
                ),

                const SizedBox(
                  height: AtlasSpacing.lg,
                ),

                Wrap(
                  spacing: AtlasSpacing.sm,
                  runSpacing: AtlasSpacing.sm,
                  children: [
                    AtlasStatusChip(
                      label:
                      '${duplicateReport.exactDuplicateGroupCount} Exact Duplicates',
                      icon:
                      Icons.content_copy_rounded,
                      accentColor:
                      AtlasColors.vaultGold,
                    ),
                    AtlasStatusChip(
                      label:
                      '${duplicateReport.reviewGroupCount} Review Groups',
                      icon:
                      Icons.compare_arrows_rounded,
                      accentColor:
                      AtlasColors.vaultGold,
                    ),
                    AtlasStatusChip(
                      label:
                      '${duplicateReport.totalGroups} Total Groups',
                      icon:
                      Icons.inventory_2_outlined,
                      accentColor:
                      AtlasColors.vaultGold,
                    ),
                  ],
                ),

                const SizedBox(
                  height: AtlasSpacing.lg,
                ),

                const AtlasInfoBanner(
                  icon:
                  Icons.psychology_alt_outlined,
                  title:
                  'Atlas Intelligence Notes',
                  message:
                  'Exact Duplicate Groups may represent the same physical release and can be cleanup candidates after review.\n\n'
                      'Identity Review Groups represent related collectible releases and may include variant, sticker, finish, packaging, production-run, retailer, event, signature, or authentication differences.\n\n'
                      'Atlas never auto-merges or auto-deletes collectibles. Identity Intelligence provides recommendations only; every decision remains under your control.',
                  accentColor:
                  AtlasColors.vaultGold,
                ),

                const SizedBox(
                  height: AtlasSpacing.lg,
                ),

                AtlasActionRow(
                  title:
                  'Open Atlas Identity Intelligence',
                  description:
                  'Review exact duplicate and related collectible groups before making cleanup decisions.',
                  icon:
                  Icons.manage_search_rounded,
                  accentColor:
                  AtlasColors.vaultGold,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) =>
                        const PossibleDuplicatesScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(
            height: AtlasSpacing.lg,
          ),

          AtlasGlassCard(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const AtlasSectionHeader(
                  title:
                  'Clean Slate Option',
                  subtitle:
                  'Use this only if you decide the current vault data should be cleared before re-importing a clean HobbyDB export.',
                  icon:
                  Icons.delete_outline_rounded,
                ),

                const SizedBox(
                  height: AtlasSpacing.lg,
                ),

                AtlasActionRow(
                  title:
                  'Clear Current Collection',
                  description: popCount == 0
                      ? 'This collection is already empty.'
                      : 'Permanently remove all $popCount Pops from $collectionName.',
                  icon:
                  Icons.delete_outline_rounded,
                  accentColor:
                  AtlasColors.warning,
                  showChevron: popCount > 0,
                  onTap: popCount == 0
                      ? null
                      : () {
                    _confirmClearCollection(
                      context,
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
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                AtlasSectionHeader(
                  title: 'Coming Next',
                  subtitle:
                  'Safe cleanup tools, confidence scoring, production-run detection, catalog verification, detailed catalog sync results, and Atlas AI recommendations powered by Identity Intelligence.',
                  icon:
                  Icons.upcoming_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}