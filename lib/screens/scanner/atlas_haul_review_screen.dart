import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:funkovault2/atlas/catalog/services/atlas_pop_factory.dart';
import 'package:funkovault2/atlas/catalog/models/atlas_catalog_product.dart';
import 'package:funkovault2/atlas/intelligence/engines/atlas_collector_insight_engine.dart';
import 'package:funkovault2/atlas/scan/acquisition/atlas_continuous_scan_coordinator.dart';
import 'package:funkovault2/atlas/scan/ledger/atlas_scan_ledger_entry.dart';
import 'package:funkovault2/atlas/scan/results/atlas_continuous_scan_result.dart';
import 'package:funkovault2/models/pop.dart';
import 'package:funkovault2/screens/pop/add_pop_screen.dart';
import 'package:funkovault2/services/app_state.dart';
import 'package:funkovault2/theme/atlas_colors.dart';
import 'package:funkovault2/theme/atlas_spacing.dart';
import 'package:funkovault2/widgets/atlas/atlas_glass_card.dart';
import 'package:funkovault2/widgets/atlas/components/atlas_section_header.dart';
import 'package:funkovault2/widgets/atlas/components/atlas_status_chip.dart';

class AtlasHaulReviewScreen extends StatefulWidget {
  const AtlasHaulReviewScreen({
    super.key,
    required this.coordinator,
    required this.collectionName,
  });

  final AtlasContinuousScanCoordinator coordinator;
  final String collectionName;

  @override
  State<AtlasHaulReviewScreen> createState() => _AtlasHaulReviewScreenState();
}

class _AtlasHaulReviewScreenState extends State<AtlasHaulReviewScreen> {
  final Set<String> _savingTrackIds = <String>{};

  Future<void> _addResolvedItem({
    required AtlasScanLedgerEntry entry,
    required AtlasCatalogProduct product,
  }) async {
    if (_savingTrackIds.contains(entry.trackId)) {
      return;
    }

    setState(() {
      _savingTrackIds.add(entry.trackId);
    });

    try {
      final bool? added = await Navigator.push<bool>(
        context,
        MaterialPageRoute<bool>(
          builder: (_) {
            return AddPopScreen(
              atlasProduct: product,
              collectionName: widget.collectionName,
            );
          },
        ),
      );

      if (!mounted || added != true) {
        return;
      }

      final bool committed = widget.coordinator.markCommitted(
        trackId: entry.trackId,
      );

      if (!committed) {
        return;
      }

      setState(() {});

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              '${product.displayName} committed to ${widget.collectionName}.',
            ),
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _savingTrackIds.remove(entry.trackId);
        });
      } else {
        _savingTrackIds.remove(entry.trackId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppState appState = context.watch<AppState>();

    final List<AtlasScanLedgerEntry> entries =
        widget.coordinator.ledger.entries.toList(growable: false)..sort(
          (AtlasScanLedgerEntry a, AtlasScanLedgerEntry b) =>
              b.createdAt.compareTo(a.createdAt),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Review Haul')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AtlasSpacing.md),
          children: [
            AtlasGlassCard(
              accentColor: AtlasColors.vaultGold,
              child: AtlasSectionHeader(
                title: '📦 Review Haul',
                subtitle:
                    'Nothing enters the Vault until you explicitly save it.',
                icon: Icons.fact_check_outlined,
                accentColor: AtlasColors.vaultGold,
                trailing: AtlasStatusChip(
                  label:
                      '${entries.length} item${entries.length == 1 ? '' : 's'}',
                  icon: Icons.inventory_2_outlined,
                  accentColor: AtlasColors.vaultGold,
                ),
              ),
            ),
            const SizedBox(height: AtlasSpacing.md),
            if (entries.isEmpty)
              AtlasGlassCard(
                child: const Text('No haul items are ready for review yet.'),
              )
            else
              ...entries.map((AtlasScanLedgerEntry entry) {
                final AtlasContinuousScanResult? result = widget.coordinator
                    .resultForTrack(entry.trackId);

                return Padding(
                  padding: const EdgeInsets.only(bottom: AtlasSpacing.md),
                  child: _HaulReviewItemCard(
                    entry: entry,
                    result: result,
                    collectionName: widget.collectionName,
                    collectionPops: appState.popsForCollection(
                      widget.collectionName,
                    ),
                    ownedWishlistIdentityKeys: appState
                        .ownedWishlistIdentityKeysForCollection(
                          widget.collectionName,
                        ),
                    isSaving: _savingTrackIds.contains(entry.trackId),
                    onAdd: result?.resolvedCatalogProduct == null
                        ? null
                        : () => _addResolvedItem(
                            entry: entry,
                            product: result!.resolvedCatalogProduct!,
                          ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _HaulReviewItemCard extends StatelessWidget {
  const _HaulReviewItemCard({
    required this.entry,
    required this.result,
    required this.collectionName,
    required this.collectionPops,
    required this.ownedWishlistIdentityKeys,
    required this.isSaving,
    required this.onAdd,
  });

  final AtlasScanLedgerEntry entry;
  final AtlasContinuousScanResult? result;
  final String collectionName;
  final List<Pop> collectionPops;
  final Set<String> ownedWishlistIdentityKeys;
  final bool isSaving;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final AtlasCatalogProduct? catalogProduct = result?.resolvedCatalogProduct;

    bool isOwned = false;
    bool isWishlisted = false;
    int ownedCopyCount = 0;
    int relatedMatchCount = 0;

    final AtlasContinuousScanResult? scanResult = result;

    if (catalogProduct != null && scanResult != null) {
      final Pop productPop = AtlasPopFactory.createFromCatalog(
        product: catalogProduct,
      );

      final insight = const AtlasCollectorInsightEngine().evaluateScan(
        session: scanResult.session,
        product: productPop,
        scannedBarcode: entry.stableCode.normalizedValue,
        collectionPops: collectionPops,
        collectionName: collectionName,
        ownedWishlistIdentityKeys: ownedWishlistIdentityKeys,
      );

      isOwned = insight.state.isOwned;
      isWishlisted = insight.state.isWishlisted;
      ownedCopyCount = insight.state.ownedMatches.fold<int>(
        0,
        (int total, Pop pop) => total + pop.quantity,
      );
      relatedMatchCount = insight.state.relatedMatches.length;
    }

    final Color accentColor = _accentForStatus(entry.status);
    final String title =
        catalogProduct?.displayName ??
        'Barcode ${entry.stableCode.normalizedValue}';

    return AtlasGlassCard(
      accentColor: accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AtlasSectionHeader(
            title: title,
            subtitle: _statusMessage(entry),
            icon: _iconForStatus(entry.status),
            accentColor: accentColor,
            trailing: AtlasStatusChip(
              label: _statusLabel(entry.status),
              icon: _iconForStatus(entry.status),
              accentColor: accentColor,
            ),
          ),
          if (catalogProduct != null) ...[
            const SizedBox(height: AtlasSpacing.md),
            Wrap(
              spacing: AtlasSpacing.sm,
              runSpacing: AtlasSpacing.sm,
              children: [
                AtlasStatusChip(
                  label: isOwned ? 'Owned ×$ownedCopyCount' : 'Not Owned',
                  icon: isOwned
                      ? Icons.inventory_2_rounded
                      : Icons.inventory_2_outlined,
                  accentColor: isOwned
                      ? AtlasColors.success
                      : AtlasColors.textSecondary,
                ),
                AtlasStatusChip(
                  label: isWishlisted ? 'Wishlisted' : 'Not Wishlisted',
                  icon: isWishlisted
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  accentColor: isWishlisted
                      ? AtlasColors.danger
                      : AtlasColors.textSecondary,
                ),
                if (relatedMatchCount > 0)
                  AtlasStatusChip(
                    label:
                        '$relatedMatchCount related variant${relatedMatchCount == 1 ? '' : 's'}',
                    icon: Icons.layers_outlined,
                    accentColor: AtlasColors.warning,
                  ),
              ],
            ),
          ],
          const SizedBox(height: AtlasSpacing.md),
          if (entry.isCommitted)
            FilledButton.icon(
              onPressed: null,
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text('Committed to Vault'),
            )
          else if (entry.isResolved && catalogProduct != null)
            FilledButton.icon(
              onPressed: isSaving ? null : onAdd,
              icon: isSaving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      isOwned
                          ? Icons.add_circle_outline_rounded
                          : Icons.inventory_2_outlined,
                    ),
              label: Text(
                isSaving
                    ? 'Saving...'
                    : isOwned
                    ? '➕ Add Another Copy'
                    : '➕ Add to Vault',
              ),
            )
          else if (entry.needsReview)
            const Text(
              '🔎 Atlas needs additional review before this item can be committed.',
              textAlign: TextAlign.center,
            )
          else if (entry.hasFailed)
            const Text(
              '⚠️ Resolution failed. Retry support is added in Scanner 4H.',
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  static String _statusLabel(AtlasScanLedgerStatus status) {
    return switch (status) {
      AtlasScanLedgerStatus.observed => 'Observed',
      AtlasScanLedgerStatus.queued => 'Queued',
      AtlasScanLedgerStatus.resolving => 'Resolving',
      AtlasScanLedgerStatus.resolved => 'Resolved',
      AtlasScanLedgerStatus.needsReview => 'Review',
      AtlasScanLedgerStatus.failed => 'Failed',
      AtlasScanLedgerStatus.committed => 'Committed',
    };
  }

  static String _statusMessage(AtlasScanLedgerEntry entry) {
    return switch (entry.status) {
      AtlasScanLedgerStatus.observed => 'Stable evidence captured.',
      AtlasScanLedgerStatus.queued => 'Waiting for an available resolver slot.',
      AtlasScanLedgerStatus.resolving =>
        'Atlas is resolving this item in the background.',
      AtlasScanLedgerStatus.resolved =>
        'Ready for explicit Vault review and save.',
      AtlasScanLedgerStatus.needsReview =>
        'Atlas could not confirm one unambiguous catalog identity.',
      AtlasScanLedgerStatus.failed =>
        entry.failureMessage?.trim().isNotEmpty == true
            ? entry.failureMessage!.trim()
            : 'Atlas could not complete resolution.',
      AtlasScanLedgerStatus.committed =>
        'This physical haul item has been committed.',
    };
  }

  static IconData _iconForStatus(AtlasScanLedgerStatus status) {
    return switch (status) {
      AtlasScanLedgerStatus.observed => Icons.visibility_outlined,
      AtlasScanLedgerStatus.queued => Icons.schedule_rounded,
      AtlasScanLedgerStatus.resolving => Icons.sync_rounded,
      AtlasScanLedgerStatus.resolved => Icons.check_circle_outline_rounded,
      AtlasScanLedgerStatus.needsReview => Icons.fact_check_outlined,
      AtlasScanLedgerStatus.failed => Icons.error_outline_rounded,
      AtlasScanLedgerStatus.committed => Icons.inventory_rounded,
    };
  }

  static Color _accentForStatus(AtlasScanLedgerStatus status) {
    return switch (status) {
      AtlasScanLedgerStatus.observed => AtlasColors.textSecondary,
      AtlasScanLedgerStatus.queued => AtlasColors.warning,
      AtlasScanLedgerStatus.resolving => AtlasColors.intelligenceBlue,
      AtlasScanLedgerStatus.resolved => AtlasColors.success,
      AtlasScanLedgerStatus.needsReview => AtlasColors.warning,
      AtlasScanLedgerStatus.failed => AtlasColors.danger,
      AtlasScanLedgerStatus.committed => AtlasColors.success,
    };
  }
}
