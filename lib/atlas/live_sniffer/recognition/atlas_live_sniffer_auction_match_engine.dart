import '../../catalog/models/atlas_catalog_product.dart';
import '../../catalog/services/atlas_catalog_service.dart';
import '../models/atlas_live_sniffer_box_candidate.dart';

final class AtlasLiveSnifferAuctionMatch {
  const AtlasLiveSnifferAuctionMatch({
    required this.candidate,
    required this.matches,
    required this.confidence,
  });

  final AtlasLiveSnifferBoxCandidate candidate;
  final List<AtlasCatalogProduct> matches;
  final double confidence;

  AtlasCatalogProduct? get bestMatch => matches.isEmpty ? null : matches.first;
  bool get hasLikelyMatch => bestMatch != null && confidence >= 0.50;
  bool get hasStrongMatch => bestMatch != null && confidence >= 0.78;
  bool get isAmbiguous => matches.length > 1 && !hasStrongMatch;
}

final class AtlasLiveSnifferAuctionMatchEngine {
  AtlasLiveSnifferAuctionMatchEngine({AtlasCatalogService? catalogService})
    : _catalogService = catalogService ?? AtlasCatalogService.instance;

  final AtlasCatalogService _catalogService;

  Future<AtlasLiveSnifferAuctionMatch> match(
    AtlasLiveSnifferBoxCandidate candidate,
  ) async {
    final List<AtlasCatalogProduct> products = await _catalogService.search(
      productNumber: candidate.productNumber,
      limit: 20,
    );

    if (products.isEmpty) {
      return AtlasLiveSnifferAuctionMatch(
        candidate: candidate,
        matches: const <AtlasCatalogProduct>[],
        confidence: 0,
      );
    }

    final List<({AtlasCatalogProduct product, double score})> scored =
        products
            .map((AtlasCatalogProduct product) {
              return (product: product, score: _score(candidate.text, product));
            })
            .toList(growable: false)
          ..sort((a, b) => b.score.compareTo(a.score));

    final double bestScore = scored.first.score;
    final double secondScore = scored.length > 1 ? scored[1].score : 0;
    final double separation = (bestScore - secondScore)
        .clamp(0.0, 1.0)
        .toDouble();
    final double confidence = (bestScore * 0.82 + separation * 0.18)
        .clamp(0.0, 1.0)
        .toDouble();

    final List<AtlasCatalogProduct> plausible = scored
        .where((entry) => entry.score >= (bestScore - 0.16).clamp(0.0, 1.0))
        .take(6)
        .map((entry) => entry.product)
        .toList(growable: false);

    return AtlasLiveSnifferAuctionMatch(
      candidate: candidate,
      matches: List<AtlasCatalogProduct>.unmodifiable(plausible),
      confidence: confidence,
    );
  }

  double _score(String recognizedText, AtlasCatalogProduct product) {
    final Set<String> evidence = _tokens(recognizedText);
    if (evidence.isEmpty) return 0.15;

    double score = 0.18;

    final Set<String> nameTokens = _tokens(product.displayName);
    final Set<String> characterTokens = _tokens(product.characterName ?? '');
    final Set<String> seriesTokens = _tokens(product.series ?? '');
    final Set<String> variantTokens = _tokens(product.variantName ?? '');
    final Set<String> lineTokens = _tokens(product.productLine ?? '');

    score += _coverage(evidence, nameTokens) * 0.32;
    score += _coverage(evidence, characterTokens) * 0.18;
    score += _coverage(evidence, seriesTokens) * 0.15;
    score += _coverage(evidence, variantTokens) * 0.10;
    score += _coverage(evidence, lineTokens) * 0.07;

    return score.clamp(0.0, 1.0).toDouble();
  }

  double _coverage(Set<String> evidence, Set<String> target) {
    if (target.isEmpty) return 0;
    final int hits = target.where(evidence.contains).length;
    return hits / target.length;
  }

  Set<String> _tokens(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .split(' ')
        .map((String token) => token.trim())
        .where((String token) => token.length >= 2)
        .toSet();
  }
}
