import '../../catalog/resolution/catalog_resolution_request.dart';
import '../../catalog/resolution/catalog_resolution_result.dart';
import '../../catalog/resolution/catalog_resolution_service.dart';
import '../contributions/contribution_conflict_policy.dart';
import '../contributions/product_resolution_contribution.dart';
import '../identity/identity_evidence.dart';
import '../identity/identity_evidence_builder.dart';
import '../identity/identity_hypothesis.dart';
import '../models/scan_session.dart';
import '../resolution/product_resolution.dart';
import '../resolution/resolved_product_snapshot.dart';
import 'abstract_scan_engine.dart';
import 'engine_context.dart';
import 'engine_result.dart';
import 'engine_support.dart';

// Resolves identity hypotheses into canonical Atlas catalog products.
//
// Catalog searching, candidate ranking, and match decisions are delegated
// to CatalogResolutionService. This engine only coordinates the scan
// intelligence pipeline.
final class ProductResolutionEngine
    extends AbstractScanEngine {
  const ProductResolutionEngine(
      this._resolutionService,
      );

  static const String id =
      'atlas.scan.product-resolution';

  static const String capabilityId =
      'atlas.capability.product-resolution';

  final CatalogResolutionService _resolutionService;

  @override
  String get engineId {
    return id;
  }

  @override
  String get displayName {
    return 'Product Resolution';
  }

  @override
  Future<EngineResult> execute(
      ScanSession session,
      EngineContext context,
      ) async {
    final IdentityEvidence evidence =
    IdentityEvidenceBuilder.fromSession(
      session,
    );

    if (!evidence.hasIdentity) {
      return EngineResult.skipped(
        session: session,
        reason: 'No identity evidence is available.',
        attributes: const <String, Object?>{
          'requirement': 'identityEvidence',
        },
      );
    }

    final IdentityHypothesis? hypothesis =
        evidence.primaryHypothesis;

    if (hypothesis == null) {
      return EngineResult.skipped(
        session: session,
        reason:
        'No primary identity hypothesis was available.',
      );
    }

    final CatalogResolutionRequest request =
    CatalogResolutionRequest(
      displayName: hypothesis.displayName,
      brand: hypothesis.brand,
      productLine: hypothesis.productLine,
      series: hypothesis.series,
      characterName: hypothesis.characterName,
      productNumber: hypothesis.productNumber,
      variantName: hypothesis.variantName,
      sourceConfidence:
      hypothesis.confidence ?? 0.0,
      attributes: <String, Object?>{
        'hypothesisId': hypothesis.hypothesisId,
        'supportingContributionIds':
        hypothesis.supportingContributionIds,
      },
    );

    final CatalogResolutionResult catalogResult =
    await _resolutionService.resolve(
      request,
    );

    final selectedMatch =
        catalogResult.selectedMatch;

    if (selectedMatch == null) {
      return EngineResult.skipped(
        session: session,
        reason:
        catalogResult.resolutionReason ??
            'No catalog product could be resolved.',
        attributes: <String, Object?>{
          'hypothesisId': hypothesis.hypothesisId,
          'candidateCount':
          catalogResult.candidateMatches.length,
          'requiresReview':
          catalogResult.requiresReview,
        },
      );
    }

    final bool requiresReview =
        evidence.requiresReview ||
            catalogResult.requiresReview ||
            selectedMatch.requiresReview;

    final ResolvedProductSnapshot resolvedProduct =
    ResolvedProductSnapshot.fromCatalogProduct(
      selectedMatch.product,
    );

    final ProductResolution resolution =
    ProductResolution(
      productId: resolvedProduct.productId,
      displayName: resolvedProduct.displayName,
      resolvedProduct: resolvedProduct,
      matchConfidence: selectedMatch.confidence,
      requiresReview: requiresReview,
      attributes: <String, Object?>{
        'hypothesisId': hypothesis.hypothesisId,
        'resolutionReason':
        catalogResult.resolutionReason,
        'matchReason': selectedMatch.matchReason,
        'candidateCount':
        catalogResult.candidateMatches.length,
      },
    );

    final ProductResolutionContribution
    contribution =
    ProductResolutionContribution(
      contributionId:
      EngineSupport.buildContributionId(
        namespace: 'atlas.resolution',
        segments: <Object?>[
          hypothesis.hypothesisId,
          resolution.productId.value,
        ],
      ),
      sourceEngineId: engineId,
      createdAt: session.startedAt,
      resolution: resolution,
      confidence: resolution.matchConfidence,
      attributes: <String, Object?>{
        'resolutionReason':
        catalogResult.resolutionReason,
        'matchReason':
        selectedMatch.matchReason,
        'candidateCount':
        catalogResult.candidateMatches.length,
      },
    );

    final ScanSession updatedSession =
    session.addContributions(
      <ProductResolutionContribution>[
        contribution,
      ],
      conflictPolicy:
      ContributionConflictPolicy.replaceExisting,
    );

    return EngineResult.success(
      session: updatedSession,
      attributes: <String, Object?>{
        'resolvedProductId':
        resolution.productId.value,
        'matchConfidence':
        resolution.matchConfidence,
        'requiresReview':
        resolution.requiresReview,
        'candidateCount':
        catalogResult.candidateMatches.length,
        'resolutionReason':
        catalogResult.resolutionReason,
      },
    );
  }
}