import 'atlas_object_track.dart';
import 'atlas_scan_observation.dart';

class AtlasObjectTrackerConfig {
  const AtlasObjectTrackerConfig({
    this.maxMatchDistance = 0.065,
    this.tentativeTtl = const Duration(milliseconds: 600),
    this.confirmedTtl = const Duration(milliseconds: 1400),
    this.cooldownDuration = const Duration(seconds: 4),
    this.confirmationMinHits = 3,
    this.centroidSmoothingAlpha = 0.30,
  });

  final double maxMatchDistance;
  final Duration tentativeTtl;
  final Duration confirmedTtl;
  final Duration cooldownDuration;
  final int confirmationMinHits;
  final double centroidSmoothingAlpha;
}

class AtlasObjectTracker {
  AtlasObjectTracker({this.config = const AtlasObjectTrackerConfig()}) {
    _validateConfig(config);
  }

  final AtlasObjectTrackerConfig config;
  final Map<String, AtlasObjectTrack> _tracks = <String, AtlasObjectTrack>{};
  int _nextTrackSequence = 1;

  List<AtlasObjectTrack> get tracks =>
      List<AtlasObjectTrack>.unmodifiable(_tracks.values);

  AtlasObjectTrack? trackForId(String trackId) => _tracks[trackId.trim()];

  List<AtlasObjectTrack> processFrame({
    required List<AtlasScanObservation> observations,
    required DateTime timestamp,
  }) {
    _removeStaleTracks(timestamp);

    final List<_MatchCandidate> candidates = <_MatchCandidate>[];

    for (
      int observationIndex = 0;
      observationIndex < observations.length;
      observationIndex++
    ) {
      final AtlasScanObservation observation = observations[observationIndex];
      final AtlasNormalizedPoint? observationCentroid = observation.centroid;
      if (observationCentroid == null) continue;

      for (final AtlasObjectTrack track in _tracks.values) {
        if (track.isCooldown || track.centroid == null) continue;

        final double distance = track.centroid!.distanceTo(observationCentroid);
        if (distance <= config.maxMatchDistance) {
          candidates.add(
            _MatchCandidate(
              observationIndex: observationIndex,
              trackId: track.trackId,
              distance: distance,
            ),
          );
        }
      }
    }

    candidates.sort(
      (_MatchCandidate a, _MatchCandidate b) =>
          a.distance.compareTo(b.distance),
    );

    final Set<int> claimedObservationIndexes = <int>{};
    final Set<String> claimedTrackIds = <String>{};

    for (final _MatchCandidate candidate in candidates) {
      if (claimedObservationIndexes.contains(candidate.observationIndex) ||
          claimedTrackIds.contains(candidate.trackId)) {
        continue;
      }

      final AtlasObjectTrack? existingTrack = _tracks[candidate.trackId];
      if (existingTrack == null) continue;

      final AtlasScanObservation observation =
          observations[candidate.observationIndex];

      AtlasObjectTrack updatedTrack = existingTrack.incorporateObservation(
        observation,
        centroidSmoothingAlpha: config.centroidSmoothingAlpha,
      );

      if (updatedTrack.isTentative &&
          updatedTrack.observationCount >= config.confirmationMinHits) {
        updatedTrack = updatedTrack.confirm();
      }

      _tracks[candidate.trackId] = updatedTrack;
      claimedObservationIndexes.add(candidate.observationIndex);
      claimedTrackIds.add(candidate.trackId);
    }

    for (
      int observationIndex = 0;
      observationIndex < observations.length;
      observationIndex++
    ) {
      if (claimedObservationIndexes.contains(observationIndex)) continue;

      final AtlasScanObservation observation = observations[observationIndex];
      final String trackId = _createTrackId(timestamp);

      AtlasObjectTrack newTrack = AtlasObjectTrack.createInitial(
        trackId: trackId,
        observation: observation,
      );

      if (config.confirmationMinHits <= 1) {
        newTrack = newTrack.confirm();
      }

      _tracks[trackId] = newTrack;
    }

    _removeStaleTracks(timestamp);
    return tracks;
  }

  bool markCooldown({required String trackId, required DateTime startedAt}) {
    final String normalizedTrackId = trackId.trim();
    final AtlasObjectTrack? track = _tracks[normalizedTrackId];
    if (track == null) return false;

    _tracks[normalizedTrackId] = track.startCooldown(startedAt);
    return true;
  }

  void reset() {
    _tracks.clear();
    _nextTrackSequence = 1;
  }

  void _removeStaleTracks(DateTime timestamp) {
    _tracks.removeWhere((String _, AtlasObjectTrack track) {
      if (track.isCooldown) {
        final DateTime? cooldownStartedAt = track.cooldownStartedAt;
        if (cooldownStartedAt == null) return true;
        return timestamp.difference(cooldownStartedAt) >
            config.cooldownDuration;
      }

      final Duration elapsed = timestamp.difference(track.lastSeenAt);
      if (track.isTentative) {
        return elapsed > config.tentativeTtl;
      }

      return elapsed > config.confirmedTtl;
    });
  }

  String _createTrackId(DateTime timestamp) {
    return 'trk_${timestamp.microsecondsSinceEpoch}_${_nextTrackSequence++}';
  }

  static void _validateConfig(AtlasObjectTrackerConfig config) {
    if (!config.maxMatchDistance.isFinite ||
        config.maxMatchDistance <= 0.0 ||
        config.maxMatchDistance > 1.0) {
      throw ArgumentError.value(
        config.maxMatchDistance,
        'maxMatchDistance',
        'maxMatchDistance must be greater than 0.0 and at most 1.0.',
      );
    }

    if (config.confirmationMinHits < 1) {
      throw ArgumentError.value(
        config.confirmationMinHits,
        'confirmationMinHits',
        'confirmationMinHits must be at least 1.',
      );
    }

    if (!config.centroidSmoothingAlpha.isFinite ||
        config.centroidSmoothingAlpha < 0.0 ||
        config.centroidSmoothingAlpha > 1.0) {
      throw ArgumentError.value(
        config.centroidSmoothingAlpha,
        'centroidSmoothingAlpha',
        'centroidSmoothingAlpha must be between 0.0 and 1.0.',
      );
    }
  }
}

class _MatchCandidate {
  const _MatchCandidate({
    required this.observationIndex,
    required this.trackId,
    required this.distance,
  });

  final int observationIndex;
  final String trackId;
  final double distance;
}
