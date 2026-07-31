import '../models/scan_session.dart';
import '../results/collector_item_status.dart';
import '../results/market_value_snapshot.dart';
import '../results/scan_variant_status.dart';
import '../workflow/identity_resolution_status.dart';
import 'atlas_scan_briefing.dart';

class AtlasScanBriefingEngine {
  const AtlasScanBriefingEngine._();

  static AtlasScanBriefing build(
      ScanSession session,
      ) {
    final List<String> highlights = <String>[];

    _addConfidenceHighlight(
      session,
      highlights,
    );

    _addCollectorHighlights(
      session.collectorStatus,
      highlights,
    );

    _addVariantHighlights(
      session.variantResolution,
      highlights,
    );

    _addMarketHighlights(
      session.marketSnapshot,
      highlights,
    );

    _addSessionHighlights(
      session,
      highlights,
    );

    return AtlasScanBriefing(
      priority: _priorityFor(session),
      title: _titleFor(session),
      summary: _summaryFor(session),
      highlights: List<String>.unmodifiable(
        highlights,
      ),
      recommendation: _recommendationFor(session),
    );
  }

  static AtlasScanBriefingPriority _priorityFor(
      ScanSession session,
      ) {
    if (session.resolutionStatus ==
        IdentityResolutionStatus.failed ||
        session.status == ScanSessionStatus.failed) {
      return AtlasScanBriefingPriority.critical;
    }

    if (session.requiresUserAction ||
        session.resolutionStatus ==
            IdentityResolutionStatus.ambiguous ||
        session.resolutionStatus ==
            IdentityResolutionStatus.unresolved) {
      return AtlasScanBriefingPriority.warning;
    }

    if (session.hasResolvedProduct) {
      return AtlasScanBriefingPriority.success;
    }

    return AtlasScanBriefingPriority.information;
  }

  static String _titleFor(
      ScanSession session,
      ) {
    switch (session.resolutionStatus) {
      case IdentityResolutionStatus.failed:
        return 'Atlas Could Not Resolve This Product';

      case IdentityResolutionStatus.ambiguous:
        return 'Product Review Required';

      case IdentityResolutionStatus.unresolved:
        return 'Product Identity Unresolved';

      case IdentityResolutionStatus.pendingSync:
        return 'Product Resolved — Sync Pending';

      case IdentityResolutionStatus.resolvedLocal:
      case IdentityResolutionStatus.resolvedRemote:
        return 'Atlas Scan Briefing';

      case IdentityResolutionStatus.resolving:
        return 'Atlas Is Resolving This Product';

      case IdentityResolutionStatus.notStarted:
        return 'Scan Evidence Collected';
    }
  }

  static String _summaryFor(
      ScanSession session,
      ) {
    switch (session.resolutionStatus) {
      case IdentityResolutionStatus.failed:
        return 'Atlas could not confidently identify this collectible from the available scan evidence.';

      case IdentityResolutionStatus.ambiguous:
        return 'Atlas found more than one possible product identity. The collectible should be reviewed before it is added to the Vault.';

      case IdentityResolutionStatus.unresolved:
        return 'The scan was processed, but Atlas could not connect the available evidence to a confirmed product identity.';

      case IdentityResolutionStatus.pendingSync:
        return 'Atlas resolved this collectible locally. Additional connected intelligence will be synchronized when available.';

      case IdentityResolutionStatus.resolvedLocal:
        return 'Atlas successfully identified this collectible using locally available intelligence.';

      case IdentityResolutionStatus.resolvedRemote:
        return 'Atlas successfully identified this collectible using connected catalog intelligence.';

      case IdentityResolutionStatus.resolving:
        return 'Atlas is still analyzing the available product evidence.';

      case IdentityResolutionStatus.notStarted:
        return 'Atlas collected the barcode evidence, but identity resolution has not started.';
    }
  }

  static String _recommendationFor(
      ScanSession session,
      ) {
    if (session.resolutionStatus ==
        IdentityResolutionStatus.failed ||
        session.status == ScanSessionStatus.failed) {
      return 'Try scanning the product barcode again or search the Atlas catalog manually.';
    }

    if (session.requiresVariantConfirmation) {
      return 'Confirm the sticker, finish, exclusive, packaging, and other variant traits before adding this collectible.';
    }

    if (session.resolutionStatus ==
        IdentityResolutionStatus.ambiguous) {
      return 'Review each possible catalog match and select the exact physical release.';
    }

    if (session.resolutionStatus ==
        IdentityResolutionStatus.unresolved) {
      return 'Search the broader catalog or enter the product manually.';
    }

    final CollectorItemStatus? collectorStatus =
        session.collectorStatus;

    if (collectorStatus?.hasPossibleDuplicates ?? false) {
      return 'Review the possible duplicate records before adding another copy.';
    }

    if (collectorStatus?.isOwned ?? false) {
      return 'This product is already represented in your Vault. Add it only if this is another copy or a distinct variant.';
    }

    if (collectorStatus?.isWishlisted ?? false) {
      return 'This product is on your wishlist and can be added to your owned collection after confirming the release details.';
    }

    if (session.hasResolvedProduct) {
      return 'The product identity is resolved. Review the details and add it to your Vault when ready.';
    }

    return 'Review the scan evidence before continuing.';
  }

  static void _addConfidenceHighlight(
      ScanSession session,
      List<String> highlights,
      ) {
    final int? confidencePercent =
    _confidencePercent(session.confidence);

    if (confidencePercent == null) {
      return;
    }

    highlights.add(
      'Atlas confidence: $confidencePercent%',
    );
  }

  static void _addCollectorHighlights(
      CollectorItemStatus? status,
      List<String> highlights,
      ) {
    if (status == null) {
      return;
    }

    switch (status.relationship) {
      case CollectorItemRelationship.notInVault:
        highlights.add(
          'This release is not currently in your Vault.',
        );

      case CollectorItemRelationship.owned:
        highlights.add(
          _ownedQuantityMessage(status.ownedQuantity),
        );

      case CollectorItemRelationship.wishlisted:
        highlights.add(
          'This release is currently on your wishlist.',
        );

      case CollectorItemRelationship.ownedAndWishlisted:
        highlights
          ..add(
            _ownedQuantityMessage(status.ownedQuantity),
          )
          ..add(
            'This release is also on your wishlist.',
          );

      case CollectorItemRelationship.unknown:
        break;
    }

    if (status.collectionNames.isNotEmpty) {
      highlights.add(
        'Vault location: ${status.collectionNames.join(', ')}',
      );
    }

    if (status.hasPossibleDuplicates) {
      final int count = status.possibleDuplicateCount;

      highlights.add(
        '$count possible duplicate ${count == 1 ? 'record' : 'records'} found.',
      );
    }
  }

  static String _ownedQuantityMessage(
      int quantity,
      ) {
    if (quantity <= 1) {
      return 'You already own this release.';
    }

    return 'You already own $quantity copies of this release.';
  }

  static void _addVariantHighlights(
      ScanVariantResolution? resolution,
      List<String> highlights,
      ) {
    if (resolution == null) {
      return;
    }

    switch (resolution.status) {
      case ScanVariantStatus.exactMatch:
        highlights.add(
          'The exact physical variant was identified.',
        );

      case ScanVariantStatus.likelyMatch:
        highlights.add(
          'Atlas found a likely variant match.',
        );

      case ScanVariantStatus.multipleCandidates:
        final int count =
            resolution.candidateProductIds.length;

        highlights.add(
          count > 1
              ? '$count possible product variants were found.'
              : 'More than one possible variant may apply.',
        );

      case ScanVariantStatus.visualConfirmationRequired:
        highlights.add(
          'Visual variant confirmation is required.',
        );

      case ScanVariantStatus.unknown:
        break;
    }

    if (resolution.confirmedTraits.isNotEmpty) {
      highlights.add(
        'Confirmed traits: ${resolution.confirmedTraits.join(', ')}',
      );
    }

    if (resolution.unconfirmedTraits.isNotEmpty) {
      highlights.add(
        'Review traits: ${resolution.unconfirmedTraits.join(', ')}',
      );
    }

    final int? confidencePercent =
    _confidencePercent(resolution.confidence);

    if (confidencePercent != null) {
      highlights.add(
        'Variant confidence: $confidencePercent%',
      );
    }
  }

  static void _addMarketHighlights(
      MarketValueSnapshot? snapshot,
      List<String> highlights,
      ) {
    if (snapshot == null ||
        !snapshot.hasMarketEvidence) {
      return;
    }

    if (snapshot.hasEstimatedValue) {
      highlights.add(
        'Estimated value: ${_formatMoney(
          snapshot.estimatedValue!,
          snapshot.currencyCode,
        )}',
      );
    }

    if (snapshot.hasRecentRange) {
      highlights.add(
        'Recent sale range: '
            '${_formatMoney(
          snapshot.recentSaleLow!,
          snapshot.currencyCode,
        )}–'
            '${_formatMoney(
          snapshot.recentSaleHigh!,
          snapshot.currencyCode,
        )}',
      );
    } else if (snapshot.hasLastSale) {
      highlights.add(
        'Last recorded sale: ${_formatMoney(
          snapshot.lastSalePrice!,
          snapshot.currencyCode,
        )}',
      );
    }

    if (snapshot.hasTrend) {
      final double percentage =
      snapshot.trendPercentage!.abs();

      switch (snapshot.trendDirection) {
        case MarketTrendDirection.rising:
          highlights.add(
            'Market trend: rising ${percentage.toStringAsFixed(1)}%',
          );

        case MarketTrendDirection.falling:
          highlights.add(
            'Market trend: falling ${percentage.toStringAsFixed(1)}%',
          );

        case MarketTrendDirection.stable:
          highlights.add(
            'Market trend: stable',
          );

        case MarketTrendDirection.unknown:
          highlights.add(
            'Recent market movement: ${percentage.toStringAsFixed(1)}%',
          );
      }
    }

    if (snapshot.isStale) {
      highlights.add(
        'Market information may be outdated.',
      );
    }
  }

  static void _addSessionHighlights(
      ScanSession session,
      List<String> highlights,
      ) {
    if (session.isOffline) {
      highlights.add(
        'This scan was processed offline.',
      );
    }

    if (session.requiresSync) {
      highlights.add(
        'Additional intelligence is waiting to sync.',
      );
    }

    if (session.contributionCount > 0) {
      final int count = session.contributionCount;

      highlights.add(
        '$count intelligence ${count == 1 ? 'contribution' : 'contributions'} evaluated.',
      );
    }

    if (session.warnings.isNotEmpty) {
      final int count = session.warnings.length;

      highlights.add(
        '$count scan ${count == 1 ? 'warning requires' : 'warnings require'} review.',
      );
    }
  }

  static int? _confidencePercent(
      double confidence,
      ) {
    if (!confidence.isFinite || confidence <= 0) {
      return null;
    }

    final double normalized =
    confidence <= 1 ? confidence * 100 : confidence;

    return normalized.round().clamp(0, 100);
  }

  static String _formatMoney(
      double value,
      String currencyCode,
      ) {
    final String normalizedCurrency =
    currencyCode.trim().toUpperCase();

    final String symbol;

    switch (normalizedCurrency) {
      case 'USD':
        symbol = r'$';

      case 'CAD':
        symbol = r'CA$';

      case 'GBP':
        symbol = '£';

      case 'EUR':
        symbol = '€';

      default:
        symbol = normalizedCurrency.isEmpty
            ? ''
            : '$normalizedCurrency ';
    }

    return '$symbol${value.toStringAsFixed(2)}';
  }
}