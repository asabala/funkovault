import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:funkovault2/atlas/catalog/models/atlas_catalog_product.dart';
import 'package:funkovault2/atlas/catalog/services/atlas_barcode_catalog_resolver.dart';
import 'package:funkovault2/atlas/catalog/services/atlas_pop_factory.dart';
import 'package:funkovault2/atlas/collection/actions/atlas_collector_action.dart';
import 'package:funkovault2/atlas/collection/engine/atlas_collector_state_engine.dart';
import 'package:funkovault2/atlas/intelligence/engines/atlas_collector_insight_engine.dart';
import 'package:funkovault2/atlas/intelligence/engines/atlas_scan_intelligence_engine.dart';
import 'package:funkovault2/atlas/intelligence/models/atlas_collector_insight.dart';
import 'package:funkovault2/atlas/intelligence/models/atlas_scan_intelligence.dart';
import 'package:funkovault2/atlas/scan/briefing/atlas_scan_briefing.dart';
import 'package:funkovault2/atlas/scan/briefing/atlas_scan_briefing_engine.dart';
import 'package:funkovault2/atlas/scan/models/scan_code.dart';
import 'package:funkovault2/atlas/scan/models/scan_session.dart';
import 'package:funkovault2/atlas/scan/workflow/identity_resolution_status.dart';
import 'package:funkovault2/models/pop.dart';
import 'package:funkovault2/screens/catalog/funko_catalog_screen.dart';
import 'package:funkovault2/screens/pop/add_pop_screen.dart';
import 'package:funkovault2/screens/pop/pop_details_screen.dart';
import 'package:funkovault2/services/app_state.dart';
import 'package:funkovault2/widgets/scanner/atlas_collector_action_bar.dart';
import 'package:funkovault2/widgets/scanner/atlas_collector_summary_card.dart';
import 'package:funkovault2/widgets/scanner/atlas_scan_briefing_card.dart';
import 'package:funkovault2/widgets/scanner/atlas_scan_intelligence_card.dart';

Future<void> _openCatalogProduct(
  BuildContext context,
  AtlasCatalogProduct product,
  String collectionName,
) {
  return Navigator.push<void>(
    context,
    MaterialPageRoute<void>(
      builder: (_) {
        return AddPopScreen(
          atlasProduct: product,
          collectionName: collectionName,
        );
      },
    ),
  );
}

Future<void> _openManualAdd(BuildContext context, String collectionName) {
  return Navigator.push<void>(
    context,
    MaterialPageRoute<void>(
      builder: (_) {
        return AddPopScreen(collectionName: collectionName);
      },
    ),
  );
}

Future<void> _openCatalogSearch(BuildContext context) {
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
    required this.collectionName,
    super.key,
  });

  final ScanSession session;
  final AtlasBarcodeResolution catalogResolution;
  final String collectionName;

  @override
  Widget build(BuildContext context) {
    final ScanCode? primaryCode = session.bestCandidate ?? _firstDetectedCode;

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Result')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: primaryCode == null
              ? const _NoBarcodeView()
              : _BarcodeResultView(
                  session: session,
                  code: primaryCode,
                  catalogResolution: catalogResolution,
                  collectionName: collectionName,
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
            const Icon(Icons.search_off_rounded, size: 72),
            const SizedBox(height: 20),
            Text(
              'No Barcode Detected',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Atlas could not find usable barcode evidence in this scan session.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan Again'),
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
    required this.collectionName,
  });

  final ScanSession session;
  final ScanCode code;
  final AtlasBarcodeResolution catalogResolution;
  final String collectionName;

  @override
  Widget build(BuildContext context) {
    final AtlasScanBriefing briefing = AtlasScanBriefingEngine.build(session);

    final AtlasScanIntelligence intelligence =
        const AtlasScanIntelligenceEngine().processChecked(session);

    final AppState appState = context.watch<AppState>();

    final List<Pop> vaultBarcodeMatches = const AtlasCollectorStateEngine()
        .findByBarcode(
          barcode: catalogResolution.barcode,
          collectionPops: appState.popsForCollection(collectionName),
        );

    final bool hasVaultBarcodeMatch =
        catalogResolution.status == AtlasBarcodeResolutionStatus.noMatch &&
        vaultBarcodeMatches.isNotEmpty;

    final bool hasSuccessfulCollectorResult =
        catalogResolution.status == AtlasBarcodeResolutionStatus.singleMatch ||
        hasVaultBarcodeMatch;

    final bool shouldShowHeader = _shouldShowResultHeader(
      session: session,
      resolution: catalogResolution,
      hasVaultBarcodeMatch: hasVaultBarcodeMatch,
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (shouldShowHeader) ...[
            _ResultHeader(
              session: session,
              code: code,
              resolution: catalogResolution,
              hasVaultBarcodeMatch: hasVaultBarcodeMatch,
            ),
            const SizedBox(height: 20),
          ],
          _CatalogResolutionCard(
            session: session,
            resolution: catalogResolution,
            intelligence: intelligence,
            collectionName: collectionName,
          ),
          const SizedBox(height: 16),
          AtlasScanBriefingCard(briefing: briefing),
          const SizedBox(height: 16),
          AtlasScanIntelligenceCard(intelligence: intelligence),
          const SizedBox(height: 16),
          _ScanDiagnosticsCard(session: session, code: code),
          if (!hasSuccessfulCollectorResult) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: const Text('📷 Scan Again'),
            ),
          ],
        ],
      ),
    );
  }

  bool _shouldShowResultHeader({
    required ScanSession session,
    required AtlasBarcodeResolution resolution,
    required bool hasVaultBarcodeMatch,
  }) {
    switch (session.resolutionStatus) {
      case IdentityResolutionStatus.failed:
      case IdentityResolutionStatus.ambiguous:
      case IdentityResolutionStatus.unresolved:
      case IdentityResolutionStatus.pendingSync:
      case IdentityResolutionStatus.resolving:
        return true;

      case IdentityResolutionStatus.resolvedLocal:
      case IdentityResolutionStatus.resolvedRemote:
        return false;

      case IdentityResolutionStatus.notStarted:
        break;
    }

    if (hasVaultBarcodeMatch) {
      return false;
    }

    switch (resolution.status) {
      case AtlasBarcodeResolutionStatus.singleMatch:
        return false;

      case AtlasBarcodeResolutionStatus.invalidBarcode:
      case AtlasBarcodeResolutionStatus.noMatch:
      case AtlasBarcodeResolutionStatus.multipleMatches:
        return true;
    }
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({
    required this.session,
    required this.code,
    required this.resolution,
    required this.hasVaultBarcodeMatch,
  });

  final ScanSession session;
  final ScanCode code;
  final AtlasBarcodeResolution resolution;
  final bool hasVaultBarcodeMatch;

  @override
  Widget build(BuildContext context) {
    final _ResultHeaderState headerState = _buildHeaderState();

    return Column(
      children: [
        Icon(headerState.icon, size: 72),
        const SizedBox(height: 16),
        Text(
          headerState.title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(headerState.message, textAlign: TextAlign.center),
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
    if (hasVaultBarcodeMatch) {
      return const _ResultHeaderState(
        title: '📦 Found in Your Vault',
        message: 'Atlas found this barcode in your selected collection.',
        icon: Icons.inventory_2_rounded,
      );
    }
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
          message: 'Atlas found one catalog product matching this barcode.',
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
    required this.collectionName,
    required this.session,
    required this.resolution,
    required this.intelligence,
  });

  final String collectionName;
  final ScanSession session;
  final AtlasScanIntelligence intelligence;
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
                _openManualAdd(context, collectionName);
              },
              icon: const Icon(Icons.edit_note_rounded),
              label: const Text('Enter Product Manually'),
            ),
          ],
        );

      case AtlasBarcodeResolutionStatus.noMatch:
        final AppState appState = context.watch<AppState>();

        final List<Pop> vaultMatches = const AtlasCollectorStateEngine()
            .findByBarcode(
              barcode: resolution.barcode,
              collectionPops: appState.popsForCollection(collectionName),
            );

        if (vaultMatches.isNotEmpty) {
          return _VaultBarcodeMatchCard(
            session: session,
            intelligence: intelligence,
            scannedBarcode: resolution.barcode,
            vaultMatches: vaultMatches,
            collectionPops: appState.popsForCollection(collectionName),
            collectionName: collectionName,
          );
        }

        return _CatalogMessageCard(
          icon: Icons.search_off_rounded,
          title: '🔎 Item Not Found in Atlas',
          message:
              'Atlas does not recognize barcode ${resolution.barcode} yet. Search the catalog or create the collectible manually.',
          actions: [
            FilledButton.icon(
              onPressed: () {
                _openCatalogSearch(context);
              },
              icon: const Icon(Icons.search_rounded),
              label: const Text('🔎 Search Catalog'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () {
                _openManualAdd(context, collectionName);
              },
              icon: const Icon(Icons.edit_note_rounded),
              label: const Text('➕ Add Manually'),
            ),
          ],
        );

      case AtlasBarcodeResolutionStatus.singleMatch:
        return _CatalogProductCard(
          collectionName: collectionName,
          session: session,
          intelligence: intelligence,
          product: session.catalogProduct ?? resolution.singleMatch!,
          scannedBarcode: resolution.barcode,
        );

      case AtlasBarcodeResolutionStatus.multipleMatches:
        return _MultipleCatalogMatchesCard(
          products: resolution.matches,
          collectionName: collectionName,
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
            Icon(icon, size: 36),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            if (actions.isNotEmpty) ...[const SizedBox(height: 20), ...actions],
          ],
        ),
      ),
    );
  }
}

class _MultipleCatalogMatchesCard extends StatelessWidget {
  const _MultipleCatalogMatchesCard({
    required this.products,
    required this.collectionName,
  });

  final List<AtlasCatalogProduct> products;
  final String collectionName;

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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Atlas will not automatically choose between products that share a barcode. Review each product and select the correct match.',
            ),
            const SizedBox(height: 16),
            for (int index = 0; index < products.length; index++) ...[
              _CatalogProductSummary(product: products[index]),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  _openCatalogProduct(context, products[index], collectionName);
                },
                icon: const Icon(Icons.add_circle_outline_rounded),
                label: const Text('Add This Product'),
              ),
              if (index < products.length - 1) const Divider(height: 32),
            ],
          ],
        ),
      ),
    );
  }
}

class _VaultBarcodeMatchCard extends StatelessWidget {
  const _VaultBarcodeMatchCard({
    required this.session,
    required this.intelligence,
    required this.scannedBarcode,
    required this.vaultMatches,
    required this.collectionPops,
    required this.collectionName,
  });

  final ScanSession session;
  final AtlasScanIntelligence intelligence;
  final String scannedBarcode;
  final List<Pop> vaultMatches;
  final List<Pop> collectionPops;
  final String collectionName;

  @override
  Widget build(BuildContext context) {
    final Pop primaryPop = _primaryDisplayPop(vaultMatches);

    final AppState appState = context.watch<AppState>();

    final AtlasCollectorInsight collectorInsight =
        const AtlasCollectorInsightEngine().evaluateScan(
          session: session,
          product: primaryPop,
          scannedBarcode: scannedBarcode,
          collectionPops: collectionPops,
          collectionName: collectionName,
          ownedWishlistIdentityKeys: appState
              .ownedWishlistIdentityKeysForCollection(collectionName),
          precomputedIntelligence: intelligence,
        );

    final List<AtlasCollectorAction> safeActions = collectorInsight.actions
        .where((AtlasCollectorAction action) {
          switch (action.type) {
            case AtlasCollectorActionType.viewExistingItem:
            case AtlasCollectorActionType.addToWishlist:
            case AtlasCollectorActionType.removeFromWishlist:
            case AtlasCollectorActionType.scanAnother:
              return true;

            case AtlasCollectorActionType.addToVault:
            case AtlasCollectorActionType.addAnotherCopy:
              return false;
          }
        })
        .toList(growable: false);

    final Pop displayPop =
        collectorInsight.state.primaryOwnedMatch ??
        collectorInsight.state.primaryWishlistMatch ??
        primaryPop;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AtlasCollectorSummaryCard(
          summary: collectorInsight.summary,
          imageUrl: displayPop.imageUrl,
        ),
        const SizedBox(height: 16),
        AtlasCollectorActionBar(
          actions: safeActions,
          onActionPressed: (AtlasCollectorActionType actionType) async {
            switch (actionType) {
              case AtlasCollectorActionType.viewExistingItem:
                final Pop? existingPop =
                    collectorInsight.state.primaryOwnedMatch;

                if (existingPop == null) {
                  return;
                }

                await Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) {
                      return PopDetailsScreen(
                        pop: existingPop,
                        collectionName: collectionName,
                      );
                    },
                  ),
                );

              case AtlasCollectorActionType.addToVault:
                await _openManualAdd(context, collectionName);

              case AtlasCollectorActionType.scanAnother:
                Navigator.pop(context);

              case AtlasCollectorActionType.addToWishlist:
                final Pop? ownedPop = collectorInsight.state.primaryOwnedMatch;

                if (ownedPop == null) {
                  return;
                }

                await context.read<AppState>().addOwnedPopToWishlist(
                  ownedPop,
                  collectionName: collectionName,
                );

              case AtlasCollectorActionType.removeFromWishlist:
                final Pop? ownedPop = collectorInsight.state.primaryOwnedMatch;

                if (ownedPop == null) {
                  return;
                }

                await context.read<AppState>().removeOwnedPopFromWishlist(
                  ownedPop,
                  collectionName: collectionName,
                );

              case AtlasCollectorActionType.addAnotherCopy:
                return;
            }
          },
        ),
      ],
    );
  }

  Pop _primaryDisplayPop(List<Pop> matches) {
    for (final Pop pop in matches) {
      if (!pop.isWishlist) {
        return pop;
      }
    }

    return matches.first;
  }
}

class _CatalogProductCard extends StatelessWidget {
  const _CatalogProductCard({
    required this.collectionName,
    required this.session,
    required this.intelligence,
    required this.product,
    required this.scannedBarcode,
  });

  final String collectionName;
  final ScanSession session;
  final AtlasScanIntelligence intelligence;
  final AtlasCatalogProduct product;
  final String scannedBarcode;

  @override
  Widget build(BuildContext context) {
    final AppState appState = context.watch<AppState>();

    final Pop scannedPop = AtlasPopFactory.createFromCatalog(product: product);

    final AtlasCollectorInsight collectorInsight =
        const AtlasCollectorInsightEngine().evaluateScan(
          session: session,
          product: scannedPop,
          scannedBarcode: scannedBarcode,
          collectionPops: appState.popsForCollection(collectionName),
          collectionName: collectionName,
          ownedWishlistIdentityKeys: appState
              .ownedWishlistIdentityKeysForCollection(collectionName),
          precomputedIntelligence: intelligence,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AtlasCollectorSummaryCard(
          summary: collectorInsight.summary,
          imageUrl: scannedPop.imageUrl,
        ),
        const SizedBox(height: 16),
        AtlasCollectorActionBar(
          actions: collectorInsight.actions,
          onActionPressed: (AtlasCollectorActionType actionType) async {
            switch (actionType) {
              case AtlasCollectorActionType.viewExistingItem:
                final Pop? existingPop =
                    collectorInsight.state.primaryOwnedMatch;

                if (existingPop == null) {
                  return;
                }

                await Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) {
                      return PopDetailsScreen(
                        pop: existingPop,
                        collectionName: collectionName,
                      );
                    },
                  ),
                );

              case AtlasCollectorActionType.addToVault:
              case AtlasCollectorActionType.addAnotherCopy:
                await _openCatalogProduct(context, product, collectionName);

              case AtlasCollectorActionType.addToWishlist:
                final AppState appState = context.read<AppState>();

                final Pop? ownedPop = collectorInsight.state.primaryOwnedMatch;

                if (ownedPop != null) {
                  await appState.addOwnedPopToWishlist(
                    ownedPop,
                    collectionName: collectionName,
                  );
                } else {
                  final Pop wishlistPop =
                      AtlasPopFactory.createWishlistFromCatalog(
                        product: product,
                      );

                  await appState.addPop(
                    wishlistPop,
                    collectionName: collectionName,
                  );
                }

                if (!context.mounted) {
                  return;
                }

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        '❤️ ${product.displayName} added to your wishlist.',
                      ),
                    ),
                  );

              case AtlasCollectorActionType.removeFromWishlist:
                final AppState appState = context.read<AppState>();

                final Pop? ownedPop = collectorInsight.state.primaryOwnedMatch;

                if (collectorInsight.state.isOwnedWishlisted &&
                    ownedPop != null) {
                  await appState.removeOwnedPopFromWishlist(
                    ownedPop,
                    collectionName: collectionName,
                  );
                } else {
                  final Pop? wishlistPop =
                      collectorInsight.state.primaryWishlistMatch;

                  if (wishlistPop == null) {
                    return;
                  }

                  await appState.deletePop(
                    wishlistPop.id,
                    collectionName: collectionName,
                    recordKey: wishlistPop.collectionRecordKey,
                  );
                }

                if (!context.mounted) {
                  return;
                }

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        '💔 ${product.displayName} removed from your wishlist.',
                      ),
                    ),
                  );

              case AtlasCollectorActionType.scanAnother:
                Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}

class _CatalogProductSummary extends StatelessWidget {
  const _CatalogProductSummary({required this.product});

  final AtlasCatalogProduct product;

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = <Widget>[
      _ResultRow(label: 'Product', value: product.displayName),
    ];

    _addOptionalRow(rows: rows, label: 'Number', value: product.productNumber);

    _addOptionalRow(rows: rows, label: 'Variant', value: product.variantName);

    _addOptionalRow(rows: rows, label: 'Series', value: product.series);

    _addOptionalRow(rows: rows, label: 'Line', value: product.productLine);

    _addOptionalRow(rows: rows, label: 'Brand', value: product.brand);

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
        for (int index = 0; index < rows.length; index++) ...[
          rows[index],
          if (index < rows.length - 1) const Divider(),
        ],
      ],
    );
  }

  static void _addOptionalRow({
    required List<Widget> rows,
    required String label,
    required String? value,
  }) {
    final String normalizedValue = value?.trim() ?? '';

    if (normalizedValue.isEmpty) {
      return;
    }

    rows.add(_ResultRow(label: label, value: normalizedValue));
  }
}

class _ScanDiagnosticsCard extends StatelessWidget {
  const _ScanDiagnosticsCard({required this.session, required this.code});

  final ScanSession session;
  final ScanCode code;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: false,
        leading: const Icon(Icons.troubleshoot_rounded),
        title: Text(
          '🔍 Scan Diagnostics',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text(
          'Barcode evidence, identity status, and technical details',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          const Divider(),
          _ResultRow(
            label: 'Barcode',
            value: code.normalizedValue,
            selectable: true,
          ),
          const Divider(),
          _ResultRow(label: 'Format', value: _formatLabel(code.format)),
          const Divider(),
          _ResultRow(label: 'Source', value: _sourceLabel(code.source)),
          const Divider(),
          _ResultRow(
            label: 'Validation',
            value: code.isValid ? 'Passed' : 'Failed',
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
            value: _resolutionStatusLabel(session.resolutionStatus),
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
            const _ResultRow(label: 'Variant', value: 'Confirmation required'),
          ],
          const Divider(),
          _ResultRow(
            label: 'Session Status',
            value: _statusLabel(session.status),
          ),
        ],
      ),
    );
  }

  String _formatLabel(ScanCodeFormat format) {
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

  String _sourceLabel(ScanCodeSource source) {
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

  String _resolutionStatusLabel(IdentityResolutionStatus status) {
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

  String _statusLabel(ScanSessionStatus status) {
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: selectable ? SelectableText(value) : Text(value)),
        ],
      ),
    );
  }
}
