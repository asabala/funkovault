import '../contributions/contribution_collection.dart';
import '../contributions/product_resolution_contribution.dart';
import '../../identity/product/atlas_product_id.dart';
import '../models/scan_session.dart';
import '../resolution/resolved_product_snapshot.dart';
import '../workflow/identity_resolution_status.dart';

/// Immutable projected state derived from scanner intelligence contributions.
///
/// Scan engines contribute evidence. The projector converts that evidence into
/// the canonical state displayed by Atlas.
class ScanSessionProjection {
  const ScanSessionProjection({
    required this.status,
    required this.resolutionStatus,
    required this.atlasProductId,
    required this.resolvedProduct,
    required this.confidence,
  });

  final ScanSessionStatus status;

  final IdentityResolutionStatus resolutionStatus;

  final AtlasProductId? atlasProductId;

  final ResolvedProductSnapshot? resolvedProduct;

  final double confidence;
}

/// Converts immutable intelligence contributions into trusted ScanSession
/// state.
///
/// Engines should produce contributions rather than independently deciding
/// what the scanner UI displays.
abstract final class ScanSessionProjector {
  static ScanSessionProjection project({
    required ContributionCollection contributions,
    required ScanSessionStatus currentStatus,
    required IdentityResolutionStatus currentResolutionStatus,
    required AtlasProductId? currentAtlasProductId,
    required ResolvedProductSnapshot? currentResolvedProduct,
    required double currentConfidence,
    required bool isOffline,
  }) {
    final ProductResolutionContribution? resolutionContribution = contributions
        .latestOfType<ProductResolutionContribution>();

    if (resolutionContribution == null) {
      return ScanSessionProjection(
        status: currentStatus,
        resolutionStatus: currentResolutionStatus,
        atlasProductId: currentAtlasProductId,
        resolvedProduct: currentResolvedProduct,
        confidence: _normalizeConfidence(currentConfidence),
      );
    }

    final resolution = resolutionContribution.resolution;
    final double confidence = _normalizeConfidence(resolution.matchConfidence);

    if (resolution.requiresReview) {
      return ScanSessionProjection(
        status: ScanSessionStatus.awaitingConfirmation,
        resolutionStatus: IdentityResolutionStatus.ambiguous,
        atlasProductId: resolution.productId,
        resolvedProduct: resolution.resolvedProduct,
        confidence: confidence,
      );
    }

    return ScanSessionProjection(
      status: ScanSessionStatus.completed,
      resolutionStatus: isOffline
          ? IdentityResolutionStatus.resolvedLocal
          : IdentityResolutionStatus.resolvedRemote,
      atlasProductId: resolution.productId,
      resolvedProduct: resolution.resolvedProduct,
      confidence: confidence,
    );
  }

  static double _normalizeConfidence(double value) {
    if (!value.isFinite) {
      return 0.0;
    }

    return value.clamp(0.0, 1.0).toDouble();
  }
}
