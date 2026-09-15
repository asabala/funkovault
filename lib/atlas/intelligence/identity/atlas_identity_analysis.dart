import '../event/funko_event_detection_result.dart';
import '../event/funko_event_evidence.dart';
import '../retailer/funko_retailer_detection_result.dart';
import '../retailer/funko_retailer_evidence.dart';
import '../sticker/funko_sticker_detection_result.dart';
import '../sticker/funko_sticker_evidence.dart';
import '../variant/atlas_variant_detection_result.dart';
import '../variant/atlas_variant_evidence.dart';

// Represents the complete analysis of a collector item.
final class AtlasIdentityAnalysis {
  const AtlasIdentityAnalysis({
    this.variantResult = const AtlasVariantDetectionResult(
      evidence: <AtlasVariantEvidence>[],
    ),
    this.retailerResult = const FunkoRetailerDetectionResult(
      evidence: <FunkoRetailerEvidence>[],
    ),
    this.stickerResult = const FunkoStickerDetectionResult(
      evidence: <FunkoStickerEvidence>[],
    ),
    this.eventResult = const FunkoEventDetectionResult(
      evidence: <FunkoEventEvidence>[],
    ),
  });

  final AtlasVariantDetectionResult variantResult;

  final FunkoRetailerDetectionResult retailerResult;

  final FunkoStickerDetectionResult stickerResult;

  final FunkoEventDetectionResult eventResult;

  bool get hasFindings {
    return variantResult.hasVariants ||
        retailerResult.hasRetailers ||
        stickerResult.hasStickers ||
        eventResult.hasEvents;
  }

  AtlasIdentityAnalysis copyWith({
    AtlasVariantDetectionResult? variantResult,
    FunkoRetailerDetectionResult? retailerResult,
    FunkoStickerDetectionResult? stickerResult,
    FunkoEventDetectionResult? eventResult,
  }) {
    return AtlasIdentityAnalysis(
      variantResult: variantResult ?? this.variantResult,
      retailerResult: retailerResult ?? this.retailerResult,
      stickerResult: stickerResult ?? this.stickerResult,
      eventResult: eventResult ?? this.eventResult,
    );
  }
}
