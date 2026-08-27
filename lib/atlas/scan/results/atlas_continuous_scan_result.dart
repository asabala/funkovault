import '../../catalog/models/atlas_catalog_product.dart';
import '../../catalog/services/atlas_barcode_catalog_resolver.dart';
import '../models/scan_session.dart';

/// Immutable completed background-resolution result for one physical track.
class AtlasContinuousScanResult {
  const AtlasContinuousScanResult({
    required this.trackId,
    required this.session,
    required this.catalogResolution,
    required this.completedAt,
  });

  final String trackId;
  final ScanSession session;
  final AtlasBarcodeResolution catalogResolution;
  final DateTime completedAt;

  bool get requiresUserReview {
    return session.requiresUserAction || !catalogResolution.hasSingleMatch;
  }

  AtlasCatalogProduct? get resolvedCatalogProduct {
    return session.catalogProduct ?? catalogResolution.singleMatch;
  }
}
