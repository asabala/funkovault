import '../attribute/identity_attribute.dart';
import '../attribute/identity_role.dart';
import '../evidence/identity_evidence.dart';
import '../evidence/identity_evidence_outcome.dart';
import '../policy/identity_policy.dart';
import '../profile/identity_profile.dart';
import 'identity_comparator.dart';
import 'identity_comparator_result.dart';

// Compares attributes that distinguish one collectible variant from another.
//
// Variant modifiers may include traits such as Chase, Glow, Metallic,
// Flocked, Diamond, Foil, Refractor, alternate artwork, scale, or color.
class VariantComparator implements IdentityComparator {
  const VariantComparator();

  @override
  String get id => 'atlas.identity.variant';

  @override
  String get name => 'Variant Comparator';

  @override
  String get version => '1.0.0';

  @override
  bool supports({
    required IdentityProfile left,
    required IdentityProfile right,
    required IdentityPolicy policy,
  }) {
    final List<IdentityAttribute> leftAttributes =
    left.attributesByRole(IdentityRole.variantModifier);

    final List<IdentityAttribute> rightAttributes =
    right.attributesByRole(IdentityRole.variantModifier);

    return leftAttributes.isNotEmpty || rightAttributes.isNotEmpty;
  }

  @override
  IdentityComparatorResult compare({
    required IdentityProfile left,
    required IdentityProfile right,
    required IdentityPolicy policy,
  }) {
    final List<IdentityAttribute> leftAttributes =
    _usableVariantAttributes(
      profile: left,
      policy: policy,
    );

    final List<IdentityAttribute> rightAttributes =
    _usableVariantAttributes(
      profile: right,
      policy: policy,
    );

    final Map<String, IdentityAttribute> leftByKey =
    _attributesByKey(leftAttributes);

    final Map<String, IdentityAttribute> rightByKey =
    _attributesByKey(rightAttributes);

    final Set<String> attributeKeys = <String>{
      ...leftByKey.keys,
      ...rightByKey.keys,
    };

    final List<IdentityEvidence> evidence = <IdentityEvidence>[];
    final List<String> notes = <String>[];

    if (attributeKeys.isEmpty) {
      evidence.add(
        IdentityEvidence(
          attributeKey: 'role.variant_modifier',
          role: IdentityRole.variantModifier,
          outcome: IdentityEvidenceOutcome.missingBoth,
          weight: _variantWeight,
          confidence: 0.0,
          reason:
          'Neither identity profile contains usable variant evidence.',
          tags: _evidenceTags(
            attributeKey: 'role.variant_modifier',
          ),
        ),
      );

      notes.add(
        'No usable variant modifiers were available for comparison.',
      );
    } else {
      final List<String> sortedKeys = attributeKeys.toList()..sort();

      for (final String attributeKey in sortedKeys) {
        evidence.add(
          _compareVariantAttribute(
            attributeKey: attributeKey,
            leftAttribute: leftByKey[attributeKey],
            rightAttribute: rightByKey[attributeKey],
          ),
        );
      }
    }

    final bool hasConflict = evidence.any(
          (IdentityEvidence item) => item.isConflict,
    );

    final bool hasUncertainEvidence = evidence.any(
          (IdentityEvidence item) {
        return item.outcome == IdentityEvidenceOutcome.uncertain;
      },
    );

    final bool hasMissingEvidence = evidence.any(
          (IdentityEvidence item) => item.isMissing,
    );

    final bool hasMatchEvidence = evidence.any(
          (IdentityEvidence item) => item.supportsMatch,
    );

    final double confidence = _calculateConfidence(evidence);

    final bool variantRoleRequired =
    policy.requiresRole(IdentityRole.variantModifier);

    final bool missingEvidenceBlocksMatch =
        variantRoleRequired &&
            hasMissingEvidence &&
            !policy.allowPartialMatches;

    final bool isMatch = hasMatchEvidence &&
        !hasConflict &&
        !hasUncertainEvidence &&
        !missingEvidenceBlocksMatch &&
        confidence >= policy.minimumConfidence;

    if (hasConflict) {
      notes.add(
        'One or more variant modifiers differ between the profiles.',
      );
    }

    if (hasUncertainEvidence) {
      notes.add(
        'One or more variant modifiers contain unresolved evidence.',
      );
    }

    if (missingEvidenceBlocksMatch) {
      notes.add(
        'Required variant evidence is missing from one or both profiles.',
      );
    }

    if (confidence < policy.minimumConfidence) {
      notes.add(
        'Variant confidence is below the policy minimum of '
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

  static const double _variantWeight = 1.0;

  List<IdentityAttribute> _usableVariantAttributes({
    required IdentityProfile profile,
    required IdentityPolicy policy,
  }) {
    return profile
        .attributesByRole(IdentityRole.variantModifier)
        .where(
          (IdentityAttribute attribute) {
        if (!attribute.contributesToIdentity) {
          return false;
        }

        if (policy.requiredClassifications.isNotEmpty &&
            !policy.includesClassification(
              attribute.classification,
            )) {
          return false;
        }

        return attribute.hasResolvedValue || attribute.hasConflict;
      },
    ).toList(growable: false);
  }

  Map<String, IdentityAttribute> _attributesByKey(
      List<IdentityAttribute> attributes,
      ) {
    final Map<String, IdentityAttribute> result =
    <String, IdentityAttribute>{};

    for (final IdentityAttribute attribute in attributes) {
      final IdentityAttribute? existing = result[attribute.key];

      if (existing == null ||
          attribute.resolutionConfidence >
              existing.resolutionConfidence) {
        result[attribute.key] = attribute;
      }
    }

    return result;
  }

  IdentityEvidence _compareVariantAttribute({
    required String attributeKey,
    required IdentityAttribute? leftAttribute,
    required IdentityAttribute? rightAttribute,
  }) {
    final String? leftValue = _resolvedValue(leftAttribute);
    final String? rightValue = _resolvedValue(rightAttribute);

    final Map<String, String> tags = _evidenceTags(
      attributeKey: attributeKey,
    );

    if (leftAttribute?.hasConflict == true ||
        rightAttribute?.hasConflict == true) {
      return IdentityEvidence(
        attributeKey: attributeKey,
        role: IdentityRole.variantModifier,
        leftValue: leftValue,
        rightValue: rightValue,
        outcome: IdentityEvidenceOutcome.uncertain,
        weight: _variantWeight,
        confidence: _combinedConfidence(
          leftAttribute,
          rightAttribute,
        ),
        reason:
        'One or both profiles contain unresolved internal evidence '
            'for variant attribute $attributeKey.',
        tags: <String, String>{
          ...tags,
          'reviewReason': 'internal_attribute_conflict',
        },
      );
    }

    if (leftValue == null && rightValue == null) {
      return IdentityEvidence(
        attributeKey: attributeKey,
        role: IdentityRole.variantModifier,
        outcome: IdentityEvidenceOutcome.missingBoth,
        weight: _variantWeight,
        confidence: 0.0,
        reason:
        'Both profiles are missing a resolved value for variant '
            'attribute $attributeKey.',
        tags: tags,
      );
    }

    if (leftValue == null) {
      return IdentityEvidence(
        attributeKey: attributeKey,
        role: IdentityRole.variantModifier,
        rightValue: rightValue,
        outcome: IdentityEvidenceOutcome.missingLeft,
        weight: _variantWeight,
        confidence: rightAttribute?.resolutionConfidence ?? 0.0,
        reason:
        'The left profile is missing variant attribute '
            '$attributeKey while the right profile contains a value.',
        tags: tags,
      );
    }

    if (rightValue == null) {
      return IdentityEvidence(
        attributeKey: attributeKey,
        role: IdentityRole.variantModifier,
        leftValue: leftValue,
        outcome: IdentityEvidenceOutcome.missingRight,
        weight: _variantWeight,
        confidence: leftAttribute?.resolutionConfidence ?? 0.0,
        reason:
        'The right profile is missing variant attribute '
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
        role: IdentityRole.variantModifier,
        leftValue: leftValue,
        rightValue: rightValue,
        outcome: IdentityEvidenceOutcome.matched,
        weight: _variantWeight,
        confidence: confidence,
        reason:
        'Both profiles contain the same normalized variant value '
            'for $attributeKey.',
        tags: tags,
      );
    }

    return IdentityEvidence(
      attributeKey: attributeKey,
      role: IdentityRole.variantModifier,
      leftValue: leftValue,
      rightValue: rightValue,
      outcome: IdentityEvidenceOutcome.conflicted,
      weight: _variantWeight,
      confidence: confidence,
      reason:
      'The profiles contain different variant values for '
          '$attributeKey.',
      tags: <String, String>{
        ...tags,
        'reviewReason': 'different_variant',
      },
    );
  }

  String? _resolvedValue(
      IdentityAttribute? attribute,
      ) {
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
        return 'true';

      case 'no':
      case 'false':
      case '0':
      case 'none':
      case 'not present':
        return 'false';

      default:
        return normalized;
    }
  }

  double _combinedConfidence(
      IdentityAttribute? left,
      IdentityAttribute? right,
      ) {
    final List<double> confidenceValues = <double>[
      if (left != null) left.resolutionConfidence,
      if (right != null) right.resolutionConfidence,
    ];

    if (confidenceValues.isEmpty) {
      return 0.0;
    }

    final double total = confidenceValues.fold<double>(
      0.0,
          (double sum, double value) => sum + value,
    );

    return total / confidenceValues.length;
  }

  double _calculateConfidence(
      List<IdentityEvidence> evidence,
      ) {
    final Iterable<IdentityEvidence> participating =
    evidence.where(
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
  }) {
    return <String, String>{
      'comparator': id,
      'comparatorVersion': version,
      'domain': 'variant',
      'role': IdentityRole.variantModifier.serializedValue,
      'attributeKey': attributeKey,
    };
  }
}