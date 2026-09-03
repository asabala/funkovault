import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:funkovault2/atlas/catalog/models/atlas_catalog_product.dart';
import 'package:funkovault2/atlas/catalog/services/atlas_pop_factory.dart';
import 'package:funkovault2/atlas/intelligence/engines/atlas_collector_insight_engine.dart';
import 'package:funkovault2/atlas/scan/acquisition/atlas_continuous_scan_coordinator.dart';
import 'package:funkovault2/atlas/scan/ledger/atlas_scan_ledger_entry.dart';
import 'package:funkovault2/atlas/scan/results/atlas_continuous_scan_result.dart';
import 'package:funkovault2/screens/scanner/atlas_visual_inspection_screen.dart';
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

  Future<void> _inspectItem({
    required AtlasScanLedgerEntry entry,
    required AtlasContinuousScanResult result,
  }) async {
    final session = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AtlasVisualInspectionScreen(session: result.session),
      ),
    );
    if (!mounted || session == null) return;
    widget.coordinator.applyInspection(
      trackId: entry.trackId,
      session: session,
    );
    setState(() {});
  }

  Future<bool> _runSaveForTrack({
    required AtlasScanLedgerEntry entry,
    required Widget Function(BuildContext context) screenBuilder,
    required String successLabel,
  }) async {
    if (_savingTrackIds.contains(entry.trackId)) {
      return false;
    }

    setState(() {
      _savingTrackIds.add(entry.trackId);
    });

    try {
      final bool? added = await Navigator.push<bool>(
        context,
        MaterialPageRoute<bool>(builder: screenBuilder),
      );

      if (!mounted || added != true) {
        return false;
      }

      final bool committed = widget.coordinator.markCommitted(
        trackId: entry.trackId,
      );

      if (!committed) {
        return false;
      }

      setState(() {});

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              '$successLabel committed to ${widget.collectionName}.',
            ),
          ),
        );

      return true;
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

  Future<void> _addCatalogItem({
    required AtlasScanLedgerEntry entry,
    required AtlasCatalogProduct product,
  }) async {
    await _runSaveForTrack(
      entry: entry,
      successLabel: product.displayName,
      screenBuilder: (_) {
        final inspection = widget.coordinator
            .resultForTrack(entry.trackId)
            ?.session
            .visualInspectionContribution
            ?.inspection;
        return AddPopScreen(
          atlasProduct: product,
          collectionName: widget.collectionName,
          visualInspection: inspection,
        );
      },
    );
  }

  Future<void> _addManualItem({required AtlasScanLedgerEntry entry}) async {
    await _runSaveForTrack(
      entry: entry,
      successLabel: 'Reviewed item',
      screenBuilder: (_) {
        final inspection = widget.coordinator
            .resultForTrack(entry.trackId)
            ?.session
            .visualInspectionContribution
            ?.inspection;
        return AddPopScreen(
          collectionName: widget.collectionName,
          visualInspection: inspection,
        );
      },
    );
  }

  Future<void> _linkExistingVaultItem({
    required AtlasScanLedgerEntry entry,
    required List<Pop> collectionPops,
  }) async {
    if (_savingTrackIds.contains(entry.trackId)) {
      return;
    }

    final Pop? selected = await showModalBottomSheet<Pop>(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return _VaultItemPickerSheet(
          collectionName: widget.collectionName,
          collectionPops: collectionPops,
          scannedBarcode: entry.stableCode.normalizedValue,
        );
      },
    );

    if (!mounted || selected == null) {
      return;
    }

    final String scannedBarcode = entry.stableCode.normalizedValue.trim();
    final String existingBarcode = selected.sourceUpc.trim();

    if (existingBarcode.isNotEmpty && existingBarcode != scannedBarcode) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              '${selected.name} already has barcode $existingBarcode. Atlas did not overwrite it.',
            ),
          ),
        );
      return;
    }

    setState(() {
      _savingTrackIds.add(entry.trackId);
    });

    try {
      final AppState appState = context.read<AppState>();
      final Pop linkedPop = existingBarcode == scannedBarcode
          ? selected
          : selected.copyWith(sourceUpc: scannedBarcode);

      final Pop? persisted = await appState.updatePop(
        linkedPop,
        collectionName: widget.collectionName,
        existingRecordKey: selected.collectionRecordKey,
      );

      if (!mounted) {
        return;
      }

      if (persisted == null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'Atlas could not safely link that Vault item. Nothing was changed.',
              ),
            ),
          );
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
              'Linked barcode $scannedBarcode to ${persisted.name} and committed this haul item.',
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

  Future<void> _reviewCatalogMatches({
    required AtlasScanLedgerEntry entry,
    required AtlasContinuousScanResult result,
  }) async {
    final List<AtlasCatalogProduct> matches = result.catalogResolution.matches;

    if (matches.isEmpty) {
      return;
    }

    final AtlasCatalogProduct?
    selected = await showModalBottomSheet<AtlasCatalogProduct>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.72,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AtlasSpacing.lg),
                  child: AtlasSectionHeader(
                    title: '🔎 Review Catalog Matches',
                    subtitle:
                        'Choose the exact collectible before adding it to the Vault.',
                    icon: Icons.content_copy_rounded,
                    accentColor: AtlasColors.warning,
                    trailing: AtlasStatusChip(
                      label: '${matches.length} matches',
                      icon: Icons.layers_outlined,
                      accentColor: AtlasColors.warning,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AtlasSpacing.lg,
                      0,
                      AtlasSpacing.lg,
                      AtlasSpacing.lg,
                    ),
                    itemCount: matches.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AtlasSpacing.sm),
                    itemBuilder: (BuildContext context, int index) {
                      final AtlasCatalogProduct product = matches[index];

                      return AtlasGlassCard(
                        accentColor: AtlasColors.warning,
                        onTap: () {
                          Navigator.pop(sheetContext, product);
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.inventory_2_outlined,
                              color: AtlasColors.warning,
                            ),
                            const SizedBox(width: AtlasSpacing.md),
                            Expanded(
                              child: Text(
                                product.displayName,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || selected == null) {
      return;
    }

    await _addCatalogItem(entry: entry, product: selected);
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
                final AtlasCatalogProduct? resolvedProduct =
                    result?.resolvedCatalogProduct;
                final bool hasMultipleMatches =
                    result?.catalogResolution.hasMultipleMatches ?? false;

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
                    onRetry: entry.hasFailed
                        ? () {
                            final bool accepted = widget.coordinator
                                .retryFailedTrack(trackId: entry.trackId);

                            if (accepted && mounted) {
                              setState(() {});
                            }
                          }
                        : null,
                    onAdd: resolvedProduct == null
                        ? null
                        : () => _addCatalogItem(
                            entry: entry,
                            product: resolvedProduct,
                          ),
                    onReviewMatches: !hasMultipleMatches || result == null
                        ? null
                        : () => _reviewCatalogMatches(
                            entry: entry,
                            result: result,
                          ),
                    onFindExisting:
                        entry.needsReview &&
                            resolvedProduct == null &&
                            !hasMultipleMatches
                        ? () => _linkExistingVaultItem(
                            entry: entry,
                            collectionPops: appState.popsForCollection(
                              widget.collectionName,
                            ),
                          )
                        : null,
                    onManualAdd:
                        entry.needsReview &&
                            resolvedProduct == null &&
                            !hasMultipleMatches
                        ? () => _addManualItem(entry: entry)
                        : null,
                    onInspect: result == null || entry.isCommitted
                        ? null
                        : () => _inspectItem(entry: entry, result: result),
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
    required this.onRetry,
    required this.onAdd,
    required this.onReviewMatches,
    required this.onFindExisting,
    required this.onManualAdd,
    required this.onInspect,
  });

  final AtlasScanLedgerEntry entry;
  final AtlasContinuousScanResult? result;
  final String collectionName;
  final List<Pop> collectionPops;
  final Set<String> ownedWishlistIdentityKeys;
  final bool isSaving;
  final VoidCallback? onRetry;
  final VoidCallback? onAdd;
  final VoidCallback? onReviewMatches;
  final VoidCallback? onFindExisting;
  final VoidCallback? onManualAdd;
  final VoidCallback? onInspect;

  @override
  Widget build(BuildContext context) {
    final AtlasCatalogProduct? catalogProduct = result?.resolvedCatalogProduct;
    final AtlasContinuousScanResult? scanResult = result;

    bool isOwned = false;
    bool isWishlisted = false;
    int ownedCopyCount = 0;
    int relatedMatchCount = 0;

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
    final bool hasMultipleMatches =
        scanResult?.catalogResolution.hasMultipleMatches ?? false;
    final int matchCount = scanResult?.catalogResolution.matches.length ?? 0;

    final String title =
        catalogProduct?.displayName ??
        (hasMultipleMatches
            ? '$matchCount Possible Matches'
            : 'Barcode ${entry.stableCode.normalizedValue}');

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
          if (catalogProduct != null ||
              scanResult?.isOfflineResult == true ||
              scanResult?.requiresSync == true) ...[
            const SizedBox(height: AtlasSpacing.md),
            Wrap(
              spacing: AtlasSpacing.sm,
              runSpacing: AtlasSpacing.sm,
              children: [
                if (catalogProduct != null) ...[
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
                if (scanResult?.isOfflineResult == true)
                  const AtlasStatusChip(
                    label: 'Offline',
                    icon: Icons.cloud_off_outlined,
                    accentColor: AtlasColors.intelligenceBlue,
                  ),
                if (scanResult?.requiresSync == true)
                  const AtlasStatusChip(
                    label: 'Sync Pending',
                    icon: Icons.cloud_sync_outlined,
                    accentColor: AtlasColors.warning,
                  ),
              ],
            ),
          ],
          const SizedBox(height: AtlasSpacing.md),
          if (scanResult?.session.authenticityContribution != null) ...[
            AtlasStatusChip(
              label: _authenticityLabel(
                scanResult!.session.authenticityContribution!.assessment.status,
              ),
              icon: Icons.shield_outlined,
              accentColor:
                  scanResult
                      .session
                      .authenticityContribution!
                      .assessment
                      .requiresReview
                  ? AtlasColors.warning
                  : AtlasColors.success,
            ),
            const SizedBox(height: AtlasSpacing.sm),
          ],
          if (onInspect != null) ...[
            OutlinedButton.icon(
              onPressed: onInspect,
              icon: const Icon(Icons.verified_user_outlined),
              label: Text(
                scanResult?.session.hasAuthenticityAssessment == true
                    ? '🔎 Review Visual Inspection'
                    : '🔎 Visual Inspection',
              ),
            ),
            const SizedBox(height: AtlasSpacing.sm),
          ],
          if (entry.isCommitted)
            FilledButton.icon(
              onPressed: null,
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text('Committed to Vault'),
            )
          else if (entry.hasFailed)
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('🔄 Retry Resolution'),
            )
          else if ((entry.isResolved || entry.needsReview) &&
              catalogProduct != null)
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
                    : entry.needsReview
                    ? '🔎 Review & Add'
                    : isOwned
                    ? '➕ Add Another Copy'
                    : '➕ Add to Vault',
              ),
            )
          else if (entry.needsReview && hasMultipleMatches)
            FilledButton.icon(
              onPressed: onReviewMatches,
              icon: const Icon(Icons.content_copy_rounded),
              label: Text('🔎 Review $matchCount Matches'),
            )
          else if (entry.needsReview) ...[
            FilledButton.icon(
              onPressed: isSaving ? null : onFindExisting,
              icon: const Icon(Icons.link_rounded),
              label: const Text('🔗 Find Existing in Vault'),
            ),
            const SizedBox(height: AtlasSpacing.sm),
            OutlinedButton.icon(
              onPressed: isSaving ? null : onManualAdd,
              icon: const Icon(Icons.edit_note_rounded),
              label: const Text('➕ Add Manually'),
            ),
          ],
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

  static String _authenticityLabel(dynamic status) {
    return switch (status.name) {
      'strongEvidence' => 'Strong Evidence',
      'developingEvidence' => 'Developing Evidence',
      'reviewRecommended' => 'Review Recommended',
      _ => 'Insufficient Evidence',
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
        'Atlas needs your confirmation before this item can be committed.',
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

class _VaultItemPickerSheet extends StatefulWidget {
  const _VaultItemPickerSheet({
    required this.collectionName,
    required this.collectionPops,
    required this.scannedBarcode,
  });

  final String collectionName;
  final List<Pop> collectionPops;
  final String scannedBarcode;

  @override
  State<_VaultItemPickerSheet> createState() => _VaultItemPickerSheetState();
}

class _VaultItemPickerSheetState extends State<_VaultItemPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Pop> get _matches {
    final String query = _query.trim().toLowerCase();

    final List<Pop> pops = widget.collectionPops
        .where((Pop pop) {
          if (query.isEmpty) {
            return true;
          }

          final List<String> values = <String>[
            pop.name,
            pop.number,
            pop.series,
            pop.variant,
            pop.retailExclusive,
            pop.eventSticker,
            pop.limitedEdition,
            pop.signature,
            pop.sourceUpc,
          ];

          return values.any(
            (String value) => value.toLowerCase().contains(query),
          );
        })
        .toList(growable: false);

    pops.sort((Pop a, Pop b) {
      final int nameCompare = a.name.toLowerCase().compareTo(
        b.name.toLowerCase(),
      );
      if (nameCompare != 0) {
        return nameCompare;
      }
      return a.number.toLowerCase().compareTo(b.number.toLowerCase());
    });

    return pops;
  }

  @override
  Widget build(BuildContext context) {
    final List<Pop> matches = _matches;

    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.84,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AtlasSpacing.lg,
                AtlasSpacing.lg,
                AtlasSpacing.lg,
                AtlasSpacing.md,
              ),
              child: AtlasSectionHeader(
                title: '🔗 Find Existing in Vault',
                subtitle:
                    'Select the existing collectible that belongs to barcode ${widget.scannedBarcode}.',
                icon: Icons.link_rounded,
                accentColor: AtlasColors.intelligenceBlue,
                trailing: AtlasStatusChip(
                  label: widget.collectionName,
                  icon: Icons.inventory_2_outlined,
                  accentColor: AtlasColors.intelligenceBlue,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AtlasSpacing.lg),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  hintText: 'Search name, number, variant, sticker...',
                  border: OutlineInputBorder(),
                ),
                onChanged: (String value) {
                  setState(() {
                    _query = value;
                  });
                },
              ),
            ),
            const SizedBox(height: AtlasSpacing.md),
            Expanded(
              child: matches.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AtlasSpacing.lg),
                        child: Text(
                          'No matching Vault items. Try a different search or use Add Manually.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.separated(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(
                        AtlasSpacing.lg,
                        0,
                        AtlasSpacing.lg,
                        AtlasSpacing.lg,
                      ),
                      itemCount: matches.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AtlasSpacing.sm),
                      itemBuilder: (BuildContext context, int index) {
                        final Pop pop = matches[index];
                        final String barcode = pop.sourceUpc.trim();
                        final bool hasDifferentBarcode =
                            barcode.isNotEmpty &&
                            barcode != widget.scannedBarcode;

                        final List<String> details = <String>[
                          if (pop.number.trim().isNotEmpty)
                            '#${pop.number.trim()}',
                          if (pop.variant.trim().isNotEmpty &&
                              pop.variant.trim().toLowerCase() != 'common')
                            pop.variant.trim(),
                          if (pop.retailExclusive.trim().isNotEmpty &&
                              pop.retailExclusive.trim().toLowerCase() !=
                                  'none')
                            pop.retailExclusive.trim(),
                          if (pop.eventSticker.trim().isNotEmpty &&
                              pop.eventSticker.trim().toLowerCase() != 'none')
                            pop.eventSticker.trim(),
                          'Qty ${pop.quantity}',
                        ];

                        return AtlasGlassCard(
                          accentColor: hasDifferentBarcode
                              ? AtlasColors.warning
                              : AtlasColors.intelligenceBlue,
                          onTap: hasDifferentBarcode
                              ? null
                              : () {
                                  Navigator.pop(context, pop);
                                },
                          child: Row(
                            children: [
                              Icon(
                                hasDifferentBarcode
                                    ? Icons.warning_amber_rounded
                                    : Icons.inventory_2_outlined,
                                color: hasDifferentBarcode
                                    ? AtlasColors.warning
                                    : AtlasColors.intelligenceBlue,
                              ),
                              const SizedBox(width: AtlasSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pop.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    if (details.isNotEmpty) ...[
                                      const SizedBox(height: AtlasSpacing.xs),
                                      Text(
                                        details.join(' • '),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AtlasColors.textSecondary,
                                            ),
                                      ),
                                    ],
                                    if (hasDifferentBarcode) ...[
                                      const SizedBox(height: AtlasSpacing.xs),
                                      Text(
                                        'Already linked to $barcode',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AtlasColors.warning,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (!hasDifferentBarcode)
                                const Icon(Icons.chevron_right_rounded),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
