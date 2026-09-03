import '../models/atlas_inspection_reference.dart';

final class AtlasInspectionRecommendationContext {
  AtlasInspectionRecommendationContext({
    this.marketValue,
    this.variantPriceSpread,
    double knownCounterfeitPrevalence = 0.0,
    required double collectorValueThreshold,
  }) : knownCounterfeitPrevalence = _unitScore(
         knownCounterfeitPrevalence,
         'knownCounterfeitPrevalence',
       ),
       collectorValueThreshold = _nonNegative(
         collectorValueThreshold,
         'collectorValueThreshold',
       );

  final double? marketValue;
  final double? variantPriceSpread;
  final double knownCounterfeitPrevalence;
  final double collectorValueThreshold;
}

final class AtlasInspectionRecommendation {
  const AtlasInspectionRecommendation({
    required this.isRecommended,
    this.badgeLabel,
    this.explanation,
  });

  final bool isRecommended;
  final String? badgeLabel;
  final String? explanation;

  static const standard = AtlasInspectionRecommendation(isRecommended: false);
}

abstract interface class AtlasInspectionRecommendationPolicy {
  AtlasInspectionRecommendation evaluate({
    required AtlasInspectionReferenceCriteria reference,
    required AtlasInspectionRecommendationContext context,
  });
}

final class AtlasStandardGrailGuardPolicy
    implements AtlasInspectionRecommendationPolicy {
  const AtlasStandardGrailGuardPolicy();

  @override
  AtlasInspectionRecommendation evaluate({
    required AtlasInspectionReferenceCriteria reference,
    required AtlasInspectionRecommendationContext context,
  }) {
    final bool highValue =
        context.marketValue != null &&
        context.marketValue! >= context.collectorValueThreshold;
    final bool elevatedPrevalence = context.knownCounterfeitPrevalence >= 0.40;
    final bool highVariantSpread =
        context.variantPriceSpread != null &&
        context.variantPriceSpread! >= 50.0;

    if (reference.highCounterfeitRiskLine && highValue) {
      return const AtlasInspectionRecommendation(
        isRecommended: true,
        badgeLabel: '🛡️ Grail Guard: High Variance',
        explanation:
            'This release combines elevated counterfeit exposure with significant market value. Visual inspection is recommended.',
      );
    }

    if (reference.highCounterfeitRiskLine || elevatedPrevalence) {
      return const AtlasInspectionRecommendation(
        isRecommended: true,
        badgeLabel: '🛡️ Grail Guard',
        explanation:
            'This release has elevated counterfeit exposure. Visual inspection is recommended before relying on identity or value.',
      );
    }

    if (highVariantSpread) {
      return const AtlasInspectionRecommendation(
        isRecommended: true,
        badgeLabel: '🏷️ High Variant Spread',
        explanation:
            'A large value difference exists between known variants. Sticker and variant inspection is recommended.',
      );
    }

    if (highValue) {
      return const AtlasInspectionRecommendation(
        isRecommended: true,
        badgeLabel: '🛡️ Grail Guard',
        explanation:
            'This item exceeds the collector inspection threshold. A deeper inspection is recommended.',
      );
    }

    return AtlasInspectionRecommendation.standard;
  }
}

double _unitScore(double value, String fieldName) {
  if (!value.isFinite || value < 0.0 || value > 1.0) {
    throw ArgumentError.value(
      value,
      fieldName,
      '$fieldName must be between 0.0 and 1.0.',
    );
  }
  return value;
}

double _nonNegative(double value, String fieldName) {
  if (!value.isFinite || value < 0.0) {
    throw ArgumentError.value(
      value,
      fieldName,
      '$fieldName must be finite and non-negative.',
    );
  }
  return value;
}
