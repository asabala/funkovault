import 'package:funkovault2/atlas/collection/actions/atlas_collector_action.dart';
import 'package:funkovault2/atlas/collection/actions/atlas_collector_action_engine.dart';
import 'package:funkovault2/atlas/collection/engine/atlas_collector_state_engine.dart';
import 'package:funkovault2/atlas/collection/models/atlas_collector_state.dart';
import 'package:funkovault2/atlas/intelligence/models/atlas_collector_insight.dart';
import 'package:funkovault2/atlas/intelligence/models/atlas_collector_summary.dart';
import 'package:funkovault2/atlas/intelligence/models/atlas_scan_intelligence.dart';
import 'package:funkovault2/atlas/scan/models/scan_session.dart';
import 'package:funkovault2/models/pop.dart';

import 'atlas_scan_intelligence_engine.dart';

class AtlasCollectorInsightEngine {
  const AtlasCollectorInsightEngine({
    this.collectorStateEngine =
    const AtlasCollectorStateEngine(),
    this.collectorActionEngine =
    const AtlasCollectorActionEngine(),
    this.scanIntelligenceEngine =
    const AtlasScanIntelligenceEngine(),
  });

  final AtlasCollectorStateEngine collectorStateEngine;
  final AtlasCollectorActionEngine collectorActionEngine;
  final AtlasScanIntelligenceEngine scanIntelligenceEngine;

  AtlasCollectorInsight evaluateScan({
    required ScanSession session,
    required Pop product,
    required String scannedBarcode,
    required List<Pop> collectionPops,
    required String collectionName,
    Set<String> ownedWishlistIdentityKeys =
    const <String>{},
    AtlasScanIntelligence? precomputedIntelligence,
  }) {
    final AtlasCollectorState collectorState =
    collectorStateEngine.evaluate(
      product: product,
      scannedBarcode: scannedBarcode,
      collectionPops: collectionPops,
      ownedWishlistIdentityKeys:
      ownedWishlistIdentityKeys,
    );

    final AtlasCollectorSummary collectorSummary =
    AtlasCollectorSummary.buildFromState(
      product: product,
      collectorState: collectorState,
      collectionName: collectionName,
    );

    final AtlasScanIntelligence scanIntelligence =
        precomputedIntelligence ??
            scanIntelligenceEngine.processChecked(
              session,
            );

    final List<AtlasCollectorAction> actions =
    collectorActionEngine.buildActions(
      AtlasCollectorActionContext(
        isOwned: collectorState.isOwned,
        isWishlisted: collectorState.isWishlisted,
        canViewExistingItem:
        collectorState.primaryOwnedMatch != null,
      ),
    );

    return AtlasCollectorInsight(
      state: collectorState,
      summary: collectorSummary,
      intelligence: scanIntelligence,
      actions: actions,
      generatedAt: scanIntelligence.generatedAt,
      confidence: _normalizeConfidence(
        session.confidence,
      ),
      source: _scanSourceLabel(
        session,
      ),
      diagnostics: _buildScanDiagnostics(
        session: session,
        scannedBarcode: scannedBarcode,
        collectorState: collectorState,
      ),
    );
  }

  AtlasCollectorInsight evaluateProduct({
    required Pop product,
    required List<Pop> collectionPops,
    required String collectionName,
    Set<String> ownedWishlistIdentityKeys =
    const <String>{},
    String source = 'Atlas Search',
  }) {
    final AtlasCollectorState collectorState =
    collectorStateEngine.evaluate(
      product: product,
      collectionPops: collectionPops,
      ownedWishlistIdentityKeys:
      ownedWishlistIdentityKeys,
    );

    final AtlasCollectorSummary collectorSummary =
    AtlasCollectorSummary.buildFromState(
      product: product,
      collectorState: collectorState,
      collectionName: collectionName,
    );

    final List<AtlasCollectorAction> actions =
    collectorActionEngine.buildActions(
      AtlasCollectorActionContext(
        isOwned: collectorState.isOwned,
        isWishlisted: collectorState.isWishlisted,
        canViewExistingItem:
        collectorState.primaryOwnedMatch != null,
        includeScanAnother: false,
      ),
    );

    final DateTime generatedAt = DateTime.now();

    return AtlasCollectorInsight(
      state: collectorState,
      summary: collectorSummary,
      intelligence: AtlasScanIntelligence(
        sessionId:
        'product-${generatedAt.microsecondsSinceEpoch}',
        generatedAt: generatedAt,
      ),
      actions: actions,
      generatedAt: generatedAt,
      confidence: _productConfidence(
        product,
      ),
      source: source,
      diagnostics: _buildProductDiagnostics(
        product: product,
        collectorState: collectorState,
      ),
    );
  }

  double _normalizeConfidence(
      double confidence,
      ) {
    if (!confidence.isFinite || confidence <= 0) {
      return 0;
    }

    final double normalizedConfidence =
    confidence > 1
        ? confidence / 100
        : confidence;

    return normalizedConfidence.clamp(
      0.0,
      1.0,
    );
  }

  double _productConfidence(
      Pop product,
      ) {
    var evidenceScore = 0;

    if (product.collectibleIdentityKey
        .trim()
        .isNotEmpty) {
      evidenceScore += 40;
    }

    if (product.sourceCatalogId.trim().isNotEmpty ||
        product.sourceCollectibleId.trim().isNotEmpty) {
      evidenceScore += 25;
    }

    if (product.sourceUpc.trim().isNotEmpty) {
      evidenceScore += 15;
    }

    if (product.name.trim().isNotEmpty &&
        product.number.trim().isNotEmpty) {
      evidenceScore += 10;
    }

    if (product.category.trim().isNotEmpty ||
        product.series.trim().isNotEmpty) {
      evidenceScore += 10;
    }

    return (evidenceScore / 100).clamp(
      0.0,
      1.0,
    );
  }

  String _scanSourceLabel(
      ScanSession session,
      ) {
    if (session.isOffline) {
      return 'Atlas Offline Scan';
    }

    if (session.requiresSync) {
      return 'Atlas Scan — Sync Pending';
    }

    return 'Atlas Scan';
  }

  List<String> _buildScanDiagnostics({
    required ScanSession session,
    required String scannedBarcode,
    required AtlasCollectorState collectorState,
  }) {
    final List<String> diagnostics = <String>[];

    final String normalizedBarcode =
    scannedBarcode.trim();

    if (normalizedBarcode.isNotEmpty) {
      diagnostics.add(
        'Barcode: $normalizedBarcode',
      );
    }

    diagnostics.add(
      'Resolution: ${session.resolutionStatus.name}',
    );

    diagnostics.add(
      'Owned matches: ${collectorState.ownedMatches.length}',
    );

    diagnostics.add(
      'Wishlist matches: ${collectorState.wishlistMatches.length}',
    );

    diagnostics.add(
      'Owned wishlist overlay: ${collectorState.isOwnedWishlisted}',
    );

    diagnostics.add(
      'Related matches: ${collectorState.relatedMatches.length}',
    );

    diagnostics.add(
      'Evidence contributions: ${session.contributionCount}',
    );

    for (final String warning in session.warnings) {
      final String cleanedWarning = warning.trim();

      if (cleanedWarning.isEmpty) {
        continue;
      }

      diagnostics.add(
        'Warning: $cleanedWarning',
      );
    }

    return List<String>.unmodifiable(
      diagnostics,
    );
  }

  List<String> _buildProductDiagnostics({
    required Pop product,
    required AtlasCollectorState collectorState,
  }) {
    final List<String> diagnostics = <String>[
      'Evaluation source: Product',
      'Owned matches: ${collectorState.ownedMatches.length}',
      'Wishlist matches: ${collectorState.wishlistMatches.length}',
      'Owned wishlist overlay: ${collectorState.isOwnedWishlisted}',
      'Related matches: ${collectorState.relatedMatches.length}',
    ];

    final String upc =
    product.sourceUpc.trim();

    if (upc.isNotEmpty) {
      diagnostics.add(
        'UPC: $upc',
      );
    }

    final String catalogId =
    product.sourceCatalogId.trim();

    if (catalogId.isNotEmpty) {
      diagnostics.add(
        'Catalog ID: $catalogId',
      );
    }

    final String collectibleId =
    product.sourceCollectibleId.trim();

    if (collectibleId.isNotEmpty) {
      diagnostics.add(
        'Collectible ID: $collectibleId',
      );
    }

    final String identityKey =
    product.collectibleIdentityKey.trim();

    if (identityKey.isNotEmpty) {
      diagnostics.add(
        'Identity key available',
      );
    }

    return List<String>.unmodifiable(
      diagnostics,
    );
  }
}