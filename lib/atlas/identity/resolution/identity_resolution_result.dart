import '../../knowledge/mapper/knowledge_mapper_result.dart';
import '../../knowledge/record/knowledge_record.dart';
import '../comparison/identity_comparison_result.dart';
import '../profile/identity_profile.dart';
import 'identity_resolution_session.dart';

// Final output produced by the Identity Resolution Engine.
//
// The result preserves the completed resolution session while exposing
// convenient accessors for the canonical identities that Atlas should use.
class IdentityResolutionResult {
  IdentityResolutionResult({
    required this.session,
  });

  // Completed resolution session.
  final IdentityResolutionSession session;

  // Canonical identities produced by the resolution process.
  List<IdentityProfile> get canonicalProfiles {
    return session.canonicalProfiles;
  }

  // Candidate identities considered during resolution.
  List<IdentityProfile> get candidateProfiles {
    return session.candidateProfiles;
  }

  // Identity comparisons executed during resolution.
  List<IdentityComparisonResult> get comparisons {
    return session.comparisons;
  }

  // Original knowledge records included in the resolution session.
  List<KnowledgeRecord> get sourceRecords {
    return session.sourceRecords;
  }

  // Mapper results used during resolution.
  List<KnowledgeMapperResult> get mapperResults {
    return session.mapperResults;
  }

  // Informational notes produced during resolution.
  List<String> get notes {
    return session.notes;
  }

  // Structured metadata produced during resolution.
  Map<String, String> get metadata {
    return session.metadata;
  }

  bool get isComplete => session.isComplete;

  bool get hasCanonicalProfiles {
    return session.hasCanonicalProfiles;
  }

  bool get hasCandidates {
    return session.hasCandidates;
  }

  bool get hasComparisons {
    return session.hasComparisons;
  }

  bool get hasSourceRecords {
    return session.hasSourceRecords;
  }

  bool get hasMapperResults {
    return session.hasMapperResults;
  }

  bool get hasNotes {
    return session.hasNotes;
  }

  int get canonicalProfileCount {
    return session.canonicalProfileCount;
  }

  int get candidateProfileCount {
    return session.candidateProfileCount;
  }

  int get comparisonCount {
    return session.comparisonCount;
  }

  int get sourceRecordCount {
    return session.sourceRecordCount;
  }

  int get mapperResultCount {
    return session.mapperResultCount;
  }

  Duration? get executionDuration {
    return session.executionDuration;
  }

  IdentityResolutionResult copyWith({
    IdentityResolutionSession? session,
  }) {
    return IdentityResolutionResult(
      session: session ?? this.session,
    );
  }

  @override
  String toString() {
    return 'IdentityResolutionResult('
        'complete: $isComplete, '
        'sourceRecords: $sourceRecordCount, '
        'mapperResults: $mapperResultCount, '
        'candidateProfiles: $candidateProfileCount, '
        'comparisons: $comparisonCount, '
        'canonicalProfiles: $canonicalProfileCount'
        ')';
  }
}