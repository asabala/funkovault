import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/app_state.dart';
import '../../services/duplicate_review_service.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/atlas_glass_panel.dart';
import '../../widgets/vault_scroll_view.dart';
import 'possible_duplicates_screen.dart';

class VaultMaintenanceScreen extends StatelessWidget {
  const VaultMaintenanceScreen({super.key});

  Future<void> _confirmClearCollection(BuildContext context) async {
    final appState = context.read<AppState>();
    final collectionName = appState.selectedCollection;
    final popCount = appState.selectedCollectionPops.length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear Current Collection?'),
          content: Text(
            'This will remove $popCount Pops from "$collectionName". '
                'This should only be used if you want to start fresh before re-importing your CSV.',
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
    final appState = context.watch<AppState>();
    final collectionName = appState.selectedCollection;
    final pops = appState.selectedCollectionPops;
    final popCount = pops.length;

    final duplicateReport = const DuplicateReviewService().buildReport(pops);
    final sameIdentityGroups = duplicateReport.sameIdentityGroups;
    final possibleVariantGroups = duplicateReport.possibleVariantGroups;

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
                  'Review, repair, or reset your current collection before importing new CSV data.',
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
                Text(
                  'Duplicate Review',
                  style: AtlasTypography.headingSmall,
                ),
                const SizedBox(height: AtlasSpacing.sm),
                Text(
                  'Review possible duplicate Pops before deleting, merging, or resetting anything. This does not change your vault.',
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
                        label: 'Same Identity Groups',
                        value: '${sameIdentityGroups.length}',
                      ),
                      const SizedBox(height: AtlasSpacing.xs),
                      _MaintenanceSummaryLine(
                        label: 'Possible Variant Groups',
                        value: '${possibleVariantGroups.length}',
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
                        'Review Safety Note',
                        style: AtlasTypography.bodyMedium.copyWith(
                          color: AtlasColors.vaultGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AtlasSpacing.sm),
                      Text(
                        'Same Identity Groups may be cleanup candidates, but they should still be reviewed first.',
                        style: AtlasTypography.bodySmall.copyWith(
                          color: AtlasColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AtlasSpacing.xs),
                      Text(
                        'Possible Variant Groups are often legitimate Funko variants such as chase, glow, metallic, exclusive, stickered, limited edition, or signed Pops.',
                        style: AtlasTypography.bodySmall.copyWith(
                          color: AtlasColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AtlasSpacing.xs),
                      Text(
                        'Atlas will not auto-merge or auto-delete Funko variants.',
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
                      MaterialPageRoute(
                        builder: (_) => const PossibleDuplicatesScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.manage_search_rounded),
                  label: const Text('Review Possible Duplicates'),
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
                  'Use this only if you decide the current vault data should be cleared before re-importing a clean HobbyDB export.',
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
                  'Next we can add safe cleanup tools for same-identity groups, but only after review. Atlas will not auto-merge Funko variants.',
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