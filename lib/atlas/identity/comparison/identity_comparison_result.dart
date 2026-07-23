import '../attribute/identity_role.dart';

// Represents the outcome of comparing two identity profiles.
//
// This object contains the comparison evidence but does not decide what
// action Atlas should take. That responsibility belongs to the decision
// engine.
class IdentityComparisonResult {
  IdentityComparisonResult({
    required this.isMatch,
    required this.confidence,
    this.matchedRoles = const <IdentityRole>{},
    this.conflictingRoles = const <IdentityRole>{},
    this.missingRoles = const <IdentityRole>{},
    this.matchedAttributes = const <String>[],
    this.conflictingAttributes = const <String>[],
    this.missingAttributes = const <String>[],
    this.notes = const <String>[],
  }) : assert(
  confidence >= 0.0 && confidence <= 1.0,
  'Confidence must be between 0.0 and 1.0.',
  );

  // Whether the compared identities matched.
  final bool isMatch;

  // Overall comparison confidence.
  final double confidence;

  // Roles that matched successfully.
  final Set<IdentityRole> matchedRoles;

  // Roles whose resolved values conflicted.
  final Set<IdentityRole> conflictingRoles;

  // Roles expected by policy but not available.
  final Set<IdentityRole> missingRoles;

  // Individual identity attributes that matched.
  final List<String> matchedAttributes;

  // Individual identity attributes that conflicted.
  final List<String> conflictingAttributes;

  // Individual identity attributes that were missing.
  final List<String> missingAttributes;

  // Additional informational notes.
  final List<String> notes;

  bool get hasConflicts {
    return conflictingRoles.isNotEmpty ||
        conflictingAttributes.isNotEmpty;
  }

  bool get hasMissingRoles => missingRoles.isNotEmpty;

  bool get hasMissingAttributes => missingAttributes.isNotEmpty;

  bool get hasMissingData {
    return hasMissingRoles || hasMissingAttributes;
  }

  bool get hasNotes => notes.isNotEmpty;

  bool get isComplete {
    return !hasConflicts && !hasMissingData;
  }

  bool roleMatched(IdentityRole role) {
    return matchedRoles.contains(role);
  }

  bool roleConflicted(IdentityRole role) {
    return conflictingRoles.contains(role);
  }

  bool roleMissing(IdentityRole role) {
    return missingRoles.contains(role);
  }

  bool attributeMatched(String attributeKey) {
    return matchedAttributes.contains(attributeKey);
  }

  bool attributeConflicted(String attributeKey) {
    return conflictingAttributes.contains(attributeKey);
  }

  bool attributeMissing(String attributeKey) {
    return missingAttributes.contains(attributeKey);
  }

  IdentityComparisonResult copyWith({
    bool? isMatch,
    double? confidence,
    Set<IdentityRole>? matchedRoles,
    Set<IdentityRole>? conflictingRoles,
    Set<IdentityRole>? missingRoles,
    List<String>? matchedAttributes,
    List<String>? conflictingAttributes,
    List<String>? missingAttributes,
    List<String>? notes,
  }) {
    return IdentityComparisonResult(
      isMatch: isMatch ?? this.isMatch,
      confidence: confidence ?? this.confidence,
      matchedRoles: matchedRoles ?? this.matchedRoles,
      conflictingRoles:
      conflictingRoles ?? this.conflictingRoles,
      missingRoles: missingRoles ?? this.missingRoles,
      matchedAttributes:
      matchedAttributes ?? this.matchedAttributes,
      conflictingAttributes:
      conflictingAttributes ?? this.conflictingAttributes,
      missingAttributes:
      missingAttributes ?? this.missingAttributes,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'IdentityComparisonResult('
        'match: $isMatch, '
        'confidence: $confidence, '
        'matchedRoles: ${matchedRoles.length}, '
        'conflictingRoles: ${conflictingRoles.length}, '
        'missingRoles: ${missingRoles.length}, '
        'matchedAttributes: ${matchedAttributes.length}, '
        'conflictingAttributes: ${conflictingAttributes.length}, '
        'missingAttributes: ${missingAttributes.length}'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is IdentityComparisonResult &&
            isMatch == other.isMatch &&
            confidence == other.confidence &&
            _setsEqual(matchedRoles, other.matchedRoles) &&
            _setsEqual(
              conflictingRoles,
              other.conflictingRoles,
            ) &&
            _setsEqual(missingRoles, other.missingRoles) &&
            _listsEqual(
              matchedAttributes,
              other.matchedAttributes,
            ) &&
            _listsEqual(
              conflictingAttributes,
              other.conflictingAttributes,
            ) &&
            _listsEqual(
              missingAttributes,
              other.missingAttributes,
            ) &&
            _listsEqual(notes, other.notes);
  }

  @override
  int get hashCode {
    return Object.hash(
      isMatch,
      confidence,
      Object.hashAll(matchedRoles),
      Object.hashAll(conflictingRoles),
      Object.hashAll(missingRoles),
      Object.hashAll(matchedAttributes),
      Object.hashAll(conflictingAttributes),
      Object.hashAll(missingAttributes),
      Object.hashAll(notes),
    );
  }

  static bool _setsEqual<T>(
      Set<T> first,
      Set<T> second,
      ) {
    if (identical(first, second)) {
      return true;
    }

    if (first.length != second.length) {
      return false;
    }

    return first.containsAll(second);
  }

  static bool _listsEqual<T>(
      List<T> first,
      List<T> second,
      ) {
    if (identical(first, second)) {
      return true;
    }

    if (first.length != second.length) {
      return false;
    }

    for (int index = 0; index < first.length; index++) {
      if (first[index] != second[index]) {
        return false;
      }
    }

    return true;
  }
}