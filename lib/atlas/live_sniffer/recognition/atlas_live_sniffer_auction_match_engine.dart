import '../../catalog/models/atlas_catalog_product.dart';
import '../../catalog/services/atlas_catalog_service.dart';
import '../models/atlas_live_sniffer_box_candidate.dart';

enum AtlasAuctionMatchStage { scanning, numberLocked, provisional, confirmed }

enum AtlasAuctionRejectionReason {
  none,
  noProductNumber,
  emptyPartition,
  lowTokenOverlap,
  ambiguousPartition,
  lowConfidence,
  waitingConfirmation,
}

final class AtlasAuctionDiagnostics {
  const AtlasAuctionDiagnostics({
    required this.rawOcrText,
    required this.normalizedTokens,
    required this.partitionSize,
    required this.anchorScore,
    required this.coverageScore,
    required this.separationScore,
    required this.orderBonus,
    required this.rejectionReason,
  });

  final String rawOcrText;
  final Set<String> normalizedTokens;
  final int partitionSize;
  final double anchorScore;
  final double coverageScore;
  final double separationScore;
  final double orderBonus;
  final AtlasAuctionRejectionReason rejectionReason;

  String toDiagnosticString() {
    return 'PartSize: $partitionSize | Anchor: ${anchorScore.toStringAsFixed(2)} | '
        'Cov: ${coverageScore.toStringAsFixed(2)} | Sep: ${separationScore.toStringAsFixed(2)} | '
        'Order: ${orderBonus.toStringAsFixed(2)} | Reason: ${rejectionReason.name}';
  }
}

final class AtlasLiveSnifferAuctionMatch {
  const AtlasLiveSnifferAuctionMatch({
    required this.candidate,
    required this.matches,
    required this.confidence,
    required this.stage,
    required this.diagnostics,
  });

  final AtlasLiveSnifferBoxCandidate candidate;
  final List<AtlasCatalogProduct> matches;
  final double confidence;
  final AtlasAuctionMatchStage stage;
  final AtlasAuctionDiagnostics diagnostics;

  AtlasCatalogProduct? get bestMatch => matches.isEmpty ? null : matches.first;

  bool get hasLikelyMatch =>
      bestMatch != null &&
      confidence >= AtlasLiveSnifferAuctionMatchEngine.provisionalThreshold;

  bool get hasStrongMatch =>
      bestMatch != null &&
      confidence >= AtlasLiveSnifferAuctionMatchEngine.confirmedThreshold;

  bool get isAmbiguous => matches.length > 1 && !hasStrongMatch;
  bool get isNumberLocked => stage == AtlasAuctionMatchStage.numberLocked;
  bool get isProvisional => stage == AtlasAuctionMatchStage.provisional;
  bool get isConfirmed => stage == AtlasAuctionMatchStage.confirmed;
}

final class AtlasLiveSnifferAuctionMatchEngine {
  AtlasLiveSnifferAuctionMatchEngine({AtlasCatalogService? catalogService})
    : _catalogService = catalogService ?? AtlasCatalogService.instance;

  final AtlasCatalogService _catalogService;

  static const double provisionalThreshold = 0.35;
  static const double confirmedThreshold = 0.72;

  static const double numberAnchorBonus = 0.35;
  static const double fallbackBaseline = 0.18;
  static const double singleCandidateSeparationBonus = 0.15;

  // Generic packaging words are useful for proving that OCR is looking at a
  // Funko box, but they are not product identity. Never let these words turn a
  // shared product number into a named catalog match.
  static const Set<String> _nonIdentityTokens = <String>{
    'pop',
    'funko',
    'vinyl',
    'figure',
    'figures',
    'animation',
    'heroes',
    'movies',
    'television',
    'games',
    'rocks',
    'exclusive',
    'limited',
    'edition',
    'collectible',
    'collectibles',
    'warning',
    'ages',
    'made',
  };

  Future<AtlasLiveSnifferAuctionMatch> match(
    AtlasLiveSnifferBoxCandidate candidate,
  ) async {
    final String rawOcr = candidate.text;
    final List<String> tokenList = _tokenList(rawOcr);
    final Set<String> evidenceTokens = tokenList.toSet();

    final String normalizedProductNumber = candidate.productNumber.trim();
    final Set<String> identityEvidence = _identityTokens(rawOcr)
      ..remove(normalizedProductNumber.toLowerCase());

    if (normalizedProductNumber.isEmpty || normalizedProductNumber == '0') {
      return AtlasLiveSnifferAuctionMatch(
        candidate: candidate,
        matches: const <AtlasCatalogProduct>[],
        confidence: 0,
        stage: AtlasAuctionMatchStage.scanning,
        diagnostics: AtlasAuctionDiagnostics(
          rawOcrText: rawOcr,
          normalizedTokens: evidenceTokens,
          partitionSize: 0,
          anchorScore: 0,
          coverageScore: 0,
          separationScore: 0,
          orderBonus: 0,
          rejectionReason: AtlasAuctionRejectionReason.noProductNumber,
        ),
      );
    }

    final List<AtlasCatalogProduct> products = await _catalogService.search(
      productNumber: candidate.productNumber,
      limit: 20,
    );

    if (products.isEmpty) {
      // A number that does not exist in the catalog is not an identity lock.
      // Keep scanning so another OCR frame can correct a smudged/misread digit.
      return AtlasLiveSnifferAuctionMatch(
        candidate: candidate,
        matches: const <AtlasCatalogProduct>[],
        confidence: 0,
        stage: AtlasAuctionMatchStage.scanning,
        diagnostics: AtlasAuctionDiagnostics(
          rawOcrText: rawOcr,
          normalizedTokens: evidenceTokens,
          partitionSize: 0,
          anchorScore: numberAnchorBonus,
          coverageScore: 0,
          separationScore: 0,
          orderBonus: 0,
          rejectionReason: AtlasAuctionRejectionReason.emptyPartition,
        ),
      );
    }

    final List<
      ({
        AtlasCatalogProduct product,
        double totalScore,
        double anchor,
        double coverage,
        double orderBonus,
        int identityHits,
        double identityCoverage,
      })
    >
    scored =
        products
            .map((AtlasCatalogProduct product) {
              final breakdown = _scoreBreakdown(
                candidate,
                tokenList,
                evidenceTokens,
                identityEvidence,
                product,
              );
              return (
                product: product,
                totalScore: breakdown.totalScore,
                anchor: breakdown.anchor,
                coverage: breakdown.coverage,
                orderBonus: breakdown.orderBonus,
                identityHits: breakdown.identityHits,
                identityCoverage: breakdown.identityCoverage,
              );
            })
            .toList(growable: false)
          ..sort((a, b) {
            // A real name/series/character token from the selected box outranks
            // generic OCR coverage. This prevents #926 + "One Piece" from
            // resolving to an unrelated #926 catalog record.
            final int identityHitOrder = b.identityHits.compareTo(
              a.identityHits,
            );
            if (identityHitOrder != 0) return identityHitOrder;
            final int identityCoverageOrder = b.identityCoverage.compareTo(
              a.identityCoverage,
            );
            if (identityCoverageOrder != 0) return identityCoverageOrder;
            return b.totalScore.compareTo(a.totalScore);
          });

    final best = scored.first;
    final double secondScore = scored.length > 1 ? scored[1].totalScore : 0;
    final double separation = (best.totalScore - secondScore)
        .clamp(0.0, 1.0)
        .toDouble();

    final double effectiveSeparation = scored.length == 1
        ? singleCandidateSeparationBonus
        : separation;

    final double scoredConfidence =
        (best.totalScore * 0.80 + effectiveSeparation * 0.20)
            .clamp(0.0, 1.0)
            .toDouble();

    // A product number is the lookup anchor, not sufficient release identity.
    // Even when the local catalog partition contains only one record, require
    // supporting OCR name/series/character evidence before projecting that
    // record to the HUD. This prevents incomplete catalog partitions from
    // turning a valid shared number into the wrong Pop name.
    final double confidence = scoredConfidence;

    final List<AtlasCatalogProduct> plausible = scored
        .where(
          (entry) =>
              entry.totalScore >= (best.totalScore - 0.18).clamp(0.0, 1.0),
        )
        .take(6)
        .map((entry) => entry.product)
        .toList(growable: false);

    final AtlasAuctionMatchStage stage;
    final AtlasAuctionRejectionReason rejectionReason;

    // Product number narrows the catalog partition; it never names the Pop.
    // Require at least one discriminative identity word from the selected box
    // to overlap the candidate's name/character/series/product line.
    final bool identityValidated = best.identityHits > 0;
    final bool shortNumberNeedsMoreEvidence =
        normalizedProductNumber.length <= 2 && !identityValidated;
    final bool catalogTitleNeedsMoreEvidence = !identityValidated;

    if (confidence >= confirmedThreshold &&
        !shortNumberNeedsMoreEvidence &&
        !catalogTitleNeedsMoreEvidence) {
      stage = AtlasAuctionMatchStage.confirmed;
      rejectionReason = AtlasAuctionRejectionReason.none;
    } else if (confidence >= provisionalThreshold &&
        !shortNumberNeedsMoreEvidence &&
        !catalogTitleNeedsMoreEvidence) {
      stage = AtlasAuctionMatchStage.provisional;
      rejectionReason = AtlasAuctionRejectionReason.waitingConfirmation;
    } else {
      stage = AtlasAuctionMatchStage.numberLocked;
      rejectionReason =
          (shortNumberNeedsMoreEvidence || catalogTitleNeedsMoreEvidence)
          ? AtlasAuctionRejectionReason.lowTokenOverlap
          : AtlasAuctionRejectionReason.lowConfidence;
    }

    return AtlasLiveSnifferAuctionMatch(
      candidate: candidate,
      matches: stage != AtlasAuctionMatchStage.numberLocked
          ? List<AtlasCatalogProduct>.unmodifiable(plausible)
          : const <AtlasCatalogProduct>[],
      confidence: confidence,
      stage: stage,
      diagnostics: AtlasAuctionDiagnostics(
        rawOcrText: rawOcr,
        normalizedTokens: evidenceTokens,
        partitionSize: products.length,
        anchorScore: best.anchor,
        coverageScore: best.coverage,
        separationScore: effectiveSeparation,
        orderBonus: best.orderBonus,
        rejectionReason: rejectionReason,
      ),
    );
  }

  ({
    double totalScore,
    double anchor,
    double coverage,
    double orderBonus,
    int identityHits,
    double identityCoverage,
  })
  _scoreBreakdown(
    AtlasLiveSnifferBoxCandidate candidate,
    List<String> rawTokens,
    Set<String> evidence,
    Set<String> identityEvidence,
    AtlasCatalogProduct product,
  ) {
    final double anchor = candidate.productNumber.isNotEmpty
        ? numberAnchorBonus
        : fallbackBaseline;

    if (evidence.isEmpty) {
      return (
        totalScore: anchor,
        anchor: anchor,
        coverage: 0,
        orderBonus: 0,
        identityHits: 0,
        identityCoverage: 0,
      );
    }

    final Set<String> nameTokens = _tokens(product.displayName);
    final Set<String> characterTokens = _tokens(product.characterName ?? '');
    final Set<String> seriesTokens = _tokens(product.series ?? '');
    final Set<String> variantTokens = _tokens(product.variantName ?? '');
    final Set<String> lineTokens = _tokens(product.productLine ?? '');

    final Set<String> productIdentityTokens = <String>{
      ..._identityTokens(product.displayName),
      ..._identityTokens(product.characterName ?? ''),
      ..._identityTokens(product.series ?? ''),
      ..._identityTokens(product.productLine ?? ''),
      ..._identityTokens(product.variantName ?? ''),
    };
    final int identityHits = productIdentityTokens
        .where(identityEvidence.contains)
        .length;
    final double identityCoverage = productIdentityTokens.isEmpty
        ? 0.0
        : (identityHits / productIdentityTokens.length)
              .clamp(0.0, 1.0)
              .toDouble();

    double coverage = 0.0;
    coverage += _coverage(evidence, nameTokens) * 0.25;
    coverage += _coverage(evidence, characterTokens) * 0.18;
    coverage += _coverage(evidence, seriesTokens) * 0.12;
    coverage += _coverage(evidence, variantTokens) * 0.06;
    coverage += _coverage(evidence, lineTokens) * 0.04;

    // Order bonus: rewards exact sequential appearance of title tokens
    double orderBonus = 0.0;
    final List<String> targetOrder = _tokenList(product.displayName);
    if (targetOrder.length >= 2 &&
        _checkSequentialOrder(rawTokens, targetOrder)) {
      orderBonus = 0.06;
    }

    final double identityBonus = (identityHits * 0.12)
        .clamp(0.0, 0.30)
        .toDouble();
    final double totalScore = (anchor + coverage + orderBonus + identityBonus)
        .clamp(0.0, 1.0)
        .toDouble();
    return (
      totalScore: totalScore,
      anchor: anchor,
      coverage: coverage,
      orderBonus: orderBonus,
      identityHits: identityHits,
      identityCoverage: identityCoverage,
    );
  }

  bool _checkSequentialOrder(List<String> raw, List<String> target) {
    int targetIdx = 0;
    for (final token in raw) {
      if (token == target[targetIdx]) {
        targetIdx++;
        if (targetIdx == target.length) return true;
      }
    }
    return false;
  }

  double _coverage(Set<String> evidence, Set<String> target) {
    if (target.isEmpty) return 0;
    final int hits = target.where(evidence.contains).length;
    return hits / target.length;
  }

  List<String> _tokenList(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .split(' ')
        .map((token) => token.trim())
        .where((token) => token.length >= 2)
        .toList(growable: false);
  }

  Set<String> _tokens(String value) => _tokenList(value).toSet();

  Set<String> _identityTokens(String value) {
    return _tokenList(value).where((String token) {
      if (_nonIdentityTokens.contains(token)) return false;
      if (RegExp(r'^\d+$').hasMatch(token)) return false;
      return token.length >= 3;
    }).toSet();
  }
}
