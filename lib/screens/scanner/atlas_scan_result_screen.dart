import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:funkovault2/atlas/catalog/models/atlas_catalog_product.dart';
import 'package:funkovault2/atlas/catalog/services/atlas_barcode_catalog_resolver.dart';
import 'package:funkovault2/atlas/catalog/services/atlas_pop_factory.dart';
import 'package:funkovault2/atlas/intelligence/engines/atlas_scan_intelligence_engine.dart';
import 'package:funkovault2/atlas/intelligence/models/atlas_collector_summary.dart';
import 'package:funkovault2/atlas/intelligence/models/atlas_scan_intelligence.dart';
import 'package:funkovault2/atlas/scan/briefing/atlas_scan_briefing.dart';
import 'package:funkovault2/atlas/scan/briefing/atlas_scan_briefing_engine.dart';
import 'package:funkovault2/atlas/scan/models/scan_code.dart';
import 'package:funkovault2/atlas/scan/models/scan_session.dart';
import 'package:funkovault2/atlas/scan/workflow/identity_resolution_status.dart';
import 'package:funkovault2/models/pop.dart';
import 'package:funkovault2/screens/catalog/funko_catalog_screen.dart';
import 'package:funkovault2/screens/pop/add_pop_screen.dart';
import 'package:funkovault2/services/app_state.dart';
import 'package:funkovault2/widgets/scanner/atlas_collector_summary_card.dart';
import 'package:funkovault2/widgets/scanner/atlas_scan_briefing_card.dart';
import 'package:funkovault2/widgets/scanner/atlas_scan_intelligence_card.dart';

Future<void> _openCatalogProduct(
    BuildContext context,
    AtlasCatalogProduct product,
    ) {
  return Navigator.push<void>(
    context,
    MaterialPageRoute<void>(
      builder: (_) {
        return AddPopScreen(
          atlasProduct: product,
        );
      },
    ),
  );
}

Future<void> _openManualAdd(
    BuildContext context,
    ) {
  return Navigator.push<void>(
    context,
    MaterialPageRoute<void>(
      builder: (_) {
        return const AddPopScreen();
      },
    ),
  );
}

Future<void> _openCatalogSearch(
    BuildContext context,
    ) {
  return Navigator.push<void>(
    context,
    MaterialPageRoute<void>(
      builder: (_) {
        return const FunkoCatalogScreen();
      },
    ),
  );
}

class AtlasScanResultScreen extends StatelessWidget {
  const AtlasScanResultScreen({
    required this.session,
    required this.catalogResolution,
    super.key,
  });

  final ScanSession session;
  final AtlasBarcodeResolution catalogResolution;

  @override
  Widget build(BuildContext context) {
    final ScanCode? primaryCode =
        session.bestCandidate ?? _firstDetectedCode;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scan Result',
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: primaryCode == null
              ? const _NoBarcodeView()
              : _BarcodeResultView(
            session: session,
            code: primaryCode,
            catalogResolution: catalogResolution,
          ),
        ),
      ),
    );
  }

  ScanCode? get _firstDetectedCode {
    if (session.detectedCodes.isEmpty) {
      return null;
    }

    return session.detectedCodes.first;
  }
}

class _NoBarcodeView extends StatelessWidget {
  const _NoBarcodeView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 72,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              'No Barcode Detected',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 12,
            ),
            const Text(
              'Atlas could not find usable barcode evidence in this scan session.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 24,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.qr_code_scanner,
                ),
                label: const Text(
                  'Scan Again',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarcodeResultView extends StatelessWidget {
  const _BarcodeResultView({
    required this.session,
    required this.code,
    required this.catalogResolution,
  });

  final ScanSession session;
  final ScanCode code;
  final AtlasBarcodeResolution catalogResolution;

  @override
  Widget build(BuildContext context) {
    final AtlasScanBriefing briefing =
    AtlasScanBriefingEngine.build(session);

    final AtlasScanIntelligence intelligence =
    const AtlasScanIntelligenceEngine().processChecked(
      session,
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ResultHeader(
            session: session,
            code: code,
            resolution: catalogResolution,
          ),
          const SizedBox(
            height: 16,
          ),
          AtlasScanBriefingCard(
            briefing: briefing,
          ),
          const SizedBox(
            height: 16,
          ),
          AtlasScanIntelligenceCard(
            intelligence: intelligence,
          ),
          const SizedBox(
            height: 24,
          ),
          _CatalogResolutionCard(
            session: session,
            resolution: catalogResolution,
          ),
          const SizedBox(
            height: 16,
          ),
          _ScanEvidenceCard(
            session: session,
            code: code,
          ),
          const SizedBox(
            height: 24,
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.qr_code_scanner,
            ),
            label: const Text(
              'Scan Again',
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({
    required this.session,
    required this.code,
    required this.resolution,
  });

  final ScanSession session;
  final ScanCode code;
  final AtlasBarcodeResolution resolution;

  @override
  Widget build(BuildContext context) {
    final _ResultHeaderState headerState = _buildHeaderState();

    return Column(
      children: [
        Icon(
          headerState.icon,
          size: 72,
        ),
        const SizedBox(
          height: 16,
        ),
        Text(
          headerState.title,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          headerState.message,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  _ResultHeaderState _buildHeaderState() {
    switch (session.resolutionStatus) {
      case IdentityResolutionStatus.failed:
        return const _ResultHeaderState(
          title: 'Resolution Failed',
          message:
          'Atlas could not confidently identify this collectible. Review the scan evidence or try scanning again.',
          icon: Icons.error_outline_rounded,
        );

      case IdentityResolutionStatus.ambiguous:
        return const _ResultHeaderState(
          title: 'Review Required',
          message:
          'Atlas found multiple possible identities. Review the available matches before continuing.',
          icon: Icons.warning_amber_rounded,
        );

      case IdentityResolutionStatus.unresolved:
        return const _ResultHeaderState(
          title: 'Identity Not Resolved',
          message:
          'Atlas could not determine a confirmed product identity from the available evidence.',
          icon: Icons.help_outline_rounded,
        );

      case IdentityResolutionStatus.pendingSync:
        return const _ResultHeaderState(
          title: 'Sync Pending',
          message:
          'Atlas resolved this product locally. Additional cloud intelligence will be synchronized when available.',
          icon: Icons.cloud_sync_outlined,
        );

      case IdentityResolutionStatus.resolvedLocal:
        return const _ResultHeaderState(
          title: 'Product Resolved',
          message:
          'Atlas successfully identified this collectible using local intelligence.',
          icon: Icons.check_circle_outline_rounded,
        );

      case IdentityResolutionStatus.resolvedRemote:
        return const _ResultHeaderState(
          title: 'Product Resolved',
          message:
          'Atlas successfully identified this collectible using connected catalog intelligence.',
          icon: Icons.check_circle_outline_rounded,
        );

      case IdentityResolutionStatus.resolving:
        return const _ResultHeaderState(
          title: 'Resolving Product',
          message:
          'Atlas is processing the available evidence and attempting to identify this collectible.',
          icon: Icons.manage_search_rounded,
        );

      case IdentityResolutionStatus.notStarted:
        return _catalogFallbackState();
    }
  }

  _ResultHeaderState _catalogFallbackState() {
    switch (resolution.status) {
      case AtlasBarcodeResolutionStatus.invalidBarcode:
        return _ResultHeaderState(
          title: 'Barcode Detected',
          message: code.isProductBarcode
              ? 'Atlas detected the code, but it could not be used for a catalog lookup.'
              : 'Atlas detected a code, but it is not a supported product barcode.',
          icon: Icons.warning_amber_rounded,
        );

      case AtlasBarcodeResolutionStatus.noMatch:
        return const _ResultHeaderState(
          title: 'No Catalog Match',
          message:
          'The barcode was valid, but Atlas did not find a matching catalog product.',
          icon: Icons.search_off_rounded,
        );

      case AtlasBarcodeResolutionStatus.singleMatch:
        return const _ResultHeaderState(
          title: 'Product Found',
          message:
          'Atlas found one catalog product matching this barcode.',
          icon: Icons.check_circle_outline_rounded,
        );

      case AtlasBarcodeResolutionStatus.multipleMatches:
        return const _ResultHeaderState(
          title: 'Possible Matches Found',
          message:
          'Atlas found more than one catalog product. Review the choices before continuing.',
          icon: Icons.content_copy_rounded,
        );
    }
  }
}

class _ResultHeaderState {
  const _ResultHeaderState({
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;
}

class _CatalogResolutionCard extends StatelessWidget {
  const _CatalogResolutionCard({
    required this.session,
    required this.resolution,
  });

  final ScanSession session;
  final AtlasBarcodeResolution resolution;

  @override
  Widget build(BuildContext context) {
    switch (resolution.status) {
      case AtlasBarcodeResolutionStatus.invalidBarcode:
        return _CatalogMessageCard(
          icon: Icons.info_outline_rounded,
          title: 'Catalog Lookup Not Available',
          message:
          'Try scanning the UPC or EAN product barcode printed on the box.',
          actions: [
            OutlinedButton.icon(
              onPressed: () {
                _openManualAdd(context);
              },
              icon: const Icon(
                Icons.edit_note_rounded,
              ),
              label: const Text(
                'Enter Product Manually',
              ),
            ),
          ],
        );

      case AtlasBarcodeResolutionStatus.noMatch:
        final AppState appState = context.watch<AppState>();

        final List<Pop> vaultMatches =
        _CollectionMatchSummary.findVaultMatchesByBarcode(
          barcode: resolution.barcode,
          vaultPops: appState.selectedCollectionPops,
        );

        if (vaultMatches.isNotEmpty) {
          return _VaultBarcodeMatchCard(
            vaultMatches: vaultMatches,
            collectionName: appState.selectedCollection,
          );
        }

        return _CatalogMessageCard(
          icon: Icons.inventory_2_outlined,
          title: 'Product Not Yet Identified',
          message:
          'Barcode ${resolution.barcode} is not currently connected to an Atlas catalog product and was not found in your selected Vault.',
          actions: [
            FilledButton.icon(
              onPressed: () {
                _openCatalogSearch(context);
              },
              icon: const Icon(
                Icons.search_rounded,
              ),
              label: const Text(
                'Search Broader Catalog',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            OutlinedButton.icon(
              onPressed: () {
                _openManualAdd(context);
              },
              icon: const Icon(
                Icons.edit_note_rounded,
              ),
              label: const Text(
                'Enter Product Manually',
              ),
            ),
          ],
        );

      case AtlasBarcodeResolutionStatus.singleMatch:
        return _CatalogProductCard(
          product:
          session.catalogProduct ??
              resolution.singleMatch!,
          scannedBarcode: resolution.barcode,
        );

      case AtlasBarcodeResolutionStatus.multipleMatches:
        return _MultipleCatalogMatchesCard(
          products: resolution.matches,
        );
    }
  }
}

class _CatalogMessageCard extends StatelessWidget {
  const _CatalogMessageCard({
    required this.icon,
    required this.title,
    required this.message,
    this.actions = const <Widget>[],
  });

  final IconData icon;
  final String title;
  final String message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              icon,
              size: 36,
            ),
            const SizedBox(
              height: 12,
            ),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            if (actions.isNotEmpty) ...[
              const SizedBox(
                height: 20,
              ),
              ...actions,
            ],
          ],
        ),
      ),
    );
  }
}

class _MultipleCatalogMatchesCard extends StatelessWidget {
  const _MultipleCatalogMatchesCard({
    required this.products,
  });

  final List<AtlasCatalogProduct> products;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${products.length} Possible Catalog Matches',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            const Text(
              'Atlas will not automatically choose between products that share a barcode. Review each product and select the correct match.',
            ),
            const SizedBox(
              height: 16,
            ),
            for (
            int index = 0;
            index < products.length;
            index++
            ) ...[
              _CatalogProductSummary(
                product: products[index],
              ),
              const SizedBox(
                height: 12,
              ),
              OutlinedButton.icon(
                onPressed: () {
                  _openCatalogProduct(
                    context,
                    products[index],
                  );
                },
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                ),
                label: const Text(
                  'Add This Product',
                ),
              ),
              if (index < products.length - 1)
                const Divider(
                  height: 32,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VaultBarcodeMatchCard extends StatelessWidget {
  const _VaultBarcodeMatchCard({
    required this.vaultMatches,
    required this.collectionName,
  });

  final List<Pop> vaultMatches;
  final String collectionName;

  @override
  Widget build(BuildContext context) {
    final Pop primaryPop = vaultMatches.first;

    final _CollectionMatchSummary collectionSummary =
    _CollectionMatchSummary(
      exactMatches: List<Pop>.unmodifiable(
        vaultMatches,
      ),
      relatedMatches: const <Pop>[],
    );

    final AtlasCollectorSummary collectorSummary =
    AtlasCollectorSummary.build(
      product: primaryPop,
      exactMatches: collectionSummary.exactMatches,
      relatedMatches: collectionSummary.relatedMatches,
      collectionName: collectionName,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AtlasCollectorSummaryCard(
          summary: collectorSummary,
          imageUrl: primaryPop.imageUrl,
        ),
        const SizedBox(
          height: 20,
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.qr_code_scanner_rounded,
          ),
          label: const Text(
            'Scan Another Product',
          ),
        ),
      ],
    );
  }
}

class _CatalogProductCard extends StatelessWidget {
  const _CatalogProductCard({
    required this.product,
    required this.scannedBarcode,
  });

  final AtlasCatalogProduct product;
  final String scannedBarcode;

  @override
  Widget build(BuildContext context) {
    final AppState appState = context.watch<AppState>();

    final Pop scannedPop = AtlasPopFactory.createFromCatalog(
      product: product,
    );

    final _CollectionMatchSummary collectionSummary =
    _CollectionMatchSummary.evaluate(
      scannedPop: scannedPop,
      scannedBarcode: scannedBarcode,
      vaultPops: appState.selectedCollectionPops,
    );

    final AtlasCollectorSummary collectorSummary =
    AtlasCollectorSummary.build(
      product: scannedPop,
      exactMatches: collectionSummary.exactMatches,
      relatedMatches: collectionSummary.relatedMatches,
      collectionName: appState.selectedCollection,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AtlasCollectorSummaryCard(
          summary: collectorSummary,
          imageUrl: scannedPop.imageUrl,
        ),
        const SizedBox(
          height: 20,
        ),
        FilledButton.icon(
          onPressed: () {
            _openCatalogProduct(
              context,
              product,
            );
          },
          icon: Icon(
            collectionSummary.hasExactMatch
                ? Icons.add_circle_outline_rounded
                : Icons.add_circle_rounded,
          ),
          label: Text(
            collectionSummary.hasExactMatch
                ? 'Add Another Copy'
                : 'Add to Vault',
          ),
        ),
      ],
    );
  }
}

class _CollectionMatchSummary {
  const _CollectionMatchSummary({
    required this.exactMatches,
    required this.relatedMatches,
  });

  final List<Pop> exactMatches;
  final List<Pop> relatedMatches;

  bool get hasExactMatch {
    return exactMatches.isNotEmpty;
  }

  bool get hasRelatedMatches {
    return relatedMatches.isNotEmpty;
  }

  int get exactQuantity {
    return exactMatches.fold<int>(
      0,
          (int total, Pop pop) {
        return total + pop.quantity;
      },
    );
  }

  static List<Pop> findVaultMatchesByBarcode({
    required String barcode,
    required List<Pop> vaultPops,
  }) {
    final Set<String> scannedBarcodeCandidates =
    _barcodeCandidates(
      barcode,
    );

    if (scannedBarcodeCandidates.isEmpty) {
      return const <Pop>[];
    }

    final List<Pop> matches = <Pop>[];

    for (final Pop vaultPop in vaultPops) {
      final Set<String> vaultBarcodeCandidates =
      _barcodeCandidates(
        vaultPop.sourceUpc,
      );

      final bool isBarcodeMatch =
          vaultBarcodeCandidates.isNotEmpty &&
              scannedBarcodeCandidates.any(
                vaultBarcodeCandidates.contains,
              );

      if (isBarcodeMatch) {
        matches.add(vaultPop);
      }
    }

    return List<Pop>.unmodifiable(
      matches,
    );
  }

  static _CollectionMatchSummary evaluate({
    required Pop scannedPop,
    required String scannedBarcode,
    required List<Pop> vaultPops,
  }) {
    final Set<String> scannedBarcodeCandidates =
    _barcodeCandidates(
      scannedBarcode,
    );

    final String scannedRecordKey =
    scannedPop.collectionRecordKey.trim();

    final String scannedSimilarityKey =
    scannedPop.similarityReviewKey.trim();

    final List<Pop> exactMatches = <Pop>[];
    final List<Pop> relatedMatches = <Pop>[];

    for (final Pop vaultPop in vaultPops) {
      final Set<String> vaultBarcodeCandidates =
      _barcodeCandidates(
        vaultPop.sourceUpc,
      );

      final bool isBarcodeMatch =
          scannedBarcodeCandidates.isNotEmpty &&
              vaultBarcodeCandidates.isNotEmpty &&
              scannedBarcodeCandidates.any(
                vaultBarcodeCandidates.contains,
              );

      if (isBarcodeMatch) {
        exactMatches.add(vaultPop);
        continue;
      }

      final String vaultRecordKey =
      vaultPop.collectionRecordKey.trim();

      final bool isRecordMatch =
          scannedRecordKey.isNotEmpty &&
              vaultRecordKey == scannedRecordKey;

      if (isRecordMatch) {
        exactMatches.add(vaultPop);
        continue;
      }

      final String vaultSimilarityKey =
      vaultPop.similarityReviewKey.trim();

      final bool isRelatedMatch =
          scannedSimilarityKey.isNotEmpty &&
              vaultSimilarityKey == scannedSimilarityKey;

      if (isRelatedMatch) {
        relatedMatches.add(vaultPop);
      }
    }

    return _CollectionMatchSummary(
      exactMatches: List<Pop>.unmodifiable(
        exactMatches,
      ),
      relatedMatches: List<Pop>.unmodifiable(
        relatedMatches,
      ),
    );
  }

  static Set<String> _barcodeCandidates(
      String value,
      ) {
    final String normalizedBarcode =
    _normalizeBarcode(value);

    if (normalizedBarcode.isEmpty) {
      return const <String>{};
    }

    final Set<String> candidates = <String>{
      normalizedBarcode,
    };

    if (normalizedBarcode.length == 13 &&
        normalizedBarcode.startsWith('0')) {
      candidates.add(
        normalizedBarcode.substring(1),
      );
    }

    if (normalizedBarcode.length == 12) {
      candidates.add(
        '0$normalizedBarcode',
      );
    }

    return candidates;
  }

  static String _normalizeBarcode(
      String value,
      ) {
    return value.replaceAll(
      RegExp(r'[^0-9A-Za-z]'),
      '',
    );
  }
}

class _CatalogProductSummary extends StatelessWidget {
  const _CatalogProductSummary({
    required this.product,
  });

  final AtlasCatalogProduct product;

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = <Widget>[
      _ResultRow(
        label: 'Product',
        value: product.displayName,
      ),
    ];

    _addOptionalRow(
      rows: rows,
      label: 'Number',
      value: product.productNumber,
    );

    _addOptionalRow(
      rows: rows,
      label: 'Variant',
      value: product.variantName,
    );

    _addOptionalRow(
      rows: rows,
      label: 'Series',
      value: product.series,
    );

    _addOptionalRow(
      rows: rows,
      label: 'Line',
      value: product.productLine,
    );

    _addOptionalRow(
      rows: rows,
      label: 'Brand',
      value: product.brand,
    );

    rows.add(
      _ResultRow(
        label: 'Atlas ID',
        value: product.productId.value,
        selectable: true,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (
        int index = 0;
        index < rows.length;
        index++
        ) ...[
          rows[index],
          if (index < rows.length - 1)
            const Divider(),
        ],
      ],
    );
  }

  static void _addOptionalRow({
    required List<Widget> rows,
    required String label,
    required String? value,
  }) {
    final String normalizedValue =
        value?.trim() ?? '';

    if (normalizedValue.isEmpty) {
      return;
    }

    rows.add(
      _ResultRow(
        label: label,
        value: normalizedValue,
      ),
    );
  }
}

class _ScanEvidenceCard extends StatelessWidget {
  const _ScanEvidenceCard({
    required this.session,
    required this.code,
  });

  final ScanSession session;
  final ScanCode code;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scan Evidence',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            _ResultRow(
              label: 'Barcode',
              value: code.normalizedValue,
              selectable: true,
            ),
            const Divider(),
            _ResultRow(
              label: 'Format',
              value: _formatLabel(
                code.format,
              ),
            ),
            const Divider(),
            _ResultRow(
              label: 'Source',
              value: _sourceLabel(
                code.source,
              ),
            ),
            const Divider(),
            _ResultRow(
              label: 'Validation',
              value: code.isValid
                  ? 'Passed'
                  : 'Failed',
            ),
            const Divider(),
            _ResultRow(
              label: 'Evidence',
              value:
              '${session.contributionCount} contribution${session.contributionCount == 1 ? '' : 's'}',
            ),
            const Divider(),
            _ResultRow(
              label: 'Identity',
              value: _resolutionStatusLabel(
                session.resolutionStatus,
              ),
            ),
            if (session.atlasProductId != null) ...[
              const Divider(),
              _ResultRow(
                label: 'Atlas Product ID',
                value: session.atlasProductId!.value,
                selectable: true,
              ),
            ],
            const Divider(),
            _ResultRow(
              label: 'User Action',
              value: session.requiresUserAction
                  ? 'Review required'
                  : 'No action required',
            ),
            if (session.requiresVariantConfirmation) ...[
              const Divider(),
              const _ResultRow(
                label: 'Variant',
                value: 'Confirmation required',
              ),
            ],
            const Divider(),
            _ResultRow(
              label: 'Session Status',
              value: _statusLabel(
                session.status,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLabel(
      ScanCodeFormat format,
      ) {
    switch (format) {
      case ScanCodeFormat.upcA:
        return 'UPC-A';

      case ScanCodeFormat.upcE:
        return 'UPC-E';

      case ScanCodeFormat.ean8:
        return 'EAN-8';

      case ScanCodeFormat.ean13:
        return 'EAN-13';

      case ScanCodeFormat.qrCode:
        return 'QR Code';

      case ScanCodeFormat.unknown:
        return 'Unknown';
    }
  }

  String _sourceLabel(
      ScanCodeSource source,
      ) {
    switch (source) {
      case ScanCodeSource.camera:
        return 'Camera';

      case ScanCodeSource.manualEntry:
        return 'Manual Entry';

      case ScanCodeSource.importedData:
        return 'Imported Data';

      case ScanCodeSource.externalProvider:
        return 'External Provider';
    }
  }

  String _resolutionStatusLabel(
      IdentityResolutionStatus status,
      ) {
    switch (status) {
      case IdentityResolutionStatus.notStarted:
        return 'Not started';

      case IdentityResolutionStatus.resolving:
        return 'Resolving identity';

      case IdentityResolutionStatus.resolvedLocal:
        return 'Resolved locally';

      case IdentityResolutionStatus.resolvedRemote:
        return 'Resolved remotely';

      case IdentityResolutionStatus.pendingSync:
        return 'Resolved — sync pending';

      case IdentityResolutionStatus.ambiguous:
        return 'Multiple possible identities';

      case IdentityResolutionStatus.unresolved:
        return 'Identity not resolved';

      case IdentityResolutionStatus.failed:
        return 'Resolution failed';
    }
  }

  String _statusLabel(
      ScanSessionStatus status,
      ) {
    switch (status) {
      case ScanSessionStatus.created:
        return 'Created';

      case ScanSessionStatus.scanning:
        return 'Scanning';

      case ScanSessionStatus.analyzing:
        return 'Analyzing';

      case ScanSessionStatus.resolving:
        return 'Resolving';

      case ScanSessionStatus.awaitingConfirmation:
        return 'Awaiting Confirmation';

      case ScanSessionStatus.completed:
        return 'Completed';

      case ScanSessionStatus.cancelled:
        return 'Cancelled';

      case ScanSessionStatus.failed:
        return 'Failed';
    }
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.value,
    this.selectable = false,
  });

  final String label;
  final String value;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: selectable
                ? SelectableText(
              value,
            )
                : Text(
              value,
            ),
          ),
        ],
      ),
    );
  }
}