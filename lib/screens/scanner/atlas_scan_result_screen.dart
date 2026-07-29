import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:funkovault2/atlas/catalog/services/atlas_pop_factory.dart';
import 'package:funkovault2/atlas/catalog/models/atlas_catalog_product.dart';
import 'package:funkovault2/atlas/catalog/services/atlas_barcode_catalog_resolver.dart';
import 'package:funkovault2/atlas/scan/models/scan_code.dart';
import 'package:funkovault2/atlas/scan/models/scan_session.dart';
import 'package:funkovault2/models/pop.dart';
import 'package:funkovault2/screens/catalog/funko_catalog_screen.dart';
import 'package:funkovault2/screens/pop/add_pop_screen.dart';
import 'package:funkovault2/services/app_state.dart';

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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ResultHeader(
            code: code,
            resolution: catalogResolution,
          ),
          const SizedBox(
            height: 24,
          ),
          _CatalogResolutionCard(
            resolution: catalogResolution,
          ),
          const SizedBox(
            height: 16,
          ),
          _ScanEvidenceCard(
            session: session,
            code: code,
          ),
          if (session.warnings.isNotEmpty) ...[
            const SizedBox(
              height: 16,
            ),
            _ScanWarningsCard(
              warnings: session.warnings,
            ),
          ],
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
    required this.code,
    required this.resolution,
  });

  final ScanCode code;
  final AtlasBarcodeResolution resolution;

  @override
  Widget build(BuildContext context) {
    final String title;
    final String message;
    final IconData icon;

    switch (resolution.status) {
      case AtlasBarcodeResolutionStatus.invalidBarcode:
        title = 'Barcode Detected';
        message = code.isProductBarcode
            ? 'Atlas detected the code, but it could not be used for a catalog lookup.'
            : 'Atlas detected a code, but it is not a supported product barcode.';
        icon = Icons.warning_amber_rounded;

      case AtlasBarcodeResolutionStatus.noMatch:
        title = 'No Catalog Match';
        message =
        'The barcode was valid, but Atlas did not find a matching catalog product.';
        icon = Icons.search_off_rounded;

      case AtlasBarcodeResolutionStatus.singleMatch:
        title = 'Product Found';
        message =
        'Atlas found one catalog product matching this barcode.';
        icon = Icons.check_circle_outline_rounded;

      case AtlasBarcodeResolutionStatus.multipleMatches:
        title = 'Possible Matches Found';
        message =
        'Atlas found more than one catalog product. Review the choices before continuing.';
        icon = Icons.content_copy_rounded;
    }

    return Column(
      children: [
        Icon(
          icon,
          size: 72,
        ),
        const SizedBox(
          height: 16,
        ),
        Text(
          title,
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
          message,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _CatalogResolutionCard extends StatelessWidget {
  const _CatalogResolutionCard({
    required this.resolution,
  });

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
            barcode: resolution.barcode,
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
          product: resolution.singleMatch!,
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
            for (int index = 0;
            index < products.length;
            index++) ...[
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
    required this.barcode,
    required this.vaultMatches,
    required this.collectionName,
  });

  final String barcode;
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _VaultProductHeroCard(
          pop: primaryPop,
        ),
        const SizedBox(
          height: 16,
        ),
        _VaultBarcodeConfidenceCard(
          barcode: barcode,
        ),
        const SizedBox(
          height: 16,
        ),
        _CollectionStatusCard(
          collectionName: collectionName,
          summary: collectionSummary,
        ),
        const SizedBox(
          height: 16,
        ),
        _AtlasInsightCard(
          summary: collectionSummary,
          productName: primaryPop.name.trim().isEmpty
              ? 'This collectible'
              : primaryPop.name.trim(),
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

class _VaultProductHeroCard extends StatelessWidget {
  const _VaultProductHeroCard({
    required this.pop,
  });

  final Pop pop;

  @override
  Widget build(BuildContext context) {
    final String imageUrl = pop.imageUrl.trim();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            constraints: const BoxConstraints(
              minHeight: 260,
              maxHeight: 360,
            ),
            alignment: Alignment.center,
            child: imageUrl.isEmpty
                ? const _ProductImagePlaceholder()
                : Image.network(
              imageUrl,
              width: double.infinity,
              height: 320,
              fit: BoxFit.contain,
              errorBuilder: (
                  BuildContext context,
                  Object error,
                  StackTrace? stackTrace,
                  ) {
                return const _ProductImagePlaceholder();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              16,
              20,
              20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  pop.name.trim().isEmpty
                      ? 'Vault Collectible'
                      : pop.name.trim(),
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (pop.number.trim().isNotEmpty) ...[
                  const SizedBox(
                    height: 6,
                  ),
                  Text(
                    '#${pop.number.trim()}',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (pop.series.trim().isNotEmpty) ...[
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    pop.series.trim(),
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
                if (pop.variant.trim().isNotEmpty) ...[
                  const SizedBox(
                    height: 12,
                  ),
                  Chip(
                    avatar: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 18,
                    ),
                    label: Text(
                      pop.variant.trim(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VaultBarcodeConfidenceCard extends StatelessWidget {
  const _VaultBarcodeConfidenceCard({
    required this.barcode,
  });

  final String barcode;

  @override
  Widget build(BuildContext context) {
    const int confidence = 99;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  '🟢 PRODUCT IDENTIFIED',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 14,
            ),
            Text(
              '★★★★★',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(
              height: 6,
            ),
            Text(
              'Atlas Confidence: $confidence%',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 6,
            ),
            Text(
              'Barcode $barcode matched an imported Vault record.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProductHeroCard(
          product: product,
          scannedPop: scannedPop,
        ),
        const SizedBox(
          height: 16,
        ),
        _AtlasConfidenceCard(
          collectionSummary: collectionSummary,
        ),
        const SizedBox(
          height: 16,
        ),
        _CollectionStatusCard(
          collectionName: appState.selectedCollection,
          summary: collectionSummary,
        ),
        const SizedBox(
          height: 16,
        ),
        _AtlasInsightCard(
          summary: collectionSummary,
          productName: product.displayName,
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

class _ProductHeroCard extends StatelessWidget {
  const _ProductHeroCard({
    required this.product,
    required this.scannedPop,
  });

  final AtlasCatalogProduct product;
  final Pop scannedPop;

  @override
  Widget build(BuildContext context) {
    final String imageUrl = scannedPop.imageUrl.trim();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            constraints: const BoxConstraints(
              minHeight: 260,
              maxHeight: 360,
            ),
            alignment: Alignment.center,
            child: imageUrl.isEmpty
                ? const _ProductImagePlaceholder()
                : Image.network(
              imageUrl,
              width: double.infinity,
              height: 320,
              fit: BoxFit.contain,
              errorBuilder: (
                  BuildContext context,
                  Object error,
                  StackTrace? stackTrace,
                  ) {
                return const _ProductImagePlaceholder();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              16,
              20,
              20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  product.displayName,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (scannedPop.number.trim().isNotEmpty) ...[
                  const SizedBox(
                    height: 6,
                  ),
                  Text(
                    '#${scannedPop.number.trim()}',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (scannedPop.series.trim().isNotEmpty) ...[
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    scannedPop.series.trim(),
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
                if (scannedPop.variant.trim().isNotEmpty) ...[
                  const SizedBox(
                    height: 12,
                  ),
                  Chip(
                    avatar: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 18,
                    ),
                    label: Text(
                      scannedPop.variant.trim(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductImagePlaceholder extends StatelessWidget {
  const _ProductImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 72,
          ),
          SizedBox(
            height: 12,
          ),
          Text(
            'Product image unavailable',
          ),
        ],
      ),
    );
  }
}

class _AtlasConfidenceCard extends StatelessWidget {
  const _AtlasConfidenceCard({
    required this.collectionSummary,
  });

  final _CollectionMatchSummary collectionSummary;

  @override
  Widget build(BuildContext context) {
    const int confidence = 99;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  '🟢 PRODUCT IDENTIFIED',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 14,
            ),
            Text(
              '★★★★★',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(
              height: 6,
            ),
            Text(
              'Atlas Confidence: $confidence%',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 6,
            ),
            Text(
              collectionSummary.hasExactMatch
                  ? 'Catalog identity and Vault identity matched.'
                  : 'Catalog identity was resolved successfully.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionStatusCard extends StatelessWidget {
  const _CollectionStatusCard({
    required this.collectionName,
    required this.summary,
  });

  final String collectionName;
  final _CollectionMatchSummary summary;

  @override
  Widget build(BuildContext context) {
    final IconData statusIcon;
    final String statusTitle;
    final String statusMessage;

    if (summary.hasExactMatch) {
      statusIcon = Icons.verified_rounded;
      statusTitle = 'You Own This Release';
      statusMessage = summary.exactQuantity == 1
          ? 'One copy is currently saved in your Vault.'
          : '${summary.exactQuantity} copies are currently saved in your Vault.';
    } else if (summary.hasRelatedMatches) {
      statusIcon = Icons.compare_arrows_rounded;
      statusTitle = 'Related Release Owned';
      statusMessage = summary.relatedMatches.length == 1
          ? 'Atlas found one related variant in your Vault.'
          : 'Atlas found ${summary.relatedMatches.length} related variants in your Vault.';
    } else {
      statusIcon = Icons.add_box_outlined;
      statusTitle = 'Not Currently in Your Vault';
      statusMessage =
      'Atlas did not find this release or a closely related variant.';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '📦 Collection Status',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  statusIcon,
                  size: 34,
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusTitle,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        statusMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 14,
            ),
            Text(
              collectionName,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (summary.hasRelatedMatches) ...[
              const Divider(
                height: 28,
              ),
              Text(
                'Related Vault Releases',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              for (final Pop relatedPop in summary.relatedMatches.take(3))
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 8,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        size: 18,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Text(
                          _relatedPopLabel(
                            relatedPop,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  String _relatedPopLabel(
      Pop pop,
      ) {
    final List<String> details = <String>[];

    if (pop.variant.trim().isNotEmpty) {
      details.add(
        pop.variant.trim(),
      );
    }

    if (pop.retailExclusive.trim().isNotEmpty &&
        pop.retailExclusive.trim().toLowerCase() != 'none') {
      details.add(
        pop.retailExclusive.trim(),
      );
    }

    if (pop.eventSticker.trim().isNotEmpty &&
        pop.eventSticker.trim().toLowerCase() != 'none') {
      details.add(
        pop.eventSticker.trim(),
      );
    }

    if (details.isEmpty) {
      return pop.name;
    }

    return '${pop.name} • ${details.join(' • ')}';
  }
}

class _AtlasInsightCard extends StatelessWidget {
  const _AtlasInsightCard({
    required this.summary,
    required this.productName,
  });

  final _CollectionMatchSummary summary;
  final String productName;

  @override
  Widget build(BuildContext context) {
    final String insight;

    if (summary.hasExactMatch) {
      insight = summary.exactQuantity > 1
          ? 'You already own ${summary.exactQuantity} copies of this exact release. '
          'Adding it again will increase the saved quantity.'
          : 'You already own this exact release. You can still add another copy '
          'if this purchase improves its condition or is intended for trade.';
    } else if (summary.hasRelatedMatches) {
      insight =
      'This exact release is not currently saved, but Atlas found related '
          'versions in your Vault. Review the sticker, finish, exclusive, and '
          'packaging details before adding it.';
    } else {
      insight =
      '$productName appears to be a new discovery for this Vault. '
          'Adding it will create a new collection record.';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🤖 Atlas Insight',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Text(
              insight,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
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

  bool get hasExactMatch => exactMatches.isNotEmpty;

  bool get hasRelatedMatches => relatedMatches.isNotEmpty;

  int get exactQuantity {
    return exactMatches.fold<int>(
      0,
          (int total, Pop pop) => total + pop.quantity,
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
      exactMatches:
      List<Pop>.unmodifiable(exactMatches),
      relatedMatches:
      List<Pop>.unmodifiable(relatedMatches),
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

    // UPC-A and EAN-13 may represent the same barcode,
    // with EAN-13 containing a leading zero.
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
        for (int index = 0;
        index < rows.length;
        index++) ...[
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

class _ScanWarningsCard extends StatelessWidget {
  const _ScanWarningsCard({
    required this.warnings,
  });

  final List<String> warnings;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  'Scan Warnings',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            for (final String warning in warnings)
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 8,
                ),
                child: Text(
                  warning,
                ),
              ),
          ],
        ),
      ),
    );
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