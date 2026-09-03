import '../../../../models/pop.dart';
import '../../models/scan_session.dart';
import '../models/atlas_inspection_reference.dart';
import '../policies/inspection_recommendation_policy.dart';

final class AtlasGrailGuardService {
  const AtlasGrailGuardService({
    this.policy = const AtlasStandardGrailGuardPolicy(),
  });

  static const double defaultCollectorValueThreshold = 100.0;

  final AtlasInspectionRecommendationPolicy policy;

  AtlasInspectionRecommendation evaluate({
    required ScanSession session,
    required Pop product,
    double collectorValueThreshold = defaultCollectorValueThreshold,
    double? variantPriceSpread,
    double knownCounterfeitPrevalence = 0.0,
  }) {
    final inspection = session.visualInspectionContribution?.inspection;
    final assessment = session.authenticityContribution?.assessment;

    final AtlasInspectionReferenceCriteria reference =
        inspection?.referenceCriteria ??
        AtlasInspectionReferenceCriteria.unknown(
          productId:
              session.atlasProductId?.value ?? 'scan-${session.sessionId}',
          upc: _firstMeaningful(<String>[
            session.resolvedProduct?.primaryBarcode ?? '',
            product.sourceUpc,
          ]),
        );

    final bool hasWeakReferenceCoverage = assessment != null
        ? assessment.referenceCoverage < 0.50
        : inspection?.referenceCriteria != null &&
              !inspection!.referenceCriteria!.canSupportConcernAssessment;

    return policy.evaluate(
      reference: reference,
      context: AtlasInspectionRecommendationContext(
        marketValue: _marketValue(session, product),
        variantPriceSpread: variantPriceSpread,
        knownCounterfeitPrevalence: knownCounterfeitPrevalence,
        collectorValueThreshold: collectorValueThreshold,
        requiresVariantConfirmation: session.requiresVariantConfirmation,
        isLimitedEdition: _hasMeaningfulValue(product.limitedEdition),
        hasAutographOrAuthentication:
            _hasMeaningfulSignature(product.signature) ||
            _hasMeaningfulValue(product.authenticationProvider) ||
            _hasMeaningfulValue(product.authenticityNumber),
        hasWeakReferenceCoverage: hasWeakReferenceCoverage,
      ),
    );
  }

  double? _marketValue(ScanSession session, Pop product) {
    final snapshot = session.marketSnapshot;
    final double? value =
        snapshot?.estimatedValue ??
        snapshot?.lastSalePrice ??
        snapshot?.recentSaleHigh;

    if (value != null && value.isFinite && value >= 0.0) {
      return value;
    }

    if (product.value.isFinite && product.value > 0.0) {
      return product.value;
    }

    return null;
  }

  String? _firstMeaningful(List<String> values) {
    for (final String value in values) {
      final String normalized = value.trim();
      if (normalized.isNotEmpty) {
        return normalized;
      }
    }
    return null;
  }

  bool _hasMeaningfulValue(String value) {
    final String normalized = value.trim().toLowerCase();
    return normalized.isNotEmpty &&
        normalized != 'none' &&
        normalized != 'no' &&
        normalized != 'n/a' &&
        normalized != 'na' &&
        normalized != 'common' &&
        normalized != 'standard' &&
        normalized != 'unsigned';
  }

  bool _hasMeaningfulSignature(String value) {
    final String normalized = value.trim().toLowerCase();
    return normalized.isNotEmpty &&
        normalized != 'none' &&
        normalized != 'no' &&
        normalized != 'n/a' &&
        normalized != 'na' &&
        normalized != 'unsigned';
  }
}
