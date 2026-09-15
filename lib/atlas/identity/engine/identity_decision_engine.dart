import '../../core/result/atlas_execution_metadata.dart';
import '../../core/result/atlas_result.dart';
import '../../core/result/atlas_result_status.dart';
import '../attribute/identity_role.dart';
import '../comparison/identity_comparison_result.dart';
import '../comparator/identity_comparator_registry.dart';
import '../comparator/identity_comparator_result.dart';
import '../evidence/identity_evidence.dart';
import '../policy/identity_policy.dart';
import '../profile/identity_profile.dart';

// Coordinates modular identity comparators and produces the final
// platform-level identity comparison result.
class IdentityDecisionEngine {
  const IdentityDecisionEngine({this.registry});

  // Allows a custom comparator registry to be supplied for testing,
  // category modules, or future Atlas extensions.
  final IdentityComparatorRegistry? registry;

  AtlasResult<IdentityComparisonResult> compare({
    required IdentityProfile left,
    required IdentityProfile right,
    required IdentityPolicy policy,
  }) {
    final DateTime startedAt = DateTime.now();

    final IdentityComparatorRegistry activeRegistry =
        registry ?? IdentityComparatorRegistry.standard();

    final List<IdentityComparatorResult> comparatorResults = activeRegistry
        .compare(left: left, right: right, policy: policy);

    final List<IdentityEvidence> evidence = _mergeEvidence(comparatorResults);

    final Set<IdentityRole> matchedRoles = _matchedRoles(evidence);

    final Set<IdentityRole> conflictingRoles = _conflictingRoles(evidence);

    final Set<IdentityRole> missingRoles = _missingRoles(
      evidence: evidence,
      policy: policy,
    );

    final List<String> matchedAttributes = _matchedAttributes(evidence);

    final List<String> conflictingAttributes = _conflictingAttributes(evidence);

    final List<String> missingAttributes = _missingAttributes(evidence);

    final List<String> notes = _buildNotes(
      comparatorResults: comparatorResults,
      conflictingRoles: conflictingRoles,
      missingRoles: missingRoles,
      missingAttributes: missingAttributes,
      policy: policy,
    );

    final double confidence = _calculateOverallConfidence(evidence);

    final bool hasConflicts = conflictingRoles.isNotEmpty;

    final bool hasMissingData =
        missingRoles.isNotEmpty || missingAttributes.isNotEmpty;

    final bool missingDataBlocksMatch =
        !policy.allowPartialMatches && hasMissingData;

    final bool allComparatorsMatch =
        comparatorResults.isNotEmpty &&
        comparatorResults.every(
          (IdentityComparatorResult result) => result.isMatch,
        );

    final bool isMatch =
        allComparatorsMatch &&
        !hasConflicts &&
        !missingDataBlocksMatch &&
        confidence >= policy.minimumConfidence;

    notes.add(
      isMatch
          ? 'The profiles satisfy the supplied identity policy.'
          : 'The profiles do not satisfy the supplied identity policy.',
    );

    final IdentityComparisonResult comparison = IdentityComparisonResult(
      isMatch: isMatch,
      confidence: confidence,
      matchedRoles: Set<IdentityRole>.unmodifiable(matchedRoles),
      conflictingRoles: Set<IdentityRole>.unmodifiable(conflictingRoles),
      missingRoles: Set<IdentityRole>.unmodifiable(missingRoles),
      matchedAttributes: List<String>.unmodifiable(matchedAttributes),
      conflictingAttributes: List<String>.unmodifiable(conflictingAttributes),
      missingAttributes: List<String>.unmodifiable(missingAttributes),
      notes: List<String>.unmodifiable(notes),
    );

    final int warningCount =
        conflictingAttributes.length + missingAttributes.length;

    final AtlasExecutionMetadata metadata = AtlasExecutionMetadata(
      engineName: 'IdentityDecisionEngine',
      engineVersion: '2.0.0',
      schemaVersion: '1.0.0',
      policyVersion: policy.version,
      startedAt: startedAt,
      completedAt: DateTime.now(),
      correlationId: '',
      warningCount: warningCount,
      evidenceCount: evidence.length,
      tags: <String, String>{
        'domain': 'identity',
        'operation': 'comparison',
        'comparison_mode': 'modular_comparators',
        'comparator_count': comparatorResults.length.toString(),
        'registry_size': activeRegistry.length.toString(),
      },
    );

    return AtlasResult<IdentityComparisonResult>(
      status: _resultStatus(
        conflictingRoles: conflictingRoles,
        missingRoles: missingRoles,
        missingAttributes: missingAttributes,
      ),
      output: comparison,
      warnings: List<String>.unmodifiable(notes),
      metadata: metadata,
    );
  }

  List<IdentityEvidence> _mergeEvidence(
    List<IdentityComparatorResult> results,
  ) {
    final List<IdentityEvidence> evidence = <IdentityEvidence>[];

    for (final IdentityComparatorResult result in results) {
      evidence.addAll(result.evidence);
    }

    return List<IdentityEvidence>.unmodifiable(evidence);
  }

  Set<IdentityRole> _matchedRoles(List<IdentityEvidence> evidence) {
    final Set<IdentityRole> roles = <IdentityRole>{};

    final Set<IdentityRole> conflicting = _conflictingRoles(evidence);

    for (final IdentityEvidence item in evidence) {
      if (item.supportsMatch && !conflicting.contains(item.role)) {
        roles.add(item.role);
      }
    }

    return roles;
  }

  Set<IdentityRole> _conflictingRoles(List<IdentityEvidence> evidence) {
    return evidence
        .where((IdentityEvidence item) => item.isConflict)
        .map((IdentityEvidence item) => item.role)
        .toSet();
  }

  Set<IdentityRole> _missingRoles({
    required List<IdentityEvidence> evidence,
    required IdentityPolicy policy,
  }) {
    final Set<IdentityRole> roles = <IdentityRole>{};

    for (final IdentityRole role in policy.requiredRoles) {
      final List<IdentityEvidence> roleEvidence = evidence
          .where((IdentityEvidence item) => item.role == role)
          .toList(growable: false);

      if (roleEvidence.isEmpty ||
          roleEvidence.every((IdentityEvidence item) => item.isMissing)) {
        roles.add(role);
      }
    }

    return roles;
  }

  List<String> _matchedAttributes(List<IdentityEvidence> evidence) {
    return evidence
        .where((IdentityEvidence item) => item.supportsMatch)
        .map(_matchedAttributeDescription)
        .toList(growable: false);
  }

  String _matchedAttributeDescription(IdentityEvidence evidence) {
    final String value = evidence.leftValue ?? evidence.rightValue ?? '';

    if (value.isEmpty) {
      return evidence.attributeKey;
    }

    return '${evidence.attributeKey}=$value';
  }

  List<String> _conflictingAttributes(List<IdentityEvidence> evidence) {
    return evidence
        .where((IdentityEvidence item) => item.isConflict)
        .map((IdentityEvidence item) {
          final String leftValue = item.leftValue ?? 'missing';

          final String rightValue = item.rightValue ?? 'missing';

          return '${item.attributeKey}: '
              '"$leftValue" != "$rightValue"';
        })
        .toList(growable: false);
  }

  List<String> _missingAttributes(List<IdentityEvidence> evidence) {
    return evidence
        .where((IdentityEvidence item) => item.isMissing)
        .map(_missingAttributeDescription)
        .toList(growable: false);
  }

  String _missingAttributeDescription(IdentityEvidence evidence) {
    if (!evidence.hasLeftValue && !evidence.hasRightValue) {
      return '${evidence.attributeKey}: '
          'missing from both profiles';
    }

    if (!evidence.hasLeftValue) {
      return '${evidence.attributeKey}: '
          'missing from left profile';
    }

    if (!evidence.hasRightValue) {
      return '${evidence.attributeKey}: '
          'missing from right profile';
    }

    return '${evidence.attributeKey}: '
        'missing comparison value';
  }

  double _calculateOverallConfidence(List<IdentityEvidence> evidence) {
    final Iterable<IdentityEvidence> participating = evidence.where(
      (IdentityEvidence item) => item.participatesInDecision,
    );

    double totalWeight = 0.0;
    double supportedScore = 0.0;

    for (final IdentityEvidence item in participating) {
      totalWeight += item.weight;

      if (item.supportsMatch) {
        supportedScore += item.weightedConfidence;
      }
    }

    if (totalWeight == 0.0) {
      return 0.0;
    }

    return (supportedScore / totalWeight).clamp(0.0, 1.0);
  }

  List<String> _buildNotes({
    required List<IdentityComparatorResult> comparatorResults,
    required Set<IdentityRole> conflictingRoles,
    required Set<IdentityRole> missingRoles,
    required List<String> missingAttributes,
    required IdentityPolicy policy,
  }) {
    final List<String> notes = <String>[];

    if (comparatorResults.isEmpty) {
      notes.add('No registered identity comparator supported this comparison.');
    }

    for (final IdentityComparatorResult result in comparatorResults) {
      for (final String note in result.notes) {
        notes.add('${result.comparatorName}: $note');
      }
    }

    if (missingRoles.isNotEmpty) {
      notes.add('Comparison completed with missing required identity roles.');
    }

    if (missingAttributes.isNotEmpty) {
      notes.add(
        'One or more identity attributes were available on only one profile.',
      );
    }

    if (conflictingRoles.isNotEmpty) {
      notes.add('One or more identity roles contained conflicting attributes.');
    }

    if (policy.allowPartialMatches &&
        (missingRoles.isNotEmpty || missingAttributes.isNotEmpty)) {
      notes.add('The supplied policy allows partial identity matches.');
    }

    return notes;
  }

  AtlasResultStatus _resultStatus({
    required Set<IdentityRole> conflictingRoles,
    required Set<IdentityRole> missingRoles,
    required List<String> missingAttributes,
  }) {
    if (conflictingRoles.isNotEmpty) {
      return AtlasResultStatus.conflictingEvidence;
    }

    if (missingRoles.isNotEmpty || missingAttributes.isNotEmpty) {
      return AtlasResultStatus.partialSuccess;
    }

    return AtlasResultStatus.success;
  }
}
