import '../attribute/identity_attribute.dart';
import '../attribute/identity_role.dart';
import '../evidence/identity_evidence.dart';
import '../evidence/identity_evidence_outcome.dart';
import '../policy/identity_policy.dart';
import '../profile/identity_profile.dart';
import 'identity_comparator.dart';
import 'identity_comparator_result.dart';

// Compares attributes that describe how a collectible was released.
//
// Release context can include retailer exclusivity, convention releases,
// distribution channels, print runs, editions, mint locations, stickers,
// regional releases, and other release-specific details.
class ReleaseContextComparator implements IdentityComparator {
  const ReleaseContextComparator();

  @override
  String get id => 'atlas.identity.release_context';

  @override
  String get name => 'Release Context Comparator';

  @override
  String get version => '1.0.0';

  @override
  bool supports({
    required IdentityProfile left,
    required IdentityProfile right,
    required IdentityPolicy policy,
  }) {
    final List<IdentityAttribute> leftAttributes = left.attributesByRole(
      IdentityRole.releaseContext,
    );

    final List<IdentityAttribute> rightAttributes = right.attributesByRole(
      IdentityRole.releaseContext,
    );

    return leftAttributes.isNotEmpty || rightAttributes.isNotEmpty;
  }

  @override
  IdentityComparatorResult compare({
    required IdentityProfile left,
    required IdentityProfile right,
    required IdentityPolicy policy,
  }) {
    final List<IdentityAttribute> leftAttributes =
        _usableReleaseContextAttributes(profile: left, policy: policy);

    final List<IdentityAttribute> rightAttributes =
        _usableReleaseContextAttributes(profile: right, policy: policy);

    final Map<String, IdentityAttribute> leftByKey = _attributesByKey(
      leftAttributes,
    );

    final Map<String, IdentityAttribute> rightByKey = _attributesByKey(
      rightAttributes,
    );

    final Set<String> attributeKeys = <String>{
      ...leftByKey.keys,
      ...rightByKey.keys,
    };

    final List<IdentityEvidence> evidence = <IdentityEvidence>[];
    final List<String> notes = <String>[];

    if (attributeKeys.isEmpty) {
      evidence.add(
        IdentityEvidence(
          attributeKey: 'role.release_context',
          role: IdentityRole.releaseContext,
          outcome: IdentityEvidenceOutcome.missingBoth,
          weight: _releaseContextWeight,
          confidence: 0.0,
          reason:
              'Neither identity profile contains usable release-context '
              'evidence.',
          tags: _evidenceTags(
            attributeKey: 'role.release_context',
            policy: policy,
          ),
        ),
      );

      notes.add(
        'No usable release-context attributes were available for comparison.',
      );
    } else {
      final List<String> sortedKeys = attributeKeys.toList()..sort();

      for (final String attributeKey in sortedKeys) {
        evidence.add(
          _compareReleaseContextAttribute(
            attributeKey: attributeKey,
            leftAttribute: leftByKey[attributeKey],
            rightAttribute: rightByKey[attributeKey],
            policy: policy,
          ),
        );
      }
    }

    final bool hasConflict = evidence.any(
      (IdentityEvidence item) => item.isConflict,
    );

    final bool hasUncertainEvidence = evidence.any((IdentityEvidence item) {
      return item.outcome == IdentityEvidenceOutcome.uncertain;
    });

    final bool hasMissingEvidence = evidence.any(
      (IdentityEvidence item) => item.isMissing,
    );

    final bool hasMatchEvidence = evidence.any(
      (IdentityEvidence item) => item.supportsMatch,
    );

    final bool releaseContextRequired = policy.requiresRole(
      IdentityRole.releaseContext,
    );

    final bool missingEvidenceBlocksMatch =
        releaseContextRequired &&
        hasMissingEvidence &&
        !policy.allowPartialMatches;

    final double confidence = _calculateConfidence(evidence);

    final bool isMatch =
        hasMatchEvidence &&
        !hasConflict &&
        !hasUncertainEvidence &&
        !missingEvidenceBlocksMatch &&
        confidence >= policy.minimumConfidence;

    if (hasConflict) {
      notes.add(
        'One or more release-context attributes differ between the profiles.',
      );
    }

    if (hasUncertainEvidence) {
      notes.add(
        'One or more release-context attributes contain unresolved evidence.',
      );
    }

    if (missingEvidenceBlocksMatch) {
      notes.add(
        'Required release-context evidence is missing from one or both '
        'profiles.',
      );
    }

    if (confidence < policy.minimumConfidence) {
      notes.add(
        'Release-context confidence is below the policy minimum of '
        '${policy.minimumConfidence.toStringAsFixed(2)}.',
      );
    }

    return IdentityComparatorResult(
      comparatorId: id,
      comparatorName: name,
      isMatch: isMatch,
      confidence: confidence,
      evidence: List<IdentityEvidence>.unmodifiable(evidence),
      notes: List<String>.unmodifiable(notes),
    );
  }

  static const double _releaseContextWeight = 1.0;

  List<IdentityAttribute> _usableReleaseContextAttributes({
    required IdentityProfile profile,
    required IdentityPolicy policy,
  }) {
    return profile
        .attributesByRole(IdentityRole.releaseContext)
        .where((IdentityAttribute attribute) {
          if (!attribute.contributesToIdentity) {
            return false;
          }

          if (policy.requiredClassifications.isNotEmpty &&
              !policy.includesClassification(attribute.classification)) {
            return false;
          }

          return attribute.hasResolvedValue || attribute.hasConflict;
        })
        .toList(growable: false);
  }

  Map<String, IdentityAttribute> _attributesByKey(
    List<IdentityAttribute> attributes,
  ) {
    final Map<String, IdentityAttribute> result = <String, IdentityAttribute>{};

    for (final IdentityAttribute attribute in attributes) {
      final IdentityAttribute? existing = result[attribute.key];

      if (existing == null ||
          attribute.resolutionConfidence > existing.resolutionConfidence) {
        result[attribute.key] = attribute;
      }
    }

    return result;
  }

  IdentityEvidence _compareReleaseContextAttribute({
    required String attributeKey,
    required IdentityAttribute? leftAttribute,
    required IdentityAttribute? rightAttribute,
    required IdentityPolicy policy,
  }) {
    final String? leftValue = _resolvedValue(leftAttribute);
    final String? rightValue = _resolvedValue(rightAttribute);

    final Map<String, String> tags = _evidenceTags(
      attributeKey: attributeKey,
      policy: policy,
    );

    if (leftAttribute?.hasConflict == true ||
        rightAttribute?.hasConflict == true) {
      return IdentityEvidence(
        attributeKey: attributeKey,
        role: IdentityRole.releaseContext,
        leftValue: leftValue,
        rightValue: rightValue,
        outcome: IdentityEvidenceOutcome.uncertain,
        weight: _releaseContextWeight,
        confidence: _combinedConfidence(leftAttribute, rightAttribute),
        reason:
            'One or both profiles contain unresolved internal evidence '
            'for release-context attribute $attributeKey.',
        tags: <String, String>{
          ...tags,
          'reviewReason': 'internal_attribute_conflict',
        },
      );
    }

    if (leftValue == null && rightValue == null) {
      return IdentityEvidence(
        attributeKey: attributeKey,
        role: IdentityRole.releaseContext,
        outcome: IdentityEvidenceOutcome.missingBoth,
        weight: _releaseContextWeight,
        confidence: 0.0,
        reason:
            'Both profiles are missing a resolved value for release-context '
            'attribute $attributeKey.',
        tags: tags,
      );
    }

    if (leftValue == null) {
      return IdentityEvidence(
        attributeKey: attributeKey,
        role: IdentityRole.releaseContext,
        rightValue: rightValue,
        outcome: IdentityEvidenceOutcome.missingLeft,
        weight: _releaseContextWeight,
        confidence: rightAttribute?.resolutionConfidence ?? 0.0,
        reason:
            'The left profile is missing release-context attribute '
            '$attributeKey while the right profile contains a value.',
        tags: tags,
      );
    }

    if (rightValue == null) {
      return IdentityEvidence(
        attributeKey: attributeKey,
        role: IdentityRole.releaseContext,
        leftValue: leftValue,
        outcome: IdentityEvidenceOutcome.missingRight,
        weight: _releaseContextWeight,
        confidence: leftAttribute?.resolutionConfidence ?? 0.0,
        reason:
            'The right profile is missing release-context attribute '
            '$attributeKey while the left profile contains a value.',
        tags: tags,
      );
    }

    final String normalizedLeft = _normalizeValue(leftValue);
    final String normalizedRight = _normalizeValue(rightValue);

    final double confidence = _combinedConfidence(
      leftAttribute,
      rightAttribute,
    );

    if (normalizedLeft == normalizedRight) {
      return IdentityEvidence(
        attributeKey: attributeKey,
        role: IdentityRole.releaseContext,
        leftValue: leftValue,
        rightValue: rightValue,
        outcome: IdentityEvidenceOutcome.matched,
        weight: _releaseContextWeight,
        confidence: confidence,
        reason:
            'Both profiles contain the same normalized release-context '
            'value for $attributeKey.',
        tags: tags,
      );
    }

    return IdentityEvidence(
      attributeKey: attributeKey,
      role: IdentityRole.releaseContext,
      leftValue: leftValue,
      rightValue: rightValue,
      outcome: IdentityEvidenceOutcome.conflicted,
      weight: _releaseContextWeight,
      confidence: confidence,
      reason:
          'The profiles contain different release-context values for '
          '$attributeKey.',
      tags: <String, String>{
        ...tags,
        'reviewReason': 'different_release_context',
      },
    );
  }

  String? _resolvedValue(IdentityAttribute? attribute) {
    if (attribute == null || !attribute.hasResolvedValue) {
      return null;
    }

    final String value = attribute.resolvedValue!.trim();

    return value.isEmpty ? null : value;
  }

  String _normalizeValue(String value) {
    final String normalized = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    switch (normalized) {
      case 'yes':
      case 'true':
      case '1':
      case 'present':
      case 'exclusive':
        return 'true';

      case 'no':
      case 'false':
      case '0':
      case 'none':
      case 'not present':
      case 'standard':
        return 'false';

      default:
        return normalized;
    }
  }

  double _combinedConfidence(
    IdentityAttribute? left,
    IdentityAttribute? right,
  ) {
    final List<double> values = <double>[
      if (left != null) left.resolutionConfidence,
      if (right != null) right.resolutionConfidence,
    ];

    if (values.isEmpty) {
      return 0.0;
    }

    final double total = values.fold<double>(
      0.0,
      (double sum, double value) => sum + value,
    );

    return total / values.length;
  }

  double _calculateConfidence(List<IdentityEvidence> evidence) {
    final Iterable<IdentityEvidence> participating = evidence.where(
      (IdentityEvidence item) => item.participatesInDecision,
    );

    double totalWeight = 0.0;
    double totalScore = 0.0;

    for (final IdentityEvidence item in participating) {
      totalWeight += item.weight;

      if (item.supportsMatch) {
        totalScore += item.weightedConfidence;
      }
    }

    if (totalWeight == 0.0) {
      return 0.0;
    }

    return (totalScore / totalWeight).clamp(0.0, 1.0);
  }

  Map<String, String> _evidenceTags({
    required String attributeKey,
    required IdentityPolicy policy,
  }) {
    final bool isRequired = policy.requiresRole(IdentityRole.releaseContext);

    return <String, String>{
      'comparator': id,
      'comparatorVersion': version,
      'domain': 'release_context',
      'role': IdentityRole.releaseContext.serializedValue,
      'attributeKey': attributeKey,
      'requirement': isRequired ? 'required' : 'optional',
    };
  }
}
