import '../models/atlas_inspection_reference.dart';

final class AtlasInspectionRecommendationContext {
  AtlasInspectionRecommendationContext({
    this.marketValue,
    this.variantPriceSpread,
    double knownCounterfeitPrevalence = 0.0,
    required double collectorValueThreshold,
    this.requiresVariantConfirmation = false,
    this.isLimitedEdition = false,
    this.hasAutographOrAuthentication = false,
    this.hasWeakReferenceCoverage = false,
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
  final bool requiresVariantConfirmation;
  final bool isLimitedEdition;
  final bool hasAutographOrAuthentication;
  final bool hasWeakReferenceCoverage;
}

final class AtlasInspectionRecommendation {
  const AtlasInspectionRecommendation({
    required this.isRecommended,
    this.badgeLabel,
    this.explanation,
    this.reasons = const <String>[],
  });

  final bool isRecommended;
  final String? badgeLabel;
  final String? explanation;
  final List<String> reasons;

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

    final List<String> reasons = <String>[
      if (highValue) 'Collector value threshold exceeded',
      if (reference.highCounterfeitRiskLine || elevatedPrevalence)
        'Elevated counterfeit exposure',
      if (highVariantSpread) 'Large known variant value spread',
      if (context.requiresVariantConfirmation) 'Variant confirmation required',
      if (context.isLimitedEdition) 'Limited or restricted release',
      if (context.hasAutographOrAuthentication)
        'Autograph or authentication evidence recorded',
      if (context.hasWeakReferenceCoverage)
        'Reference coverage is limited for this release',
    ];

    if (reference.highCounterfeitRiskLine && highValue) {
      return AtlasInspectionRecommendation(
        isRecommended: true,
        badgeLabel: '🛡️ Grail Guard: High Variance',
        explanation:
            'This release combines elevated counterfeit exposure with significant collector value. A full visual inspection is recommended.',
        reasons: List<String>.unmodifiable(reasons),
      );
    }

    if (reference.highCounterfeitRiskLine || elevatedPrevalence) {
      return AtlasInspectionRecommendation(
        isRecommended: true,
        badgeLabel: '🛡️ Grail Guard',
        explanation:
            'This release has elevated counterfeit exposure. A full visual inspection is recommended before relying on identity or value.',
        reasons: List<String>.unmodifiable(reasons),
      );
    }

    if (highVariantSpread) {
      return AtlasInspectionRecommendation(
        isRecommended: true,
        badgeLabel: '🏷️ High Variant Spread',
        explanation:
            'A large value difference exists between known variants. Sticker and variant inspection is recommended.',
        reasons: List<String>.unmodifiable(reasons),
      );
    }

    if (context.requiresVariantConfirmation) {
      return AtlasInspectionRecommendation(
        isRecommended: true,
        badgeLabel: '🧩 Variant Review',
        explanation:
            'Atlas found unresolved physical variant evidence. Confirm the sticker and release details with the guided inspection before relying on the match.',
        reasons: List<String>.unmodifiable(reasons),
      );
    }

    if (highValue) {
      return AtlasInspectionRecommendation(
        isRecommended: true,
        badgeLabel: '🛡️ Grail Guard',
        explanation:
            'This item exceeds the collector inspection threshold. A deeper inspection is recommended.',
        reasons: List<String>.unmodifiable(reasons),
      );
    }

    if (context.isLimitedEdition && context.hasAutographOrAuthentication) {
      return AtlasInspectionRecommendation(
        isRecommended: true,
        badgeLabel: '🛡️ Grail Guard',
        explanation:
            'This release combines limited-production and autograph or authentication evidence. A full visual inspection is recommended to preserve the collector record.',
        reasons: List<String>.unmodifiable(reasons),
      );
    }

    if (context.hasWeakReferenceCoverage &&
        (context.isLimitedEdition || context.hasAutographOrAuthentication)) {
      return AtlasInspectionRecommendation(
        isRecommended: true,
        badgeLabel: '📚 Reference Review',
        explanation:
            'This collectible has significant release documentation but limited reference coverage. Capture the available visual evidence for collector review.',
        reasons: List<String>.unmodifiable(reasons),
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
