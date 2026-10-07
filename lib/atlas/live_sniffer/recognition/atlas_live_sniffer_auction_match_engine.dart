import '../../catalog/models/atlas_catalog_product.dart';
import '../../catalog/services/atlas_catalog_service.dart';
import '../models/atlas_live_sniffer_box_candidate.dart';
import 'atlas_live_sniffer_identity_gate.dart';

enum AtlasAuctionMatchStage {
  scanning,
  identityHypothesis,
  numberLocked,
  provisional,
  confirmed,
}

enum AtlasAuctionRejectionReason {
  none,
  noProductNumber,
  emptyPartition,
  lowTokenOverlap,
  identityContradiction,
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
      (stage == AtlasAuctionMatchStage.provisional ||
          stage == AtlasAuctionMatchStage.confirmed) &&
      confidence >= AtlasLiveSnifferAuctionMatchEngine.provisionalThreshold;

  bool get hasStrongMatch =>
      bestMatch != null &&
      stage == AtlasAuctionMatchStage.confirmed &&
      confidence >= AtlasLiveSnifferAuctionMatchEngine.confirmedThreshold;

  bool get isAmbiguous => matches.length > 1 && !hasStrongMatch;
  bool get isIdentityHypothesis =>
      stage == AtlasAuctionMatchStage.identityHypothesis;
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

  Future<AtlasLiveSnifferAuctionMatch> match(
    AtlasLiveSnifferBoxCandidate candidate,
  ) async {
    final String rawOcr = candidate.text;
    final List<String> tokenList = _tokenList(rawOcr);
    final Set<String> evidenceTokens = tokenList.toSet();

    final String normalizedProductNumber = candidate.productNumber.trim();

    // NAME-FIRST identity authority:
    // Build a catalog family from selected-target name/franchise OCR first.
    // A raw number is never allowed to open a global catalog partition.
    final List<AtlasCatalogProduct> identityFamily =
        await _searchIdentityFamily(rawOcr);

    if (identityFamily.isEmpty) {
      return AtlasLiveSnifferAuctionMatch(
        candidate: candidate,
        matches: const <AtlasCatalogProduct>[],
        confidence: 0,
        stage: normalizedProductNumber.isEmpty
            ? AtlasAuctionMatchStage.scanning
            : AtlasAuctionMatchStage.numberLocked,
        diagnostics: AtlasAuctionDiagnostics(
          rawOcrText: rawOcr,
          normalizedTokens: evidenceTokens,
          partitionSize: 0,
          anchorScore: normalizedProductNumber.isEmpty ? 0 : numberAnchorBonus,
          coverageScore: 0,
          separationScore: 0,
          orderBonus: 0,
          rejectionReason: normalizedProductNumber.isEmpty
              ? AtlasAuctionRejectionReason.lowTokenOverlap
              : AtlasAuctionRejectionReason.waitingConfirmation,
        ),
      );
    }

    // If Atlas has established who the Pop is but not which numbered release,
    // expose only a safe identity hypothesis to the controller. HAVE?/PRICE
    // remain blocked until number verification succeeds.
    if (normalizedProductNumber.isEmpty || normalizedProductNumber == '0') {
      final List<AtlasCatalogProduct> rankedFamily = _rankIdentityFamily(
        candidate,
        identityFamily,
      );

      return AtlasLiveSnifferAuctionMatch(
        candidate: candidate,
        matches: List<AtlasCatalogProduct>.unmodifiable(rankedFamily.take(6)),
        confidence: rankedFamily.isEmpty ? 0 : 0.50,
        stage: AtlasAuctionMatchStage.identityHypothesis,
        diagnostics: AtlasAuctionDiagnostics(
          rawOcrText: rawOcr,
          normalizedTokens: evidenceTokens,
          partitionSize: identityFamily.length,
          anchorScore: 0,
          coverageScore: rankedFamily.isEmpty ? 0 : 0.50,
          separationScore: 0,
          orderBonus: 0,
          rejectionReason: AtlasAuctionRejectionReason.waitingConfirmation,
        ),
      );
    }

    // NUMBER SECOND:
    // The number may only choose a release inside the already-established
    // identity family. Never broaden back out to all catalog records #372.
    final List<AtlasCatalogProduct> products = identityFamily
        .where((AtlasCatalogProduct product) {
          return (product.productNumber?.trim() ?? '') ==
              normalizedProductNumber;
        })
        .toList(growable: false);

    if (products.isEmpty) {
      final List<AtlasCatalogProduct> rankedFamily = _rankIdentityFamily(
        candidate,
        identityFamily,
      );

      return AtlasLiveSnifferAuctionMatch(
        candidate: candidate,
        matches: List<AtlasCatalogProduct>.unmodifiable(rankedFamily.take(6)),
        confidence: rankedFamily.isEmpty ? 0 : 0.50,
        stage: AtlasAuctionMatchStage.identityHypothesis,
        diagnostics: AtlasAuctionDiagnostics(
          rawOcrText: rawOcr,
          normalizedTokens: evidenceTokens,
          partitionSize: identityFamily.length,
          anchorScore: numberAnchorBonus,
          coverageScore: rankedFamily.isEmpty ? 0 : 0.50,
          separationScore: 0,
          orderBonus: 0,
          rejectionReason: AtlasAuctionRejectionReason.waitingConfirmation,
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
        bool identityValidated,
        bool identityContradicted,
      })
    >
    scored =
        products
            .map((AtlasCatalogProduct product) {
              final breakdown = _scoreBreakdown(
                candidate,
                tokenList,
                evidenceTokens,
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
                identityValidated: breakdown.identityValidated,
                identityContradicted: breakdown.identityContradicted,
              );
            })
            .toList(growable: false)
          ..sort((a, b) {
            final int contradictionOrder = (a.identityContradicted ? 1 : 0)
                .compareTo(b.identityContradicted ? 1 : 0);
            if (contradictionOrder != 0) return contradictionOrder;

            // A candidate must first pass the identity evidence gate. Raw OCR
            // overlap is only useful after the name/franchise evidence agrees.
            final int validationOrder = (b.identityValidated ? 1 : 0).compareTo(
              a.identityValidated ? 1 : 0,
            );
            if (validationOrder != 0) return validationOrder;

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

    if (best.identityContradicted || !best.identityValidated) {
      return AtlasLiveSnifferAuctionMatch(
        candidate: candidate,
        matches: const <AtlasCatalogProduct>[],
        confidence: 0,
        stage: AtlasAuctionMatchStage.numberLocked,
        diagnostics: AtlasAuctionDiagnostics(
          rawOcrText: rawOcr,
          normalizedTokens: evidenceTokens,
          partitionSize: products.length,
          anchorScore: best.anchor,
          coverageScore: best.coverage,
          separationScore: 0,
          orderBonus: best.orderBonus,
          rejectionReason: best.identityContradicted
              ? AtlasAuctionRejectionReason.identityContradiction
              : AtlasAuctionRejectionReason.lowTokenOverlap,
        ),
      );
    }

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
    final bool identityValidated = best.identityValidated;
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
    bool identityValidated,
    bool identityContradicted,
  })
  _scoreBreakdown(
    AtlasLiveSnifferBoxCandidate candidate,
    List<String> rawTokens,
    Set<String> evidence,
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
        identityValidated: false,
        identityContradicted: false,
      );
    }

    final Set<String> nameTokens = _tokens(product.displayName);
    final Set<String> characterTokens = _tokens(product.characterName ?? '');
    final Set<String> seriesTokens = _tokens(product.series ?? '');
    final Set<String> variantTokens = _tokens(product.variantName ?? '');
    final Set<String> lineTokens = _tokens(product.productLine ?? '');

    final AtlasLiveSnifferIdentityEvidence identity =
        AtlasLiveSnifferIdentityGate.evaluate(
          rawOcr: candidate.text,
          displayName: product.displayName,
          characterName: product.characterName,
          series: product.series,
          productLine: product.productLine,
          variantName: product.variantName,
        );
    final int identityHits = identity.identityHits;
    final double identityCoverage = identity.identityCoverage;

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
      identityValidated: identity.validated,
      identityContradicted: identity.contradicted,
    );
  }

  Future<List<AtlasCatalogProduct>> _searchIdentityFamily(String rawOcr) async {
    final List<String> queryTokens = _identityQueryTokens(rawOcr);
    if (queryTokens.isEmpty) {
      return const <AtlasCatalogProduct>[];
    }

    final Map<String, AtlasCatalogProduct> merged =
        <String, AtlasCatalogProduct>{};

    // Search a few of the strongest foreground words independently. This avoids
    // requiring the repository to understand an entire noisy OCR sentence.
    for (final String token in queryTokens.take(4)) {
      final List<AtlasCatalogProduct> found = await _catalogService.search(
        query: token,
        limit: 40,
      );

      for (final AtlasCatalogProduct product in found) {
        final AtlasLiveSnifferIdentityEvidence identity =
            AtlasLiveSnifferIdentityGate.evaluate(
              rawOcr: rawOcr,
              displayName: product.displayName,
              characterName: product.characterName,
              series: product.series,
              productLine: product.productLine,
              variantName: product.variantName,
            );

        if (!identity.validated || identity.contradicted) {
          continue;
        }

        final String key = [
          product.displayName,
          product.productNumber ?? '',
          product.series ?? '',
          product.variantName ?? '',
        ].join('|').toLowerCase();

        merged[key] = product;
      }
    }

    return List<AtlasCatalogProduct>.unmodifiable(merged.values);
  }

  List<AtlasCatalogProduct> _rankIdentityFamily(
    AtlasLiveSnifferBoxCandidate candidate,
    List<AtlasCatalogProduct> family,
  ) {
    final List<({AtlasCatalogProduct product, int hits, double coverage})>
    ranked =
        family
            .map((AtlasCatalogProduct product) {
              final AtlasLiveSnifferIdentityEvidence identity =
                  AtlasLiveSnifferIdentityGate.evaluate(
                    rawOcr: candidate.text,
                    displayName: product.displayName,
                    characterName: product.characterName,
                    series: product.series,
                    productLine: product.productLine,
                    variantName: product.variantName,
                  );
              return (
                product: product,
                hits: identity.identityHits,
                coverage: identity.identityCoverage,
              );
            })
            .toList(growable: false)
          ..sort((a, b) {
            final int hitOrder = b.hits.compareTo(a.hits);
            if (hitOrder != 0) return hitOrder;
            return b.coverage.compareTo(a.coverage);
          });

    return ranked.map((entry) => entry.product).toList(growable: false);
  }

  List<String> _identityQueryTokens(String value) {
    const Set<String> ignored = <String>{
      'pop',
      'funko',
      'vinyl',
      'figure',
      'figures',
      'animation',
      'heroes',
      'movies',
      'movie',
      'television',
      'games',
      'game',
      'rocks',
      'exclusive',
      'limited',
      'edition',
      'collectible',
      'collectibles',
      'warning',
      'ages',
      'made',
      'standard',
      'release',
      'special',
      'chase',
      'glow',
      'metallic',
      'flocked',
      'diamond',
      'the',
      'and',
      'for',
      'with',
      'from',
      'this',
      'that',
      'these',
      'those',
      'your',
      'you',
      'are',
      'was',
      'were',
      'have',
      'has',
    };

    final Set<String> unique = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .split(' ')
        .map((String token) => token.trim())
        .where((String token) {
          if (token.length < 3) return false;
          if (ignored.contains(token)) return false;
          if (RegExp(r'^\d+$').hasMatch(token)) return false;
          return true;
        })
        .toSet();

    final List<String> result = unique.toList(growable: false)
      ..sort((String a, String b) {
        final int lengthOrder = b.length.compareTo(a.length);
        if (lengthOrder != 0) return lengthOrder;
        return a.compareTo(b);
      });

    return result;
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
}
