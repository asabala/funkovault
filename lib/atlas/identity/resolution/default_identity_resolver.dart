import '../../core/result/atlas_execution_metadata.dart';
import '../../core/result/atlas_result.dart';
import '../../knowledge/mapper/knowledge_mapper_result.dart';
import '../comparison/identity_comparison_result.dart';
import '../engine/identity_decision_engine.dart';
import '../profile/identity_profile.dart';
import 'config/identity_resolution_configuration.dart';
import 'identity_resolution_result.dart';
import 'identity_resolution_session.dart';
import 'identity_resolver.dart';

// Default implementation of the Atlas Identity Resolution Engine.
//
// This engine orchestrates the complete identity resolution pipeline.
// It does not contain comparison policies or canonicalization logic.
// Those responsibilities belong to the configuration supplied to it.
class DefaultIdentityResolver implements IdentityResolver {
  const DefaultIdentityResolver({
    required this.decisionEngine,
    required this.configuration,
  });

  final IdentityDecisionEngine decisionEngine;

  final IdentityResolutionConfiguration configuration;

  @override
  String get id => 'atlas.default_identity_resolver';

  @override
  String get name => 'Default Identity Resolver';

  @override
  String get version => '1.0.0';

  @override
  Future<AtlasResult<IdentityResolutionResult>> resolve({
    required List<KnowledgeMapperResult> mapperResults,
  }) async {
    final DateTime startedAt = DateTime.now();

    final List<IdentityProfile> candidates =
    <IdentityProfile>[];

    for (final KnowledgeMapperResult mapperResult
    in mapperResults) {
      candidates.addAll(mapperResult.profiles);
    }

    final List<IdentityComparisonResult> comparisons =
    <IdentityComparisonResult>[];

    if (configuration.options.compareAllCandidates) {
      for (
      int leftIndex = 0;
      leftIndex < candidates.length;
      leftIndex++
      ) {
        for (
        int rightIndex = leftIndex + 1;
        rightIndex < candidates.length;
        rightIndex++
        ) {
          final AtlasResult<IdentityComparisonResult>
          comparison = decisionEngine.compare(
            left: candidates[leftIndex],
            right: candidates[rightIndex],
            policy: configuration.policy,
          );

          if (comparison.hasUsableOutput) {
            comparisons.add(
              comparison.requireOutput(),
            );
          }
        }
      }
    }

    final List<IdentityProfile> canonicalProfiles =
    configuration.canonicalizationStrategy.canonicalize(
      candidates: candidates,
      comparisons: comparisons,
    );

    final DateTime completedAt = DateTime.now();

    final List<String> notes =
    configuration.options.includeComparisonNotes
        ? const <String>[
      'Resolution completed successfully.',
    ]
        : const <String>[];

    final IdentityResolutionSession session =
    IdentityResolutionSession(
      sessionId: startedAt.microsecondsSinceEpoch.toString(),
      startedAt: startedAt,
      completedAt: completedAt,
      sourceRecords: mapperResults
          .map(
            (KnowledgeMapperResult mapperResult) =>
        mapperResult.sourceRecord,
      )
          .toList(growable: false),
      mapperResults:
      List<KnowledgeMapperResult>.unmodifiable(
        mapperResults,
      ),
      candidateProfiles:
      List<IdentityProfile>.unmodifiable(
        candidates,
      ),
      comparisons:
      List<IdentityComparisonResult>.unmodifiable(
        comparisons,
      ),
      canonicalProfiles:
      List<IdentityProfile>.unmodifiable(
        canonicalProfiles,
      ),
      notes: notes,
    );

    final IdentityResolutionResult result =
    IdentityResolutionResult(
      session: session,
    );

    return AtlasResult<IdentityResolutionResult>.success(
      output: result,
      metadata: AtlasExecutionMetadata(
        engineName: name,
        engineVersion: version,
        schemaVersion: '1.0.0',
        policyVersion: configuration.policy.version,
        startedAt: startedAt,
        completedAt: completedAt,
        evidenceCount: comparisons.length,
        tags: <String, String>{
          'domain': 'identity',
          'operation': 'resolution',
          'candidate_count': candidates.length.toString(),
          'comparison_count': comparisons.length.toString(),
          'canonical_profile_count':
          canonicalProfiles.length.toString(),
          'mapper_result_count':
          mapperResults.length.toString(),
          'compare_all_candidates': configuration
              .options.compareAllCandidates
              .toString(),
          'allow_single_candidate': configuration
              .options.allowSingleCandidate
              .toString(),
          'record_unmatched_candidates': configuration
              .options.recordUnmatchedCandidates
              .toString(),
          'build_resolution_session': configuration
              .options.buildResolutionSession
              .toString(),
          'include_comparison_notes': configuration
              .options.includeComparisonNotes
              .toString(),
          'canonicalization_strategy':
          configuration.canonicalizationStrategy.id,
        },
      ),
    );
  }
}