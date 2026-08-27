import '../../scan/models/scan_code.dart';
import '../tracking/atlas_object_track.dart';

class AtlasEvidenceAccumulatorConfig {
  const AtlasEvidenceAccumulatorConfig({
    this.minBarcodeHits = 3,
    this.dominantBarcodeThreshold = 0.75,
  });

  final int minBarcodeHits;
  final double dominantBarcodeThreshold;
}

class AtlasAccumulatedEvidence {
  const AtlasAccumulatedEvidence({
    required this.trackId,
    required this.stableCode,
    required this.agreementConfidence,
    required this.totalBarcodeHits,
    required this.dominantBarcodeHits,
    required this.isReadyForResolution,
  });

  final String trackId;
  final ScanCode stableCode;
  final double agreementConfidence;
  final int totalBarcodeHits;
  final int dominantBarcodeHits;
  final bool isReadyForResolution;
}

class AtlasEvidenceAccumulator {
  AtlasEvidenceAccumulator({
    this.config = const AtlasEvidenceAccumulatorConfig(),
  }) {
    _validateConfig(config);
  }

  final AtlasEvidenceAccumulatorConfig config;

  AtlasAccumulatedEvidence? evaluateTrack(AtlasObjectTrack track) {
    if (track.isCooldown || track.barcodeEvidenceByKey.isEmpty) {
      return null;
    }

    final int totalBarcodeHits = track.usableBarcodeHitCount;
    if (totalBarcodeHits == 0) return null;

    AtlasTrackedBarcodeEvidence? dominantEvidence;

    for (final AtlasTrackedBarcodeEvidence evidence
        in track.barcodeEvidenceByKey.values) {
      final AtlasTrackedBarcodeEvidence? currentDominant = dominantEvidence;

      if (currentDominant == null ||
          evidence.hitCount > currentDominant.hitCount ||
          (evidence.hitCount == currentDominant.hitCount &&
              evidence.latestCode.capturedAt.isAfter(
                currentDominant.latestCode.capturedAt,
              ))) {
        dominantEvidence = evidence;
      }
    }

    if (dominantEvidence == null) return null;

    final double agreementConfidence =
        dominantEvidence.hitCount / totalBarcodeHits;

    final bool isReadyForResolution =
        track.isConfirmed &&
        totalBarcodeHits >= config.minBarcodeHits &&
        agreementConfidence >= config.dominantBarcodeThreshold;

    return AtlasAccumulatedEvidence(
      trackId: track.trackId,
      stableCode: dominantEvidence.latestCode,
      agreementConfidence: agreementConfidence,
      totalBarcodeHits: totalBarcodeHits,
      dominantBarcodeHits: dominantEvidence.hitCount,
      isReadyForResolution: isReadyForResolution,
    );
  }

  static void _validateConfig(AtlasEvidenceAccumulatorConfig config) {
    if (config.minBarcodeHits < 1) {
      throw ArgumentError.value(
        config.minBarcodeHits,
        'minBarcodeHits',
        'minBarcodeHits must be at least 1.',
      );
    }

    if (!config.dominantBarcodeThreshold.isFinite ||
        config.dominantBarcodeThreshold <= 0.0 ||
        config.dominantBarcodeThreshold > 1.0) {
      throw ArgumentError.value(
        config.dominantBarcodeThreshold,
        'dominantBarcodeThreshold',
        'dominantBarcodeThreshold must be greater than 0.0 and at most 1.0.',
      );
    }
  }
}
