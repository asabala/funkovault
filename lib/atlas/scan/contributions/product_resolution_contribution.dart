import '../resolution/product_resolution.dart';
import 'abstract_intelligence_contribution.dart';
import 'contribution_category.dart';

// Represents the result of canonical product resolution.
//
// Resolution engines produce this contribution after evaluating one or more
// identity hypotheses and selecting the best canonical Atlas product.
final class ProductResolutionContribution
    extends AbstractIntelligenceContribution {
  ProductResolutionContribution({
    required super.contributionId,
    required super.sourceEngineId,
    required super.createdAt,
    required this.resolution,
    super.confidence,
    super.attributes,
  });

  // Canonical resolution selected by Atlas.
  final ProductResolution resolution;

  bool get requiresReview {
    return resolution.requiresReview;
  }

  bool get isHighConfidence {
    return resolution.isHighConfidence;
  }

  bool get isMediumConfidence {
    return resolution.isMediumConfidence;
  }

  bool get isLowConfidence {
    return resolution.isLowConfidence;
  }

  @override
  ContributionCategory get category {
    return ContributionCategory.resolution;
  }

  @override
  String toString() {
    return 'ProductResolutionContribution('
        'productId: ${resolution.productId.value}, '
        'confidence: ${resolution.matchConfidence}'
        ')';
  }
}