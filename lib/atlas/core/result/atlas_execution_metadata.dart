// Immutable metadata describing one Atlas Engine execution.
//
// This model is intentionally independent of Flutter, persistence, and any
// specific engine family.
class AtlasExecutionMetadata {
  AtlasExecutionMetadata({
    required this.engineName,
    required this.engineVersion,
    required this.schemaVersion,
    required this.startedAt,
    required this.completedAt,
    this.policyVersion,
    this.correlationId,
    this.warningCount = 0,
    this.evidenceCount = 0,
    this.tags = const <String, String>{},
  }) : assert(engineName != ''),
       assert(engineVersion != ''),
       assert(schemaVersion != ''),
       assert(warningCount >= 0),
       assert(evidenceCount >= 0),
       assert(!completedAt.isBefore(startedAt));

  // Stable name of the engine that produced the result.
  final String engineName;

  // Version of the engine implementation.
  final String engineVersion;

  // Version of the result schema.
  final String schemaVersion;

  // Version of the policy used during execution, when applicable.
  final String? policyVersion;

  // Timestamp captured immediately before execution began.
  final DateTime startedAt;

  // Timestamp captured immediately after execution completed.
  final DateTime completedAt;

  // Identifier used to trace related operations across engines.
  final String? correlationId;

  // Number of warnings generated during execution.
  final int warningCount;

  // Number of evidence items considered or produced.
  final int evidenceCount;

  // Optional structured metadata for diagnostics and future extensions.
  final Map<String, String> tags;

  // Total elapsed execution time.
  Duration get executionDuration => completedAt.difference(startedAt);

  // Whether this execution used a versioned policy.
  bool get usedPolicy => policyVersion != null && policyVersion!.isNotEmpty;

  // Whether warnings were produced.
  bool get hasWarnings => warningCount > 0;

  // Whether evidence was recorded.
  bool get hasEvidence => evidenceCount > 0;

  AtlasExecutionMetadata copyWith({
    String? engineName,
    String? engineVersion,
    String? schemaVersion,
    String? policyVersion,
    bool clearPolicyVersion = false,
    DateTime? startedAt,
    DateTime? completedAt,
    String? correlationId,
    bool clearCorrelationId = false,
    int? warningCount,
    int? evidenceCount,
    Map<String, String>? tags,
  }) {
    return AtlasExecutionMetadata(
      engineName: engineName ?? this.engineName,
      engineVersion: engineVersion ?? this.engineVersion,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      policyVersion: clearPolicyVersion
          ? null
          : policyVersion ?? this.policyVersion,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      correlationId: clearCorrelationId
          ? null
          : correlationId ?? this.correlationId,
      warningCount: warningCount ?? this.warningCount,
      evidenceCount: evidenceCount ?? this.evidenceCount,
      tags: Map<String, String>.unmodifiable(tags ?? this.tags),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'engine_name': engineName,
      'engine_version': engineVersion,
      'schema_version': schemaVersion,
      'policy_version': policyVersion,
      'started_at': startedAt.toUtc().toIso8601String(),
      'completed_at': completedAt.toUtc().toIso8601String(),
      'execution_duration_ms': executionDuration.inMilliseconds,
      'correlation_id': correlationId,
      'warning_count': warningCount,
      'evidence_count': evidenceCount,
      'tags': tags,
    };
  }

  factory AtlasExecutionMetadata.fromJson(Map<String, dynamic> json) {
    return AtlasExecutionMetadata(
      engineName: json['engine_name'] as String,
      engineVersion: json['engine_version'] as String,
      schemaVersion: json['schema_version'] as String,
      policyVersion: json['policy_version'] as String?,
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: DateTime.parse(json['completed_at'] as String),
      correlationId: json['correlation_id'] as String?,
      warningCount: json['warning_count'] as int? ?? 0,
      evidenceCount: json['evidence_count'] as int? ?? 0,
      tags: Map<String, String>.unmodifiable(
        Map<String, String>.from(
          json['tags'] as Map<dynamic, dynamic>? ?? const <String, String>{},
        ),
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AtlasExecutionMetadata &&
            other.engineName == engineName &&
            other.engineVersion == engineVersion &&
            other.schemaVersion == schemaVersion &&
            other.policyVersion == policyVersion &&
            other.startedAt == startedAt &&
            other.completedAt == completedAt &&
            other.correlationId == correlationId &&
            other.warningCount == warningCount &&
            other.evidenceCount == evidenceCount &&
            _mapsEqual(other.tags, tags);
  }

  @override
  int get hashCode {
    return Object.hash(
      engineName,
      engineVersion,
      schemaVersion,
      policyVersion,
      startedAt,
      completedAt,
      correlationId,
      warningCount,
      evidenceCount,
      Object.hashAll(
        tags.entries.map(
          (MapEntry<String, String> entry) =>
              Object.hash(entry.key, entry.value),
        ),
      ),
    );
  }

  @override
  String toString() {
    return 'AtlasExecutionMetadata('
        'engineName: $engineName, '
        'engineVersion: $engineVersion, '
        'schemaVersion: $schemaVersion, '
        'policyVersion: $policyVersion, '
        'executionDuration: $executionDuration, '
        'warningCount: $warningCount, '
        'evidenceCount: $evidenceCount'
        ')';
  }

  static bool _mapsEqual(Map<String, String> left, Map<String, String> right) {
    if (left.length != right.length) {
      return false;
    }

    for (final MapEntry<String, String> entry in left.entries) {
      if (right[entry.key] != entry.value) {
        return false;
      }
    }

    return true;
  }
}
