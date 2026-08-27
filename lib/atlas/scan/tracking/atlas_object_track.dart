import '../../scan/models/scan_code.dart';
import 'atlas_scan_observation.dart';

enum AtlasObjectTrackState { tentative, confirmed, cooldown }

class AtlasTrackedBarcodeEvidence {
  const AtlasTrackedBarcodeEvidence({
    required this.key,
    required this.latestCode,
    required this.hitCount,
  });

  final String key;
  final ScanCode latestCode;
  final int hitCount;

  AtlasTrackedBarcodeEvidence addHit(ScanCode code) {
    return AtlasTrackedBarcodeEvidence(
      key: key,
      latestCode: code,
      hitCount: hitCount + 1,
    );
  }
}

class AtlasObjectTrack {
  AtlasObjectTrack({
    required this.trackId,
    required this.state,
    required this.firstSeenAt,
    required this.lastSeenAt,
    required this.observationCount,
    required this.latestObservation,
    required this.centroid,
    required this.normalizedBounds,
    required Map<String, AtlasTrackedBarcodeEvidence> barcodeEvidenceByKey,
    this.cooldownStartedAt,
  }) : barcodeEvidenceByKey =
           Map<String, AtlasTrackedBarcodeEvidence>.unmodifiable(
             barcodeEvidenceByKey,
           );

  factory AtlasObjectTrack.createInitial({
    required String trackId,
    required AtlasScanObservation observation,
  }) {
    return AtlasObjectTrack(
      trackId: trackId,
      state: AtlasObjectTrackState.tentative,
      firstSeenAt: observation.capturedAt,
      lastSeenAt: observation.capturedAt,
      observationCount: 1,
      latestObservation: observation,
      centroid: observation.centroid,
      normalizedBounds: observation.normalizedBounds,
      barcodeEvidenceByKey: _barcodeEvidenceForObservation(observation),
    );
  }

  final String trackId;
  final AtlasObjectTrackState state;
  final DateTime firstSeenAt;
  final DateTime lastSeenAt;
  final int observationCount;
  final AtlasScanObservation latestObservation;
  final AtlasNormalizedPoint? centroid;
  final AtlasNormalizedBounds? normalizedBounds;
  final Map<String, AtlasTrackedBarcodeEvidence> barcodeEvidenceByKey;
  final DateTime? cooldownStartedAt;

  bool get isTentative => state == AtlasObjectTrackState.tentative;
  bool get isConfirmed => state == AtlasObjectTrackState.confirmed;
  bool get isCooldown => state == AtlasObjectTrackState.cooldown;

  int get usableBarcodeHitCount => barcodeEvidenceByKey.values.fold<int>(
    0,
    (int total, AtlasTrackedBarcodeEvidence evidence) =>
        total + evidence.hitCount,
  );

  AtlasObjectTrack incorporateObservation(
    AtlasScanObservation observation, {
    double centroidSmoothingAlpha = 0.30,
  }) {
    if (!centroidSmoothingAlpha.isFinite ||
        centroidSmoothingAlpha < 0.0 ||
        centroidSmoothingAlpha > 1.0) {
      throw ArgumentError.value(
        centroidSmoothingAlpha,
        'centroidSmoothingAlpha',
        'centroidSmoothingAlpha must be between 0.0 and 1.0.',
      );
    }

    final Map<String, AtlasTrackedBarcodeEvidence> updatedEvidence =
        Map<String, AtlasTrackedBarcodeEvidence>.from(barcodeEvidenceByKey);

    final ScanCode? observedCode = observation.code;
    if (observation.hasUsableProductBarcode && observedCode != null) {
      final String key = barcodeEvidenceKey(observedCode);
      final AtlasTrackedBarcodeEvidence? existingEvidence =
          updatedEvidence[key];
      updatedEvidence[key] = existingEvidence == null
          ? AtlasTrackedBarcodeEvidence(
              key: key,
              latestCode: observedCode,
              hitCount: 1,
            )
          : existingEvidence.addHit(observedCode);
    }

    final AtlasNormalizedPoint? observationCentroid = observation.centroid;
    final AtlasNormalizedPoint? updatedCentroid = _smoothedCentroid(
      current: centroid,
      observation: observationCentroid,
      alpha: centroidSmoothingAlpha,
    );

    return AtlasObjectTrack(
      trackId: trackId,
      state: state,
      firstSeenAt: firstSeenAt,
      lastSeenAt: observation.capturedAt,
      observationCount: observationCount + 1,
      latestObservation: observation,
      centroid: updatedCentroid,
      normalizedBounds: observation.normalizedBounds ?? normalizedBounds,
      barcodeEvidenceByKey: updatedEvidence,
      cooldownStartedAt: cooldownStartedAt,
    );
  }

  AtlasObjectTrack confirm() {
    if (!isTentative) return this;

    return AtlasObjectTrack(
      trackId: trackId,
      state: AtlasObjectTrackState.confirmed,
      firstSeenAt: firstSeenAt,
      lastSeenAt: lastSeenAt,
      observationCount: observationCount,
      latestObservation: latestObservation,
      centroid: centroid,
      normalizedBounds: normalizedBounds,
      barcodeEvidenceByKey: barcodeEvidenceByKey,
      cooldownStartedAt: cooldownStartedAt,
    );
  }

  AtlasObjectTrack startCooldown(DateTime startedAt) {
    return AtlasObjectTrack(
      trackId: trackId,
      state: AtlasObjectTrackState.cooldown,
      firstSeenAt: firstSeenAt,
      lastSeenAt: lastSeenAt,
      observationCount: observationCount,
      latestObservation: latestObservation,
      centroid: centroid,
      normalizedBounds: normalizedBounds,
      barcodeEvidenceByKey: barcodeEvidenceByKey,
      cooldownStartedAt: startedAt,
    );
  }

  static String barcodeEvidenceKey(ScanCode code) {
    return '${code.format.name}|${code.normalizedValue.trim()}';
  }

  static Map<String, AtlasTrackedBarcodeEvidence>
  _barcodeEvidenceForObservation(AtlasScanObservation observation) {
    final ScanCode? code = observation.code;
    if (!observation.hasUsableProductBarcode || code == null) {
      return const <String, AtlasTrackedBarcodeEvidence>{};
    }

    final String key = barcodeEvidenceKey(code);
    return <String, AtlasTrackedBarcodeEvidence>{
      key: AtlasTrackedBarcodeEvidence(key: key, latestCode: code, hitCount: 1),
    };
  }

  static AtlasNormalizedPoint? _smoothedCentroid({
    required AtlasNormalizedPoint? current,
    required AtlasNormalizedPoint? observation,
    required double alpha,
  }) {
    if (observation == null) return current;
    if (current == null) return observation;

    return AtlasNormalizedPoint(
      x: (current.x * (1.0 - alpha)) + (observation.x * alpha),
      y: (current.y * (1.0 - alpha)) + (observation.y * alpha),
    );
  }
}
