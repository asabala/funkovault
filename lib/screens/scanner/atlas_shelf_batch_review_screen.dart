import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../atlas/catalog/models/atlas_catalog_product.dart';
import '../../atlas/scan/acquisition/atlas_continuous_scan_coordinator.dart';
import '../../atlas/scan/results/atlas_continuous_scan_result.dart';
import '../../atlas/shelf/atlas_shelf_session_coordinator.dart';
import '../../atlas/shelf/models/atlas_shelf_expected_item.dart';
import '../../atlas/shelf/models/atlas_shelf_observation.dart';
import '../../atlas/shelf/models/atlas_shelf_proposed_action.dart';
import '../../atlas/shelf/models/atlas_shelf_reconciliation_result.dart';
import '../../screens/pop/add_pop_screen.dart';
import '../../services/app_state.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/atlas_glass_panel.dart';
import '../../widgets/atlas/components/atlas_empty_state.dart';
import '../../widgets/atlas/components/atlas_info_banner.dart';
import '../../widgets/atlas/components/atlas_section_header.dart';
import '../../widgets/atlas/components/atlas_status_chip.dart';
import '../../widgets/vault/vault_scroll_view.dart';
import 'atlas_haul_review_screen.dart';

class AtlasShelfBatchReviewScreen extends StatefulWidget {
  const AtlasShelfBatchReviewScreen({
    super.key,
    required this.collectionName,
    required this.shelfCoordinator,
    required this.resolutionCoordinator,
  });

  final String collectionName;
  final AtlasShelfSessionCoordinator shelfCoordinator;
  final AtlasContinuousScanCoordinator resolutionCoordinator;

  @override
  State<AtlasShelfBatchReviewScreen> createState() =>
      _AtlasShelfBatchReviewScreenState();
}

class _AtlasShelfBatchReviewScreenState
    extends State<AtlasShelfBatchReviewScreen> {
  final Set<String> _savingActionIds = <String>{};
  final Set<String> _completedActionIds = <String>{};

  AtlasShelfReconciliationResult get _result {
    final result = widget.shelfCoordinator.session.reconciliation;
    if (result == null) {
      throw StateError('Shelf batch review requires a reconciled session.');
    }
    return result;
  }

  AtlasShelfObservation? _observationFor(String observationId) {
    for (final observation in _result.observations) {
      if (observation.observationId == observationId) return observation;
    }
    return null;
  }

  AtlasContinuousScanResult? _scanResultFor(AtlasShelfObservation observation) {
    for (final trackId in observation.sourceTrackIds.toList().reversed) {
      final result = widget.resolutionCoordinator.resultForTrack(trackId);
      if (result != null) return result;
    }
    return null;
  }

  Future<void> _reviewAction(AtlasShelfProposedAction action) async {
    if (_savingActionIds.contains(action.actionId) ||
        _completedActionIds.contains(action.actionId)) {
      return;
    }

    final AtlasShelfObservation? observation = _observationFor(
      action.observationId,
    );
    if (observation == null) return;

    switch (action.type) {
      case AtlasShelfProposedActionType.addToVault:
      case AtlasShelfProposedActionType.addAnotherCopy:
        await _runAddFlow(action, observation);
      case AtlasShelfProposedActionType.reviewVariant:
      case AtlasShelfProposedActionType.reviewObservation:
        await _openHaulReview();
    }
  }

  Future<void> _runAddFlow(
    AtlasShelfProposedAction action,
    AtlasShelfObservation observation,
  ) async {
    final AtlasContinuousScanResult? scanResult = _scanResultFor(observation);
    final AtlasCatalogProduct? product = scanResult?.resolvedCatalogProduct;

    if (product == null) {
      await _openHaulReview();
      return;
    }

    setState(() => _savingActionIds.add(action.actionId));
    try {
      final bool? added = await Navigator.push<bool>(
        context,
        MaterialPageRoute<bool>(
          builder: (_) => AddPopScreen(
            atlasProduct: product,
            collectionName: widget.collectionName,
            visualInspection:
                scanResult?.session.visualInspectionContribution?.inspection,
          ),
        ),
      );

      if (!mounted || added != true) return;

      bool committed = false;
      for (final trackId in observation.sourceTrackIds.toList().reversed) {
        if (widget.resolutionCoordinator.markCommitted(trackId: trackId)) {
          committed = true;
          break;
        }
      }

      if (!committed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The Vault save succeeded, but Atlas could not close the scanner ledger item. Review the haul before finishing.',
            ),
          ),
        );
        return;
      }

      setState(() => _completedActionIds.add(action.actionId));
    } finally {
      if (mounted) {
        setState(() => _savingActionIds.remove(action.actionId));
      } else {
        _savingActionIds.remove(action.actionId);
      }
    }
  }

  Future<void> _openHaulReview() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => AtlasHaulReviewScreen(
          coordinator: widget.resolutionCoordinator,
          collectionName: widget.collectionName,
        ),
      ),
    );

    if (mounted) {
      _refreshReconciliation();
    }
  }

  void _refreshReconciliation() {
    final AppState appState = context.read<AppState>();
    widget.shelfCoordinator.reconcile(
      collectionPops: appState.popsForCollection(widget.collectionName),
      ownedWishlistIdentityKeys: appState
          .ownedWishlistIdentityKeysForCollection(widget.collectionName),
    );
    setState(() {});
  }

  void _finishReview() {
    widget.shelfCoordinator.markCompleted();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final AtlasShelfReconciliationResult result = _result;

    return Scaffold(
      appBar: AppBar(title: const Text('Review Shelf Scan')),
      body: VaultScrollView(
        children: [
          AtlasGlassCard(
            accentColor: AtlasColors.vaultGold,
            child: AtlasSectionHeader(
              title: '📚 Shelf Reconciliation',
              subtitle:
                  'Review Atlas observations and confirm every Vault-changing action individually.',
              icon: Icons.fact_check_outlined,
              accentColor: AtlasColors.vaultGold,
              trailing: AtlasStatusChip(
                label: '${result.observations.length} observed',
                icon: Icons.inventory_2_outlined,
                accentColor: AtlasColors.vaultGold,
              ),
            ),
          ),
          const SizedBox(height: AtlasSpacing.md),
          const AtlasInfoBanner(
            title: 'Explicit confirmation required',
            message:
                'This screen never performs silent batch writes. Additions and copy changes still pass through the existing reviewed Vault save flow.',
            icon: Icons.verified_user_outlined,
            accentColor: AtlasColors.intelligenceBlue,
          ),
          const SizedBox(height: AtlasSpacing.lg),
          _SummaryCard(result: result),
          const SizedBox(height: AtlasSpacing.lg),
          _ExpectedShelfCard(expectedItems: result.expectedItems),
          const SizedBox(height: AtlasSpacing.lg),
          AtlasGlassCard(
            accentColor: AtlasColors.warning,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AtlasSectionHeader(
                  title: 'Staged Actions',
                  subtitle:
                      '${result.proposedActions.length} action${result.proposedActions.length == 1 ? '' : 's'} proposed. Nothing below is automatic.',
                  icon: Icons.rule_folder_outlined,
                  accentColor: AtlasColors.warning,
                ),
                const SizedBox(height: AtlasSpacing.md),
                if (result.proposedActions.isEmpty)
                  const AtlasEmptyState(
                    eyebrow: 'Shelf Review',
                    title: 'No Vault Changes Proposed',
                    message:
                        'Atlas did not find any shelf observations that require an add, extra-copy action, or identity review.',
                    icon: Icons.task_alt_rounded,
                    compact: true,
                  )
                else
                  ...result.proposedActions.map(
                    (action) => Padding(
                      padding: const EdgeInsets.only(bottom: AtlasSpacing.sm),
                      child: _ActionCard(
                        action: action,
                        observation: _observationFor(action.observationId),
                        isSaving: _savingActionIds.contains(action.actionId),
                        isComplete: _completedActionIds.contains(
                          action.actionId,
                        ),
                        onReview: () => _reviewAction(action),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AtlasSpacing.lg),
          AtlasGlassCard(
            accentColor: AtlasColors.intelligenceBlue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AtlasSectionHeader(
                  title: 'Set Completion Gaps',
                  subtitle:
                      'Completion gaps are separate from Vault-owned items that were simply not seen on this shelf.',
                  icon: Icons.extension_outlined,
                  accentColor: AtlasColors.intelligenceBlue,
                ),
                const SizedBox(height: AtlasSpacing.md),
                if (result.completionGaps.isEmpty)
                  Text(
                    'No catalog completion-gap context was attached to this shelf pass.',
                    style: AtlasTypography.bodySmall.copyWith(
                      color: AtlasColors.textSecondary,
                    ),
                  )
                else
                  ...result.completionGaps.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: AtlasSpacing.sm),
                      child: AtlasGlassPanel(child: Text(item.displayName)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AtlasSpacing.xl),
          FilledButton.icon(
            key: const ValueKey('finish-shelf-review'),
            onPressed: _finishReview,
            icon: const Icon(Icons.check_circle_outline_rounded),
            label: const Text('Finish Shelf Review'),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.result});

  final AtlasShelfReconciliationResult result;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      accentColor: AtlasColors.intelligenceBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AtlasSectionHeader(
            title: 'Shelf Snapshot',
            subtitle: 'Physical observations compared with the scoped Vault.',
            icon: Icons.analytics_outlined,
            accentColor: AtlasColors.intelligenceBlue,
          ),
          const SizedBox(height: AtlasSpacing.md),
          Wrap(
            spacing: AtlasSpacing.sm,
            runSpacing: AtlasSpacing.sm,
            children: [
              AtlasStatusChip(
                label: '${result.ownedObservationCount} Owned',
                icon: Icons.inventory_2_rounded,
                accentColor: AtlasColors.success,
              ),
              AtlasStatusChip(
                label: '${result.notInVaultCount} Not in Vault',
                icon: Icons.add_box_outlined,
                accentColor: AtlasColors.intelligenceBlue,
              ),
              AtlasStatusChip(
                label: '${result.possibleVariantCount} Possible Variant',
                icon: Icons.layers_outlined,
                accentColor: AtlasColors.warning,
              ),
              AtlasStatusChip(
                label: '${result.extraCopyCount} Extra Copy',
                icon: Icons.content_copy_outlined,
                accentColor: AtlasColors.warning,
              ),
              AtlasStatusChip(
                label: '${result.needsReviewCount} Needs Review',
                icon: Icons.fact_check_outlined,
                accentColor: AtlasColors.warning,
              ),
              AtlasStatusChip(
                label: '${result.missingFromShelfCount} Missing From Shelf',
                icon: Icons.remove_circle_outline_rounded,
                accentColor: AtlasColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExpectedShelfCard extends StatelessWidget {
  const _ExpectedShelfCard({required this.expectedItems});

  final List<AtlasShelfExpectedItem> expectedItems;

  @override
  Widget build(BuildContext context) {
    final missing = expectedItems
        .where((item) => item.missingQuantity > 0)
        .toList();

    return AtlasGlassCard(
      accentColor: AtlasColors.vaultGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AtlasSectionHeader(
            title: 'Missing From This Shelf',
            subtitle: missing.isEmpty
                ? 'All scoped Vault quantities were observed during this pass.'
                : '${missing.length} Vault release${missing.length == 1 ? '' : 's'} had quantity not observed.',
            icon: Icons.inventory_2_outlined,
            accentColor: AtlasColors.vaultGold,
          ),
          if (missing.isNotEmpty) ...[
            const SizedBox(height: AtlasSpacing.md),
            ...missing.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AtlasSpacing.sm),
                child: AtlasGlassPanel(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.remove_circle_outline_rounded,
                        color: AtlasColors.textSecondary,
                      ),
                      const SizedBox(width: AtlasSpacing.md),
                      Expanded(child: Text(item.pop.name)),
                      Text('Missing ${item.missingQuantity}'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.action,
    required this.observation,
    required this.isSaving,
    required this.isComplete,
    required this.onReview,
  });

  final AtlasShelfProposedAction action;
  final AtlasShelfObservation? observation;
  final bool isSaving;
  final bool isComplete;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final String productName = observation?.product?.name.trim() ?? '';

    return AtlasGlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(_iconFor(action.type), color: _colorFor(action.type)),
              const SizedBox(width: AtlasSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      style: AtlasTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (productName.isNotEmpty)
                      Text(
                        productName,
                        style: AtlasTypography.bodySmall.copyWith(
                          color: AtlasColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              if (isComplete)
                const AtlasStatusChip(
                  label: 'Confirmed',
                  icon: Icons.check_circle_rounded,
                  accentColor: AtlasColors.success,
                  size: AtlasStatusChipSize.compact,
                ),
            ],
          ),
          const SizedBox(height: AtlasSpacing.sm),
          Text(action.explanation, style: AtlasTypography.bodySmall),
          const SizedBox(height: AtlasSpacing.md),
          FilledButton.icon(
            onPressed: isSaving || isComplete ? null : onReview,
            icon: isSaving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    isComplete
                        ? Icons.check_rounded
                        : Icons.fact_check_outlined,
                  ),
            label: Text(
              isComplete
                  ? 'Confirmed'
                  : isSaving
                  ? 'Saving...'
                  : _buttonLabel(action.type),
            ),
          ),
        ],
      ),
    );
  }

  static String _buttonLabel(AtlasShelfProposedActionType type) {
    return switch (type) {
      AtlasShelfProposedActionType.addToVault => 'Review & Add to Vault',
      AtlasShelfProposedActionType.addAnotherCopy => 'Review Extra Copy',
      AtlasShelfProposedActionType.reviewVariant => 'Review Variant',
      AtlasShelfProposedActionType.reviewObservation => 'Review Observation',
    };
  }

  static IconData _iconFor(AtlasShelfProposedActionType type) {
    return switch (type) {
      AtlasShelfProposedActionType.addToVault => Icons.add_box_outlined,
      AtlasShelfProposedActionType.addAnotherCopy =>
        Icons.content_copy_outlined,
      AtlasShelfProposedActionType.reviewVariant => Icons.layers_outlined,
      AtlasShelfProposedActionType.reviewObservation =>
        Icons.fact_check_outlined,
    };
  }

  static Color _colorFor(AtlasShelfProposedActionType type) {
    return switch (type) {
      AtlasShelfProposedActionType.addToVault => AtlasColors.intelligenceBlue,
      AtlasShelfProposedActionType.addAnotherCopy => AtlasColors.warning,
      AtlasShelfProposedActionType.reviewVariant => AtlasColors.warning,
      AtlasShelfProposedActionType.reviewObservation => AtlasColors.warning,
    };
  }
}
