import '../matching/catalog_matcher.dart';
import '../models/atlas_catalog_product.dart';
import '../models/catalog_match.dart';
import '../repository/atlas_catalog_repository.dart';
import 'catalog_resolution_request.dart';
import 'catalog_resolution_result.dart';

// Resolves product identity requests into catalog matches.
//
// This service owns catalog search and ranking. It intentionally hides the
// repository implementation and matching strategy from callers so that both
// can evolve independently.
final class CatalogResolutionService {
  CatalogResolutionService(
      this._repository, [
        this._matcher = const CatalogMatcher(),
      ]);

  final AtlasCatalogRepository _repository;
  final CatalogMatcher _matcher;

  Future<CatalogResolutionResult> resolve(
      CatalogResolutionRequest request,
      ) async {
    final List<AtlasCatalogProduct> candidates =
    await _repository.search(
      query: request.displayName,
      categoryCode: request.categoryCode,
      brand: request.brand,
      productLine: request.productLine,
      series: request.series,
      characterName: request.characterName,
      productNumber: request.productNumber,
      variantName: request.variantName,
    );

    final List<CatalogMatch> matches =
    _matcher.rankCandidates(
      candidates: candidates,
      displayName: request.displayName,
      productNumber: request.productNumber,
      series: request.series,
      variantName: request.variantName,
    );

    if (matches.isEmpty) {
      return CatalogResolutionResult(
        resolutionReason:
        'No catalog matches were found.',
      );
    }

    final CatalogMatch bestMatch =
        matches.first;

    return CatalogResolutionResult(
      selectedMatch: bestMatch,
      candidateMatches: matches,
      requiresReview:
      bestMatch.requiresReview,
      resolutionReason:
      'Resolved using catalog matching.',
    );
  }
}