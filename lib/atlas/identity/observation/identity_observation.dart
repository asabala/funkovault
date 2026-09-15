import '../attribute/identity_role.dart';
import 'identity_presence.dart';
import 'identity_source_type.dart';

// Represents a single observed identity fact.
//
// Multiple observations may exist for the same attribute. Atlas later
// evaluates those observations to resolve conflicts and determine the
// canonical identity.
class IdentityObservation {
  IdentityObservation({
    required this.role,
    required this.value,
    required this.presence,
    required this.sourceType,
    this.confidence = 1.0,
    this.observedAt,
    this.sourceReference,
  }) : assert(
         confidence >= 0.0 && confidence <= 1.0,
         'Confidence must be between 0.0 and 1.0.',
       );

  // The identity role this observation represents.
  final IdentityRole role;

  // The observed value.
  final String value;

  // Whether the value is known, unknown, conflicting, etc.
  final IdentityPresence presence;

  // Where this observation originated.
  final IdentitySourceType sourceType;

  // Confidence assigned to this observation.
  final double confidence;

  // When the observation was created.
  final DateTime? observedAt;

  // Optional external identifier or reference.
  final String? sourceReference;

  // True when this observation has a usable value.
  bool get hasValue => value.trim().isNotEmpty;

  // True when Atlas considers the observation usable.
  bool get isUsable {
    return presence.isKnown && hasValue;
  }

  // Creates a modified copy.
  IdentityObservation copyWith({
    IdentityRole? role,
    String? value,
    IdentityPresence? presence,
    IdentitySourceType? sourceType,
    double? confidence,
    DateTime? observedAt,
    String? sourceReference,
  }) {
    return IdentityObservation(
      role: role ?? this.role,
      value: value ?? this.value,
      presence: presence ?? this.presence,
      sourceType: sourceType ?? this.sourceType,
      confidence: confidence ?? this.confidence,
      observedAt: observedAt ?? this.observedAt,
      sourceReference: sourceReference ?? this.sourceReference,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'role': role.serializedValue,
      'value': value,
      'presence': presence.serializedValue,
      'sourceType': sourceType.serializedValue,
      'confidence': confidence,
      'observedAt': observedAt?.toIso8601String(),
      'sourceReference': sourceReference,
    };
  }

  factory IdentityObservation.fromJson(Map<String, dynamic> json) {
    return IdentityObservation(
      role: IdentityRole.fromSerializedValue(json['role'] as String),
      value: json['value'] as String? ?? '',
      presence: IdentityPresence.fromSerializedValue(
        json['presence'] as String,
      ),
      sourceType: IdentitySourceType.fromSerializedValue(
        json['sourceType'] as String,
      ),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      observedAt: json['observedAt'] == null
          ? null
          : DateTime.parse(json['observedAt'] as String),
      sourceReference: json['sourceReference'] as String?,
    );
  }

  @override
  String toString() {
    return 'IdentityObservation('
        'role: ${role.serializedValue}, '
        'value: $value, '
        'presence: ${presence.serializedValue}, '
        'source: ${sourceType.serializedValue}, '
        'confidence: $confidence'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is IdentityObservation &&
            role == other.role &&
            value == other.value &&
            presence == other.presence &&
            sourceType == other.sourceType &&
            confidence == other.confidence &&
            observedAt == other.observedAt &&
            sourceReference == other.sourceReference;
  }

  @override
  int get hashCode {
    return Object.hash(
      role,
      value,
      presence,
      sourceType,
      confidence,
      observedAt,
      sourceReference,
    );
  }
}
