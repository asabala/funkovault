import '../observation/identity_observation.dart';
import '../observation/identity_presence.dart';
import 'identity_classification.dart';
import 'identity_role.dart';

// Represents one identity attribute and all evidence observed for it.
//
// An attribute groups observations that describe the same identity role.
// Atlas can later resolve those observations into a preferred value while
// preserving the original evidence for traceability.
class IdentityAttribute {
  IdentityAttribute({
    required this.key,
    required this.role,
    required this.classification,
    this.observations = const <IdentityObservation>[],
    this.resolvedValue,
    this.resolvedPresence = IdentityPresence.unknown,
    this.resolutionConfidence = 0.0,
  })  : assert(
  key.trim().isNotEmpty,
  'Identity attribute key cannot be empty.',
  ),
        assert(
        resolutionConfidence >= 0.0 && resolutionConfidence <= 1.0,
        'Resolution confidence must be between 0.0 and 1.0.',
        ),
        assert(
        resolvedPresence.isKnown
            ? resolvedValue != null && resolvedValue.trim().isNotEmpty
            : true,
        'Known attributes must contain a resolved value.',
        );

  // Stable category-specific identifier for this attribute.
  //
  // Examples:
  // funko.pop_number
  // funko.chase
  // comic.issue_number
  // coin.mint_mark
  final String key;

  // Universal category-neutral role used by Atlas comparisons.
  final IdentityRole role;

  // Describes how strongly this attribute contributes to identity.
  final IdentityClassification classification;

  // All evidence collected for this attribute.
  final List<IdentityObservation> observations;

  // Preferred value resolved from the available observations.
  final String? resolvedValue;

  // Current presence state of the resolved attribute.
  final IdentityPresence resolvedPresence;

  // Confidence in the resolved value.
  final double resolutionConfidence;

  // True when a resolved value is available for comparison.
  bool get hasResolvedValue {
    return resolvedPresence.isKnown &&
        resolvedValue != null &&
        resolvedValue!.trim().isNotEmpty;
  }

  // True when the attribute has at least one observation.
  bool get hasObservations => observations.isNotEmpty;

  // True when one or more observations can be used as evidence.
  bool get hasUsableObservations {
    return observations.any(
          (IdentityObservation observation) => observation.isUsable,
    );
  }

  // True when the resolved state represents conflicting evidence.
  bool get hasConflict => resolvedPresence.isConflicting;

  // True when this attribute contributes to identity comparison.
  bool get contributesToIdentity {
    return classification.contributesToIdentity;
  }

  // Returns usable observations only.
  List<IdentityObservation> get usableObservations {
    return List<IdentityObservation>.unmodifiable(
      observations.where(
            (IdentityObservation observation) => observation.isUsable,
      ),
    );
  }

  // Returns a copy with an additional observation.
  IdentityAttribute addObservation(
      IdentityObservation observation,
      ) {
    assert(
    observation.role == role,
    'Observation role must match the attribute role.',
    );

    return copyWith(
      observations: <IdentityObservation>[
        ...observations,
        observation,
      ],
    );
  }

  // Creates a modified copy.
  IdentityAttribute copyWith({
    String? key,
    IdentityRole? role,
    IdentityClassification? classification,
    List<IdentityObservation>? observations,
    String? resolvedValue,
    bool clearResolvedValue = false,
    IdentityPresence? resolvedPresence,
    double? resolutionConfidence,
  }) {
    return IdentityAttribute(
      key: key ?? this.key,
      role: role ?? this.role,
      classification: classification ?? this.classification,
      observations: List<IdentityObservation>.unmodifiable(
        observations ?? this.observations,
      ),
      resolvedValue: clearResolvedValue
          ? null
          : resolvedValue ?? this.resolvedValue,
      resolvedPresence: resolvedPresence ?? this.resolvedPresence,
      resolutionConfidence:
      resolutionConfidence ?? this.resolutionConfidence,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'key': key,
      'role': role.serializedValue,
      'classification': classification.serializedValue,
      'observations': observations
          .map(
            (IdentityObservation observation) => observation.toJson(),
      )
          .toList(growable: false),
      'resolvedValue': resolvedValue,
      'resolvedPresence': resolvedPresence.serializedValue,
      'resolutionConfidence': resolutionConfidence,
    };
  }

  factory IdentityAttribute.fromJson(
      Map<String, dynamic> json,
      ) {
    final List<dynamic> rawObservations =
        json['observations'] as List<dynamic>? ?? const <dynamic>[];

    return IdentityAttribute(
      key: json['key'] as String,
      role: IdentityRole.fromSerializedValue(
        json['role'] as String,
      ),
      classification: IdentityClassification.fromSerializedValue(
        json['classification'] as String,
      ),
      observations: List<IdentityObservation>.unmodifiable(
        rawObservations.map(
              (dynamic observation) => IdentityObservation.fromJson(
            Map<String, dynamic>.from(
              observation as Map<dynamic, dynamic>,
            ),
          ),
        ),
      ),
      resolvedValue: json['resolvedValue'] as String?,
      resolvedPresence: IdentityPresence.fromSerializedValue(
        json['resolvedPresence'] as String? ?? 'unknown',
      ),
      resolutionConfidence:
      (json['resolutionConfidence'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  String toString() {
    return 'IdentityAttribute('
        'key: $key, '
        'role: ${role.serializedValue}, '
        'classification: ${classification.serializedValue}, '
        'observations: ${observations.length}, '
        'resolvedValue: $resolvedValue, '
        'resolvedPresence: ${resolvedPresence.serializedValue}, '
        'resolutionConfidence: $resolutionConfidence'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is IdentityAttribute &&
            key == other.key &&
            role == other.role &&
            classification == other.classification &&
            _listsEqual(observations, other.observations) &&
            resolvedValue == other.resolvedValue &&
            resolvedPresence == other.resolvedPresence &&
            resolutionConfidence == other.resolutionConfidence;
  }

  @override
  int get hashCode {
    return Object.hash(
      key,
      role,
      classification,
      Object.hashAll(observations),
      resolvedValue,
      resolvedPresence,
      resolutionConfidence,
    );
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