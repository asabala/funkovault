import '../attribute/identity_role.dart';
import 'identity_evidence_outcome.dart';

// Represents one explainable piece of evidence produced during an
// identity comparison.
//
// Evidence records the values that were evaluated, the comparison
// outcome, its importance, and the reason for that outcome.
class IdentityEvidence {
  const IdentityEvidence({
    required this.attributeKey,
    required this.role,
    required this.outcome,
    required this.weight,
    required this.confidence,
    required this.reason,
    this.leftValue,
    this.rightValue,
    this.leftSource,
    this.rightSource,
    this.tags = const <String, String>{},
  })  : assert(
  weight >= 0.0 && weight <= 1.0,
  'Weight must be between 0.0 and 1.0.',
  ),
        assert(
        confidence >= 0.0 && confidence <= 1.0,
        'Confidence must be between 0.0 and 1.0.',
        );

  // Stable key identifying the attribute being evaluated.
  final String attributeKey;

  // Universal identity role associated with the attribute.
  final IdentityRole role;

  // Value supplied by the left identity profile.
  final String? leftValue;

  // Value supplied by the right identity profile.
  final String? rightValue;

  // Result of evaluating the two values.
  final IdentityEvidenceOutcome outcome;

  // Relative importance of this evidence to the identity decision.
  final double weight;

  // Confidence Atlas has in this individual evidence record.
  final double confidence;

  // Human-readable explanation of the evidence outcome.
  final String reason;

  // Optional source description for the left value.
  final String? leftSource;

  // Optional source description for the right value.
  final String? rightSource;

  // Optional structured metadata for adapters and comparators.
  final Map<String, String> tags;

  bool get supportsMatch => outcome.supportsMatch;

  bool get isConflict => outcome.isConflict;

  bool get isMissing => outcome.isMissing;

  bool get requiresReview => outcome.requiresReview;

  bool get participatesInDecision {
    return outcome.participatesInDecision && weight > 0.0;
  }

  bool get hasLeftValue {
    return leftValue != null && leftValue!.trim().isNotEmpty;
  }

  bool get hasRightValue {
    return rightValue != null && rightValue!.trim().isNotEmpty;
  }

  bool get hasBothValues => hasLeftValue && hasRightValue;

  double get weightedConfidence {
    if (!participatesInDecision) {
      return 0.0;
    }

    return weight * confidence;
  }

  IdentityEvidence copyWith({
    String? attributeKey,
    IdentityRole? role,
    String? leftValue,
    String? rightValue,
    IdentityEvidenceOutcome? outcome,
    double? weight,
    double? confidence,
    String? reason,
    String? leftSource,
    String? rightSource,
    Map<String, String>? tags,
    bool clearLeftValue = false,
    bool clearRightValue = false,
    bool clearLeftSource = false,
    bool clearRightSource = false,
  }) {
    return IdentityEvidence(
      attributeKey: attributeKey ?? this.attributeKey,
      role: role ?? this.role,
      leftValue: clearLeftValue
          ? null
          : leftValue ?? this.leftValue,
      rightValue: clearRightValue
          ? null
          : rightValue ?? this.rightValue,
      outcome: outcome ?? this.outcome,
      weight: weight ?? this.weight,
      confidence: confidence ?? this.confidence,
      reason: reason ?? this.reason,
      leftSource: clearLeftSource
          ? null
          : leftSource ?? this.leftSource,
      rightSource: clearRightSource
          ? null
          : rightSource ?? this.rightSource,
      tags: tags ?? this.tags,
    );
  }

  @override
  String toString() {
    return 'IdentityEvidence('
        'attributeKey: $attributeKey, '
        'role: ${role.name}, '
        'outcome: ${outcome.serializedValue}, '
        'weight: $weight, '
        'confidence: $confidence, '
        'leftValue: $leftValue, '
        'rightValue: $rightValue'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is IdentityEvidence &&
            attributeKey == other.attributeKey &&
            role == other.role &&
            leftValue == other.leftValue &&
            rightValue == other.rightValue &&
            outcome == other.outcome &&
            weight == other.weight &&
            confidence == other.confidence &&
            reason == other.reason &&
            leftSource == other.leftSource &&
            rightSource == other.rightSource &&
            _mapsEqual(tags, other.tags);
  }

  @override
  int get hashCode {
    return Object.hash(
      attributeKey,
      role,
      leftValue,
      rightValue,
      outcome,
      weight,
      confidence,
      reason,
      leftSource,
      rightSource,
      Object.hashAll(
        tags.entries.map(
              (MapEntry<String, String> entry) {
            return Object.hash(entry.key, entry.value);
          },
        ),
      ),
    );
  }

  static bool _mapsEqual<K, V>(
      Map<K, V> first,
      Map<K, V> second,
      ) {
    if (identical(first, second)) {
      return true;
    }

    if (first.length != second.length) {
      return false;
    }

    for (final MapEntry<K, V> entry in first.entries) {
      if (!second.containsKey(entry.key) ||
          second[entry.key] != entry.value) {
        return false;
      }
    }

    return true;
  }
}