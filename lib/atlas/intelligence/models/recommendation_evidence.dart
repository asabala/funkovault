import 'package:flutter/foundation.dart';

@immutable
class RecommendationEvidence {
  const RecommendationEvidence({
    required this.id,
    required this.label,
    required this.description,
    this.value,
    this.source,
    this.metadata = const <String, Object?>{},
  });

  final String id;
  final String label;
  final String description;

  /// Optional structured value supporting this evidence.
  ///
  /// Examples:
  /// - 14
  /// - 0.92
  /// - 125.50
  /// - 'Disney'
  final Object? value;

  /// Identifies where the evidence came from.
  ///
  /// Examples:
  /// - collector_dna
  /// - vault_health
  /// - duplicate_review
  /// - query_preview
  final String? source;

  /// Additional structured information that other Atlas systems may use.
  ///
  /// This keeps the model expandable without forcing UI-specific fields
  /// into the core intelligence contract.
  final Map<String, Object?> metadata;

  RecommendationEvidence copyWith({
    String? id,
    String? label,
    String? description,
    Object? value,
    bool clearValue = false,
    String? source,
    bool clearSource = false,
    Map<String, Object?>? metadata,
  }) {
    return RecommendationEvidence(
      id: id ?? this.id,
      label: label ?? this.label,
      description: description ?? this.description,
      value: clearValue ? null : value ?? this.value,
      source: clearSource ? null : source ?? this.source,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is RecommendationEvidence &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            label == other.label &&
            description == other.description &&
            value == other.value &&
            source == other.source &&
            mapEquals(metadata, other.metadata);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      label,
      description,
      value,
      source,
      Object.hashAll(
        metadata.entries.map(
              (entry) => Object.hash(entry.key, entry.value),
        ),
      ),
    );
  }

  @override
  String toString() {
    return 'RecommendationEvidence('
        'id: $id, '
        'label: $label, '
        'description: $description, '
        'value: $value, '
        'source: $source'
        ')';
  }
}