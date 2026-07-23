import '../../knowledge/mapper/knowledge_mapper_result.dart';
import '../../knowledge/record/knowledge_record.dart';
import '../comparison/identity_comparison_result.dart';
import '../profile/identity_profile.dart';

// Carries the complete state of one identity resolution operation.
//
// The session preserves the records, mapper outputs, candidate profiles,
// comparisons, canonical profiles, notes, and metadata produced while
// Atlas resolves collectible identities.
class IdentityResolutionSession {
  IdentityResolutionSession({
    required this.sessionId,
    required this.startedAt,
    this.completedAt,
    List<KnowledgeRecord> sourceRecords =
    const <KnowledgeRecord>[],
    List<KnowledgeMapperResult> mapperResults =
    const <KnowledgeMapperResult>[],
    List<IdentityProfile> candidateProfiles =
    const <IdentityProfile>[],
    List<IdentityComparisonResult> comparisons =
    const <IdentityComparisonResult>[],
    List<IdentityProfile> canonicalProfiles =
    const <IdentityProfile>[],
    List<String> notes = const <String>[],
    Map<String, String> metadata =
    const <String, String>{},
  })  : assert(
  sessionId.trim().isNotEmpty,
  'Resolution session ID cannot be empty.',
  ),
        assert(
        completedAt == null || !completedAt.isBefore(startedAt),
        'Completion time cannot be before the session start time.',
        ),
        sourceRecords = List<KnowledgeRecord>.unmodifiable(
          sourceRecords,
        ),
        mapperResults = List<KnowledgeMapperResult>.unmodifiable(
          mapperResults,
        ),
        candidateProfiles = List<IdentityProfile>.unmodifiable(
          candidateProfiles,
        ),
        comparisons = List<IdentityComparisonResult>.unmodifiable(
          comparisons,
        ),
        canonicalProfiles = List<IdentityProfile>.unmodifiable(
          canonicalProfiles,
        ),
        notes = List<String>.unmodifiable(notes),
        metadata = Map<String, String>.unmodifiable(metadata);

  // Stable identifier for this resolution operation.
  final String sessionId;

  // Time when the resolution operation began.
  final DateTime startedAt;

  // Time when the resolution operation completed.
  final DateTime? completedAt;

  // Original provider records included in the session.
  final List<KnowledgeRecord> sourceRecords;

  // Mapper results produced from the source records.
  final List<KnowledgeMapperResult> mapperResults;

  // Candidate identity profiles collected from mapper results.
  final List<IdentityProfile> candidateProfiles;

  // Pairwise identity comparisons performed during resolution.
  final List<IdentityComparisonResult> comparisons;

  // Canonical profiles produced by the selected strategy.
  final List<IdentityProfile> canonicalProfiles;

  // Human-readable information about the resolution process.
  final List<String> notes;

  // Structured information for diagnostics and future extensions.
  final Map<String, String> metadata;

  bool get isComplete => completedAt != null;

  bool get hasSourceRecords => sourceRecords.isNotEmpty;

  bool get hasMapperResults => mapperResults.isNotEmpty;

  bool get hasCandidates => candidateProfiles.isNotEmpty;

  bool get hasComparisons => comparisons.isNotEmpty;

  bool get hasCanonicalProfiles => canonicalProfiles.isNotEmpty;

  bool get hasNotes => notes.isNotEmpty;

  int get sourceRecordCount => sourceRecords.length;

  int get mapperResultCount => mapperResults.length;

  int get candidateProfileCount => candidateProfiles.length;

  int get comparisonCount => comparisons.length;

  int get canonicalProfileCount => canonicalProfiles.length;

  Duration? get executionDuration {
    final DateTime? completionTime = completedAt;

    if (completionTime == null) {
      return null;
    }

    return completionTime.difference(startedAt);
  }

  IdentityResolutionSession copyWith({
    String? sessionId,
    DateTime? startedAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    List<KnowledgeRecord>? sourceRecords,
    List<KnowledgeMapperResult>? mapperResults,
    List<IdentityProfile>? candidateProfiles,
    List<IdentityComparisonResult>? comparisons,
    List<IdentityProfile>? canonicalProfiles,
    List<String>? notes,
    Map<String, String>? metadata,
  }) {
    return IdentityResolutionSession(
      sessionId: sessionId ?? this.sessionId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: clearCompletedAt
          ? null
          : completedAt ?? this.completedAt,
      sourceRecords: sourceRecords ?? this.sourceRecords,
      mapperResults: mapperResults ?? this.mapperResults,
      candidateProfiles:
      candidateProfiles ?? this.candidateProfiles,
      comparisons: comparisons ?? this.comparisons,
      canonicalProfiles:
      canonicalProfiles ?? this.canonicalProfiles,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }

  IdentityResolutionSession addSourceRecord(
      KnowledgeRecord record,
      ) {
    return copyWith(
      sourceRecords: <KnowledgeRecord>[
        ...sourceRecords,
        record,
      ],
    );
  }

  IdentityResolutionSession addMapperResult(
      KnowledgeMapperResult result,
      ) {
    return copyWith(
      mapperResults: <KnowledgeMapperResult>[
        ...mapperResults,
        result,
      ],
    );
  }

  IdentityResolutionSession addCandidateProfile(
      IdentityProfile profile,
      ) {
    return copyWith(
      candidateProfiles: <IdentityProfile>[
        ...candidateProfiles,
        profile,
      ],
    );
  }

  IdentityResolutionSession addComparison(
      IdentityComparisonResult comparison,
      ) {
    return copyWith(
      comparisons: <IdentityComparisonResult>[
        ...comparisons,
        comparison,
      ],
    );
  }

  IdentityResolutionSession addCanonicalProfile(
      IdentityProfile profile,
      ) {
    return copyWith(
      canonicalProfiles: <IdentityProfile>[
        ...canonicalProfiles,
        profile,
      ],
    );
  }

  IdentityResolutionSession addNote(String note) {
    final String normalizedNote = note.trim();

    if (normalizedNote.isEmpty) {
      return this;
    }

    return copyWith(
      notes: <String>[
        ...notes,
        normalizedNote,
      ],
    );
  }

  IdentityResolutionSession complete({
    required DateTime completedAt,
    List<IdentityProfile>? canonicalProfiles,
    List<String>? notes,
    Map<String, String>? metadata,
  }) {
    return copyWith(
      completedAt: completedAt,
      canonicalProfiles:
      canonicalProfiles ?? this.canonicalProfiles,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'IdentityResolutionSession('
        'sessionId: $sessionId, '
        'complete: $isComplete, '
        'sourceRecords: ${sourceRecords.length}, '
        'mapperResults: ${mapperResults.length}, '
        'candidates: ${candidateProfiles.length}, '
        'comparisons: ${comparisons.length}, '
        'canonicalProfiles: ${canonicalProfiles.length}'
        ')';
  }
}