typedef AtlasResolutionTask = Future<void> Function();

/// Immutable unit of resolution work for one physical scanner track.
///
/// The queue coordinates execution only. Product identity, catalog resolution,
/// and collection mutation remain responsibilities of the existing Atlas
/// scanner pipeline and downstream services.
class AtlasResolutionJob {
  AtlasResolutionJob({
    required this.jobId,
    required this.trackId,
    required this.createdAt,
    required this.execute,
  }) {
    if (jobId.trim().isEmpty) {
      throw ArgumentError.value(jobId, 'jobId', 'jobId cannot be empty.');
    }

    if (trackId.trim().isEmpty) {
      throw ArgumentError.value(trackId, 'trackId', 'trackId cannot be empty.');
    }
  }

  final String jobId;
  final String trackId;
  final DateTime createdAt;
  final AtlasResolutionTask execute;
}
