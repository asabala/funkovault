import 'package:flutter/material.dart';

import 'package:funkovault2/atlas/catalog/models/atlas_catalog_product.dart';
import 'package:funkovault2/atlas/catalog/services/atlas_barcode_catalog_resolver.dart';
import 'package:funkovault2/atlas/scan/models/scan_code.dart';
import 'package:funkovault2/atlas/scan/models/scan_session.dart';
import 'package:funkovault2/screens/catalog/funko_catalog_screen.dart';
import 'package:funkovault2/screens/pop/add_pop_screen.dart';

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
        return _CatalogMessageCard(
          icon: Icons.inventory_2_outlined,
          title: 'Product Not Yet Identified',
          message:
          'Barcode ${resolution.barcode} is not currently connected to an Atlas catalog product.',
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

class _CatalogProductCard extends StatelessWidget {
  const _CatalogProductCard({
    required this.product,
  });

  final AtlasCatalogProduct product;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CatalogProductSummary(
              product: product,
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
              icon: const Icon(
                Icons.add_circle_rounded,
              ),
              label: const Text(
                'Add to Vault',
              ),
            ),
          ],
        ),
      ),
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