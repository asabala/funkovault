import '../models/atlas_catalog_product.dart';
import '../models/catalog_match.dart';

// Scores catalog candidates against recognized identity information.
//
// This first implementation intentionally uses a straightforward scoring
// algorithm. It establishes the public API while allowing future versions
// to incorporate barcode confidence, OCR confidence, AI ranking, and
// collector-specific intelligence without changing callers.
final class CatalogMatcher {
  const CatalogMatcher();

  List<CatalogMatch> rankCandidates({
    required Iterable<AtlasCatalogProduct> candidates,
    String? displayName,
    String? productNumber,
    String? series,
    String? variantName,
  }) {
    final List<CatalogMatch> matches =
    <CatalogMatch>[];

    final String normalizedName =
    _normalize(displayName);

    final String normalizedSeries =
    _normalize(series);

    final String normalizedNumber =
    _normalize(productNumber);

    final String normalizedVariant =
    _normalize(variantName);

    for (final AtlasCatalogProduct product
    in candidates) {
      double score = 0.0;

      if (normalizedName.isNotEmpty &&
          _normalize(product.displayName) ==
              normalizedName) {
        score += 0.50;
      }

      if (normalizedSeries.isNotEmpty &&
          _normalize(product.series) ==
              normalizedSeries) {
        score += 0.20;
      }

      if (normalizedNumber.isNotEmpty &&
          _normalize(product.productNumber) ==
              normalizedNumber) {
        score += 0.20;
      }

      if (normalizedVariant.isNotEmpty &&
          _normalize(product.variantName) ==
              normalizedVariant) {
        score += 0.10;
      }

      if (score <= 0.0) {
        continue;
      }

      matches.add(
        CatalogMatch(
          product: product,
          confidence: score.clamp(0.0, 1.0),
          requiresReview: score < 0.95,
          matchReason:
          'Identity similarity',
          attributes: <String, Object?>{
            'score': score,
          },
        ),
      );
    }

    matches.sort(
          (CatalogMatch a, CatalogMatch b) =>
          b.confidence.compareTo(
            a.confidence,
          ),
    );

    return List<CatalogMatch>.unmodifiable(
      matches,
    );
  }

  String _normalize(
      String? value,
      ) {
    return value
        ?.trim()
        .toLowerCase() ??
        '';
  }
}