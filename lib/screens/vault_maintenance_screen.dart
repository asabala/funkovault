import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../theme/atlas_colors.dart';
import '../theme/atlas_spacing.dart';
import '../theme/atlas_typography.dart';
import '../widgets/atlas/atlas_glass_card.dart';
import '../widgets/atlas/atlas_glass_panel.dart';
import '../widgets/vault_scroll_view.dart';

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
    final popCount = appState.selectedCollectionPops.length;

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
                  'Next we can add duplicate review tools here so Atlas can show possible duplicate groups without deleting anything automatically.',
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