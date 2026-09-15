import '../attribute/identity_attribute.dart';
import '../attribute/identity_role.dart';
import '../evidence/identity_evidence.dart';
import '../evidence/identity_evidence_outcome.dart';
import '../policy/identity_policy.dart';
import '../profile/identity_profile.dart';
import 'identity_comparator.dart';
import 'identity_comparator_result.dart';

// Compares the foundational attributes that establish a collectible's
// canonical identity.
//
// This comparator intentionally excludes release-context and variant
// attributes. Those will be evaluated by dedicated comparators.
class CoreAnchorComparator implements IdentityComparator {
  const CoreAnchorComparator();

  static const Set<IdentityRole> _supportedRoles = <IdentityRole>{
    IdentityRole.category,
    IdentityRole.maker,
    IdentityRole.entityAnchor,
    IdentityRole.catalogIndex,
    IdentityRole.primaryDescriptor,
    IdentityRole.temporalMarker,
  };

  @override
  String get id => 'atlas.identity.core_anchor';

  @override
  String get name => 'Core Anchor Comparator';

  @override
  String get version => '1.0.0';

  @override
  bool supports({
    required IdentityProfile left,
    required IdentityProfile right,
    required IdentityPolicy policy,
  }) {
    if (left.isEmpty || right.isEmpty) {
      return false;
    }

    final Set<IdentityRole> policyRoles = <IdentityRole>{
      ...policy.requiredRoles,
      ...policy.optionalRoles,
    };

    final Set<IdentityRole> rolesToEvaluate = policyRoles.isEmpty
        ? _supportedRoles
        : policyRoles.intersection(_supportedRoles);

    if (rolesToEvaluate.isEmpty) {
      return false;
    }

    return rolesToEvaluate.any((IdentityRole role) {
      return left.attributesByRole(role).isNotEmpty ||
          right.attributesByRole(role).isNotEmpty;
    });
  }

  @override
  IdentityComparatorResult compare({
    required IdentityProfile left,
    required IdentityProfile right,
    required IdentityPolicy policy,
  }) {
    final Set<IdentityRole> rolesToEvaluate = _rolesForPolicy(policy);
    final List<IdentityEvidence> evidence = <IdentityEvidence>[];
    final List<String> notes = <String>[];

    for (final IdentityRole role in rolesToEvaluate) {
      final List<IdentityAttribute> leftAttributes = _usableAttributesForRole(
        profile: left,
        role: role,
        policy: policy,
      );

      final List<IdentityAttribute> rightAttributes = _usableAttributesForRole(
        profile: right,
        role: role,
        policy: policy,
      );

      evidence.addAll(
        _compareRole(
          role: role,
          leftAttributes: leftAttributes,
          rightAttributes: rightAttributes,
          policy: policy,
        ),
      );
    }

    if (evidence.isEmpty) {
      notes.add('No usable core-anchor evidence was available for comparison.');
    }

    final double confidence = _calculateConfidence(evidence);

    final bool hasConflict = evidence.any(
      (IdentityEvidence item) => item.isConflict,
    );

    final bool hasMissingRequiredEvidence = evidence.any((
      IdentityEvidence item,
    ) {
      return item.isMissing && item.tags['requirement'] == 'required';
    });

    final bool hasMatchEvidence = evidence.any(
      (IdentityEvidence item) => item.supportsMatch,
    );

    final bool isMatch =
        hasMatchEvidence &&
        !hasConflict &&
        confidence >= policy.minimumConfidence &&
        (policy.allowPartialMatches || !hasMissingRequiredEvidence);

    if (hasConflict) {
      notes.add(
        'One or more core-anchor attributes contain conflicting values.',
      );
    }

    if (hasMissingRequiredEvidence) {
      notes.add('One or more required core-anchor attributes are missing.');
    }

    if (confidence < policy.minimumConfidence) {
      notes.add(
        'Core-anchor confidence is below the policy minimum of '
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

  Set<IdentityRole> _rolesForPolicy(IdentityPolicy policy) {
    final Set<IdentityRole> policyRoles = <IdentityRole>{
      ...policy.requiredRoles,
      ...policy.optionalRoles,
    };

    if (policyRoles.isEmpty) {
      return _supportedRoles;
    }

    return policyRoles.intersection(_supportedRoles);
  }

  List<IdentityAttribute> _usableAttributesForRole({
    required IdentityProfile profile,
    required IdentityRole role,
    required IdentityPolicy policy,
  }) {
    return profile
        .attributesByRole(role)
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

  List<IdentityEvidence> _compareRole({
    required IdentityRole role,
    required List<IdentityAttribute> leftAttributes,
    required List<IdentityAttribute> rightAttributes,
    required IdentityPolicy policy,
  }) {
    final Map<String, IdentityAttribute> leftByKey = _attributeValueMap(
      leftAttributes,
    );

    final Map<String, IdentityAttribute> rightByKey = _attributeValueMap(
      rightAttributes,
    );

    final Set<String> attributeKeys = <String>{
      ...leftByKey.keys,
      ...rightByKey.keys,
    };

    final bool isRequired = policy.requiresRole(role);
    final double weight = _weightForRole(role: role, isRequired: isRequired);

    if (attributeKeys.isEmpty) {
      return <IdentityEvidence>[
        IdentityEvidence(
          attributeKey: 'role.${role.serializedValue}',
          role: role,
          outcome: IdentityEvidenceOutcome.missingBoth,
          weight: weight,
          confidence: 0.0,
          reason:
              'Neither identity profile contains a usable value for '
              '${role.serializedValue}.',
          tags: _evidenceTags(role: role, isRequired: isRequired),
        ),
      ];
    }

    final List<String> sortedKeys = attributeKeys.toList()..sort();

    return sortedKeys
        .map((String attributeKey) {
          final IdentityAttribute? leftAttribute = leftByKey[attributeKey];

          final IdentityAttribute? rightAttribute = rightByKey[attributeKey];

          return _compareAttribute(
            attributeKey: attributeKey,
            role: role,
            leftAttribute: leftAttribute,
            rightAttribute: rightAttribute,
            weight: weight,
            isRequired: isRequired,
          );
        })
        .toList(growable: false);
  }

  IdentityEvidence _compareAttribute({
    required String attributeKey,
    required IdentityRole role,
    required IdentityAttribute? leftAttribute,
    required IdentityAttribute? rightAttribute,
    required double weight,
    required bool isRequired,
  }) {
    final String? leftValue = _resolvedValue(leftAttribute);
    final String? rightValue = _resolvedValue(rightAttribute);

    final Map<String, String> tags = _evidenceTags(
      role: role,
      isRequired: isRequired,
    );

    if (leftAttribute?.hasConflict == true ||
        rightAttribute?.hasConflict == true) {
      return IdentityEvidence(
        attributeKey: attributeKey,
        role: role,
        leftValue: leftValue,
        rightValue: rightValue,
        outcome: IdentityEvidenceOutcome.uncertain,
        weight: weight,
        confidence: _combinedConfidence(leftAttribute, rightAttribute),
        reason:
            'One or both identity profiles contain unresolved internal '
            'conflicts for $attributeKey.',
        tags: <String, String>{
          ...tags,
          'reviewReason': 'internal_attribute_conflict',
        },
      );
    }

    if (leftValue == null && rightValue == null) {
      return IdentityEvidence(
        attributeKey: attributeKey,
        role: role,
        outcome: IdentityEvidenceOutcome.missingBoth,
        weight: weight,
        confidence: 0.0,
        reason:
            'Both identity profiles are missing a resolved value for '
            '$attributeKey.',
        tags: tags,
      );
    }

    if (leftValue == null) {
      return IdentityEvidence(
        attributeKey: attributeKey,
        role: role,
        rightValue: rightValue,
        outcome: IdentityEvidenceOutcome.missingLeft,
        weight: weight,
        confidence: rightAttribute?.resolutionConfidence ?? 0.0,
        reason:
            'The left identity profile is missing a resolved value for '
            '$attributeKey.',
        tags: tags,
      );
    }

    if (rightValue == null) {
      return IdentityEvidence(
        attributeKey: attributeKey,
        role: role,
        leftValue: leftValue,
        outcome: IdentityEvidenceOutcome.missingRight,
        weight: weight,
        confidence: leftAttribute?.resolutionConfidence ?? 0.0,
        reason:
            'The right identity profile is missing a resolved value for '
            '$attributeKey.',
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
        role: role,
        leftValue: leftValue,
        rightValue: rightValue,
        outcome: IdentityEvidenceOutcome.matched,
        weight: weight,
        confidence: confidence,
        reason:
            'Both identity profiles contain the same normalized value '
            'for $attributeKey.',
        tags: tags,
      );
    }

    return IdentityEvidence(
      attributeKey: attributeKey,
      role: role,
      leftValue: leftValue,
      rightValue: rightValue,
      outcome: IdentityEvidenceOutcome.conflicted,
      weight: weight,
      confidence: confidence,
      reason:
          'The identity profiles contain different resolved values for '
          '$attributeKey.',
      tags: tags,
    );
  }

  Map<String, IdentityAttribute> _attributeValueMap(
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

  String? _resolvedValue(IdentityAttribute? attribute) {
    if (attribute == null || !attribute.hasResolvedValue) {
      return null;
    }

    final String value = attribute.resolvedValue!.trim();

    return value.isEmpty ? null : value;
  }

  String _normalizeValue(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
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

  double _weightForRole({
    required IdentityRole role,
    required bool isRequired,
  }) {
    final double baseWeight;

    switch (role) {
      case IdentityRole.category:
        baseWeight = 1.0;

      case IdentityRole.maker:
        baseWeight = 0.90;

      case IdentityRole.entityAnchor:
        baseWeight = 1.0;

      case IdentityRole.catalogIndex:
        baseWeight = 1.0;

      case IdentityRole.primaryDescriptor:
        baseWeight = 0.85;

      case IdentityRole.temporalMarker:
        baseWeight = 0.70;

      case IdentityRole.releaseContext:
      case IdentityRole.variantModifier:
        baseWeight = 0.0;
    }

    if (isRequired) {
      return baseWeight;
    }

    return (baseWeight * 0.60).clamp(0.0, 1.0);
  }

  Map<String, String> _evidenceTags({
    required IdentityRole role,
    required bool isRequired,
  }) {
    return <String, String>{
      'comparator': id,
      'comparatorVersion': version,
      'domain': 'core_anchor',
      'role': role.serializedValue,
      'requirement': isRequired ? 'required' : 'optional',
    };
  }
}
