// Represents one provider-supplied collectible knowledge record.
//
// A knowledge record preserves source information without requiring the
// provider to understand Atlas identity profiles or identity policies.
class KnowledgeRecord {
  KnowledgeRecord({
    required this.recordId,
    required this.sourceId,
    this.category,
    this.title,
    this.externalId,
    Map<String, String> identifiers = const <String, String>{},
    Map<String, Object?> attributes = const <String, Object?>{},
    Map<String, String> metadata = const <String, String>{},
    this.confidence = 1.0,
  }) : assert(recordId.trim().isNotEmpty, 'Record ID must not be empty.'),
       assert(sourceId.trim().isNotEmpty, 'Source ID must not be empty.'),
       assert(
         confidence >= 0.0 && confidence <= 1.0,
         'Confidence must be between 0.0 and 1.0.',
       ),
       identifiers = Map<String, String>.unmodifiable(identifiers),
       attributes = Map<String, Object?>.unmodifiable(attributes),
       metadata = Map<String, String>.unmodifiable(metadata);

  // Stable identifier for this record within its source.
  final String recordId;

  // Provider or dataset that supplied the record.
  final String sourceId;

  // Optional collectible category.
  final String? category;

  // Human-readable item title.
  final String? title;

  // Native identifier used by the external source.
  final String? externalId;

  // Structured identifiers such as UPC, EAN, catalog number, or SKU.
  final Map<String, String> identifiers;

  // Raw or normalized collectible attributes supplied by the provider.
  final Map<String, Object?> attributes;

  // Source context that should not directly define collectible identity.
  final Map<String, String> metadata;

  // Confidence assigned to this individual source record.
  final double confidence;

  bool get hasCategory => _hasValue(category);

  bool get hasTitle => _hasValue(title);

  bool get hasExternalId => _hasValue(externalId);

  bool get hasIdentifiers => identifiers.isNotEmpty;

  bool get hasAttributes => attributes.isNotEmpty;

  bool get hasMetadata => metadata.isNotEmpty;

  String? identifier(String key) {
    return identifiers[key];
  }

  Object? attribute(String key) {
    return attributes[key];
  }

  String? stringAttribute(String key) {
    final Object? value = attributes[key];

    if (value == null) {
      return null;
    }

    return value.toString();
  }

  bool containsIdentifier(String key) {
    return identifiers.containsKey(key);
  }

  bool containsAttribute(String key) {
    return attributes.containsKey(key);
  }

  KnowledgeRecord copyWith({
    String? recordId,
    String? sourceId,
    String? category,
    String? title,
    String? externalId,
    Map<String, String>? identifiers,
    Map<String, Object?>? attributes,
    Map<String, String>? metadata,
    double? confidence,
  }) {
    return KnowledgeRecord(
      recordId: recordId ?? this.recordId,
      sourceId: sourceId ?? this.sourceId,
      category: category ?? this.category,
      title: title ?? this.title,
      externalId: externalId ?? this.externalId,
      identifiers: identifiers ?? this.identifiers,
      attributes: attributes ?? this.attributes,
      metadata: metadata ?? this.metadata,
      confidence: confidence ?? this.confidence,
    );
  }

  bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  @override
  String toString() {
    return 'KnowledgeRecord('
        'recordId: $recordId, '
        'sourceId: $sourceId, '
        'category: $category, '
        'title: $title, '
        'identifiers: ${identifiers.length}, '
        'attributes: ${attributes.length}, '
        'confidence: $confidence'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is KnowledgeRecord &&
            recordId == other.recordId &&
            sourceId == other.sourceId &&
            category == other.category &&
            title == other.title &&
            externalId == other.externalId &&
            confidence == other.confidence &&
            _mapsEqual(identifiers, other.identifiers) &&
            _mapsEqual(attributes, other.attributes) &&
            _mapsEqual(metadata, other.metadata);
  }

  @override
  int get hashCode {
    return Object.hash(
      recordId,
      sourceId,
      category,
      title,
      externalId,
      Object.hashAll(
        identifiers.entries.map((MapEntry<String, String> entry) {
          return Object.hash(entry.key, entry.value);
        }),
      ),
      Object.hashAll(
        attributes.entries.map((MapEntry<String, Object?> entry) {
          return Object.hash(entry.key, entry.value);
        }),
      ),
      Object.hashAll(
        metadata.entries.map((MapEntry<String, String> entry) {
          return Object.hash(entry.key, entry.value);
        }),
      ),
      confidence,
    );
  }

  static bool _mapsEqual<K, V>(Map<K, V> first, Map<K, V> second) {
    if (identical(first, second)) {
      return true;
    }

    if (first.length != second.length) {
      return false;
    }

    for (final MapEntry<K, V> entry in first.entries) {
      if (!second.containsKey(entry.key) || second[entry.key] != entry.value) {
        return false;
      }
    }

    return true;
  }
}
