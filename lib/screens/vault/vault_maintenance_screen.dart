import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../atlas/catalog/controllers/atlas_catalog_maintenance_controller.dart';
import '../../services/app_state.dart';
import '../../services/duplicate_review_service.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/atlas_glass_panel.dart';
import '../../widgets/vault/vault_scroll_view.dart';
import 'possible_duplicates_screen.dart';

class VaultMaintenanceScreen extends StatefulWidget {
  const VaultMaintenanceScreen({super.key});

  @override
  State<VaultMaintenanceScreen> createState() =>
      _VaultMaintenanceScreenState();
}

class _VaultMaintenanceScreenState extends State<VaultMaintenanceScreen> {
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
          content: Text('Atlas catalog sync completed successfully.'),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      final String message = _catalogSyncErrorMessage(error);

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
    final String errorText = error.toString().trim();

    if (errorText.isEmpty) {
      return 'Atlas catalog sync failed. Please try again.';
    }

    return 'Atlas catalog sync failed: $errorText';
  }

  String _formatSyncDateTime(DateTime value) {
    final DateTime localValue = value.toLocal();

    final String month = localValue.month.toString().padLeft(2, '0');
    final String day = localValue.day.toString().padLeft(2, '0');
    final String year = localValue.year.toString();

    final int hourValue =
    localValue.hour == 0 ? 12 : (localValue.hour > 12
        ? localValue.hour - 12
        : localValue.hour);

    final String hour = hourValue.toString();
    final String minute = localValue.minute.toString().padLeft(2, '0');
    final String period = localValue.hour >= 12 ? 'PM' : 'AM';

    return '$month/$day/$year at $hour:$minute $period';
  }

  Future<void> _confirmClearCollection(BuildContext context) async {
    final AppState appState = context.read<AppState>();
    final String collectionName = appState.selectedCollection;
    final int popCount = appState.selectedCollectionPops.length;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Clear Current Collection?'),
          content: Text(
            'This will remove $popCount Pops from "$collectionName". '
                'This should only be used if you want to start fresh before '
                're-importing your CSV.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Clear Collection'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await appState.clearSelectedCollection();

    if (!context.mounted) {
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
    final AppState appState = context.watch<AppState>();
    final String collectionName = appState.selectedCollection;
    final pops = appState.selectedCollectionPops;
    final int popCount = pops.length;

    final duplicateReport =
    const DuplicateReviewService().buildReport(pops);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vault Maintenance'),
      ),
      body: VaultScrollView(
        children: [
          AtlasGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vault Maintenance',
                  style: AtlasTypography.headingLarge,
                ),
                const SizedBox(height: AtlasSpacing.sm),
                Text(
                  'Review, repair, or reset your current collection before '
                      'importing new CSV data.',
                  style: AtlasTypography.bodyMedium.copyWith(
                    color: AtlasColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AtlasSpacing.lg),
                AtlasGlassPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        collectionName,
                        style: AtlasTypography.headingSmall,
                      ),
                      const SizedBox(height: AtlasSpacing.xs),
                      Text(
                        '$popCount Pops currently saved in this collection.',
                        style: AtlasTypography.bodyMedium.copyWith(
                          color: AtlasColors.textSecondary,
                        ),
                      ),
                    ],
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.cloud_sync_rounded,
                      color: AtlasColors.vaultGold,
                    ),
                    const SizedBox(width: AtlasSpacing.sm),
                    Expanded(
                      child: Text(
                        'Atlas Catalog',
                        style: AtlasTypography.headingSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AtlasSpacing.sm),
                Text(
                  'Synchronize the bundled Pop Vinyl catalog with the Atlas '
                      'catalog stored in Supabase.',
                  style: AtlasTypography.bodyMedium.copyWith(
                    color: AtlasColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AtlasSpacing.lg),
                AtlasGlassPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MaintenanceSummaryLine(
                        label: 'Status',
                        value: _isCatalogSyncing
                            ? 'Syncing'
                            : _catalogSyncError != null
                            ? 'Failed'
                            : _lastCatalogSyncAt != null
                            ? 'Completed'
                            : 'Ready',
                      ),
                      if (_lastCatalogSyncAt != null) ...[
                        const SizedBox(height: AtlasSpacing.sm),
                        Text(
                          'Last completed ${_formatSyncDateTime(
                            _lastCatalogSyncAt!,
                          )}',
                          style: AtlasTypography.bodySmall.copyWith(
                            color: AtlasColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (_catalogSyncError != null) ...[
                  const SizedBox(height: AtlasSpacing.md),
                  AtlasGlassPanel(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(width: AtlasSpacing.sm),
                        Expanded(
                          child: Text(
                            _catalogSyncError!,
                            style: AtlasTypography.bodySmall.copyWith(
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AtlasSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed:
                    _isCatalogSyncing ? null : _syncAtlasCatalog,
                    icon: _isCatalogSyncing
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : const Icon(Icons.sync_rounded),
                    label: Text(
                      _isCatalogSyncing
                          ? 'Syncing Atlas Catalog...'
                          : 'Sync Atlas Catalog',
                    ),
                  ),
                ),
                const SizedBox(height: AtlasSpacing.sm),
                Text(
                  'The sync may take some time depending on the number of '
                      'catalog products being processed. Do not close the app '
                      'while the sync is running.',
                  style: AtlasTypography.bodySmall.copyWith(
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
                  'Atlas Identity Intelligence',
                  style: AtlasTypography.headingSmall,
                ),
                const SizedBox(height: AtlasSpacing.sm),
                Text(
                  'Atlas analyzes your collection for exact duplicates and '
                      'related collectible releases before you make any cleanup '
                      'decisions. Nothing is changed automatically.',
                  style: AtlasTypography.bodyMedium.copyWith(
                    color: AtlasColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AtlasSpacing.lg),
                AtlasGlassPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MaintenanceSummaryLine(
                        label: 'Exact Duplicate Groups',
                        value:
                        '${duplicateReport.exactDuplicateGroupCount}',
                      ),
                      const SizedBox(height: AtlasSpacing.xs),
                      _MaintenanceSummaryLine(
                        label: 'Identity Review Groups',
                        value: '${duplicateReport.reviewGroupCount}',
                      ),
                      const SizedBox(height: AtlasSpacing.xs),
                      _MaintenanceSummaryLine(
                        label: 'Total Identity Groups',
                        value: '${duplicateReport.totalGroups}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AtlasSpacing.md),
                AtlasGlassPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Atlas Intelligence Notes',
                        style: AtlasTypography.bodyMedium.copyWith(
                          color: AtlasColors.vaultGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AtlasSpacing.sm),
                      Text(
                        'Exact Duplicate Groups appear to represent the same '
                            'physical release and may be cleanup candidates after '
                            'review.',
                        style: AtlasTypography.bodySmall.copyWith(
                          color: AtlasColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AtlasSpacing.xs),
                      Text(
                        'Identity Review Groups represent related collectible '
                            'releases. Atlas may classify them as variant, sticker, '
                            'finish, packaging, production-run, retailer, event, '
                            'signature, or authentication differences.',
                        style: AtlasTypography.bodySmall.copyWith(
                          color: AtlasColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AtlasSpacing.xs),
                      Text(
                        'Atlas never auto-merges or auto-deletes collectibles. '
                            'Identity Intelligence provides recommendations only; '
                            'every decision remains under your control.',
                        style: AtlasTypography.bodySmall.copyWith(
                          color: AtlasColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AtlasSpacing.lg),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) =>
                        const PossibleDuplicatesScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.manage_search_rounded),
                  label:
                  const Text('Open Atlas Identity Intelligence'),
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
                  'Clean Slate Option',
                  style: AtlasTypography.headingSmall,
                ),
                const SizedBox(height: AtlasSpacing.sm),
                Text(
                  'Use this only if you decide the current vault data should '
                      'be cleared before re-importing a clean HobbyDB export.',
                  style: AtlasTypography.bodyMedium.copyWith(
                    color: AtlasColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AtlasSpacing.lg),
                FilledButton.icon(
                  onPressed: popCount == 0
                      ? null
                      : () => _confirmClearCollection(context),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Clear Current Collection'),
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
                  'Coming Next',
                  style: AtlasTypography.headingSmall,
                ),
                const SizedBox(height: AtlasSpacing.sm),
                Text(
                  'Coming next: safe cleanup tools, confidence scoring, '
                      'production-run detection, catalog verification, detailed '
                      'catalog sync results, and Atlas AI recommendations powered '
                      'by Identity Intelligence.',
                  style: AtlasTypography.bodyMedium.copyWith(
                    color: AtlasColors.textSecondary,
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

class _MaintenanceSummaryLine extends StatelessWidget {
  const _MaintenanceSummaryLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AtlasTypography.bodyMedium.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AtlasSpacing.sm,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AtlasColors.vaultGold.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AtlasColors.vaultGold.withValues(alpha: 0.42),
            ),
          ),
          child: Text(
            value,
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.vaultGold,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}