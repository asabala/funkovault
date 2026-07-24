import '../funko/retailer/funko_retailer_detection_result.dart';
import '../funko/retailer/funko_retailer_evidence.dart';
import '../variant/atlas_variant_detection_result.dart';
import '../variant/atlas_variant_evidence.dart';

// Represents the complete analysis of a collector item.
final class AtlasIdentityAnalysis {
  const AtlasIdentityAnalysis({
    this.variantResult =
    const AtlasVariantDetectionResult(
      evidence: <AtlasVariantEvidence>[],
    ),
    this.retailerResult =
    const FunkoRetailerDetectionResult(
      evidence: <FunkoRetailerEvidence>[],
    ),
  });

  final AtlasVariantDetectionResult
  variantResult;

  final FunkoRetailerDetectionResult
  retailerResult;

  bool get hasFindings {
    return variantResult.hasVariants ||
        retailerResult.hasRetailers;
  }

  AtlasIdentityAnalysis copyWith({
    AtlasVariantDetectionResult?
    variantResult,
    FunkoRetailerDetectionResult?
    retailerResult,
  }) {
    return AtlasIdentityAnalysis(
      variantResult:
      variantResult ?? this.variantResult,
      retailerResult:
      retailerResult ?? this.retailerResult,
    );
  }
}