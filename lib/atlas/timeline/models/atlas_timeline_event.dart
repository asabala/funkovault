enum AtlasTimelineEventType {
  addedToVault,
  valueUpdated,
  purchased,
  sold,
  traded,
  photoAdded,
  noteAdded,
  signatureAdded,
  convention,
  collectorMoment,
  displayLocationChanged,
  itemConditionChanged,
  boxConditionChanged,
  stickerChanged,
  variantChanged,
  protectorAdded,
  aiInsight,
  custom,
}

extension AtlasTimelineEventTypeExtension on AtlasTimelineEventType {
  String get storageKey {
    switch (this) {
      case AtlasTimelineEventType.addedToVault:
        return 'added_to_vault';

      case AtlasTimelineEventType.valueUpdated:
        return 'value_updated';

      case AtlasTimelineEventType.purchased:
        return 'purchased';

      case AtlasTimelineEventType.sold:
        return 'sold';

      case AtlasTimelineEventType.traded:
        return 'traded';

      case AtlasTimelineEventType.photoAdded:
        return 'photo_added';

      case AtlasTimelineEventType.noteAdded:
        return 'note_added';

      case AtlasTimelineEventType.signatureAdded:
        return 'signature_added';

      case AtlasTimelineEventType.convention:
        return 'convention';

      case AtlasTimelineEventType.collectorMoment:
        return 'collector_moment';

      case AtlasTimelineEventType.displayLocationChanged:
        return 'display_location_changed';

      case AtlasTimelineEventType.itemConditionChanged:
        return 'item_condition_changed';

      case AtlasTimelineEventType.boxConditionChanged:
        return 'box_condition_changed';

      case AtlasTimelineEventType.stickerChanged:
        return 'sticker_changed';

      case AtlasTimelineEventType.variantChanged:
        return 'variant_changed';

      case AtlasTimelineEventType.protectorAdded:
        return 'protector_added';

      case AtlasTimelineEventType.aiInsight:
        return 'ai_insight';

      case AtlasTimelineEventType.custom:
        return 'custom';
    }
  }

  String get label {
    switch (this) {
      case AtlasTimelineEventType.addedToVault:
        return 'Added to Vault';

      case AtlasTimelineEventType.valueUpdated:
        return 'Value Updated';

      case AtlasTimelineEventType.purchased:
        return 'Purchased';

      case AtlasTimelineEventType.sold:
        return 'Sold';

      case AtlasTimelineEventType.traded:
        return 'Traded';

      case AtlasTimelineEventType.photoAdded:
        return 'Photo Added';

      case AtlasTimelineEventType.noteAdded:
        return 'Note Added';

      case AtlasTimelineEventType.signatureAdded:
        return 'Signature Added';

      case AtlasTimelineEventType.convention:
        return 'Convention';

      case AtlasTimelineEventType.collectorMoment:
        return 'Collector Moment';

      case AtlasTimelineEventType.displayLocationChanged:
        return 'Display Location Changed';

      case AtlasTimelineEventType.itemConditionChanged:
        return 'Item Condition Changed';

      case AtlasTimelineEventType.boxConditionChanged:
        return 'Box Condition Changed';

      case AtlasTimelineEventType.stickerChanged:
        return 'Sticker Changed';

      case AtlasTimelineEventType.variantChanged:
        return 'Variant Changed';

      case AtlasTimelineEventType.protectorAdded:
        return 'Protector Added';

      case AtlasTimelineEventType.aiInsight:
        return 'Atlas Insight';

      case AtlasTimelineEventType.custom:
        return 'Custom Event';
    }
  }

  static AtlasTimelineEventType fromStorageKey(dynamic rawValue) {
    final normalized = rawValue
        ?.toString()
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');

    for (final type in AtlasTimelineEventType.values) {
      if (type.storageKey == normalized) {
        return type;
      }
    }

    return AtlasTimelineEventType.custom;
  }
}

class AtlasTimelineEvent {
  const AtlasTimelineEvent({
    required this.id,
    required this.popId,
    required this.type,
    required this.occurredAt,
    required this.title,
    this.description = '',
    this.metadata = const <String, dynamic>{},
    this.createdBy = manualCreatedBy,
    this.createdAt,
  });

  static const String manualCreatedBy = 'manual';
  static const String systemCreatedBy = 'system';
  static const String importCreatedBy = 'import';
  static const String atlasAiCreatedBy = 'atlas_ai';

  /// Unique identifier for this timeline event.
  final String id;

  /// Identifier of the collectible associated with this event.
  final String popId;

  /// Machine-readable category describing what happened.
  final AtlasTimelineEventType type;

  /// Date and time the event actually occurred.
  final DateTime occurredAt;

  /// Collector-facing event title.
  final String title;

  /// Optional explanation, note, or story attached to the event.
  final String description;

  /// Structured event-specific information.
  ///
  /// Examples:
  ///
  /// Value update:
  /// {
  ///   "previousValue": 20.00,
  ///   "newValue": 32.00,
  ///   "source": "manual"
  /// }
  ///
  /// Purchase:
  /// {
  ///   "pricePaid": 14.99,
  ///   "store": "Target"
  /// }
  ///
  /// Convention:
  /// {
  ///   "conventionName": "SDCC 2026",
  ///   "location": "San Diego"
  /// }
  final Map<String, dynamic> metadata;

  /// Identifies whether the event came from the collector, Atlas, an import,
  /// or another approved workflow.
  final String createdBy;

  /// Date and time this record was created in Atlas.
  ///
  /// This can differ from [occurredAt] when a collector adds an older memory.
  final DateTime? createdAt;

  bool get hasDescription => description.trim().isNotEmpty;

  bool get hasMetadata => metadata.isNotEmpty;

  bool get wasCreatedByAtlasAi => createdBy == atlasAiCreatedBy;

  factory AtlasTimelineEvent.fromJson(Map<String, dynamic> json) {
    final occurredAt = _readDateTime(json['occurredAt'] ?? json['timestamp']);

    return AtlasTimelineEvent(
      id: json['id']?.toString() ?? '',
      popId: json['popId']?.toString() ?? '',
      type: AtlasTimelineEventTypeExtension.fromStorageKey(
        json['type'] ?? json['eventType'],
      ),
      occurredAt: occurredAt,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      metadata: _readMetadata(json['metadata']),
      createdBy: _readCreatedBy(json['createdBy']),
      createdAt: _readNullableDateTime(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'popId': popId,
      'type': type.storageKey,
      'occurredAt': occurredAt.toIso8601String(),
      'title': title,
      'description': description,
      'metadata': Map<String, dynamic>.from(metadata),
      'createdBy': createdBy,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  AtlasTimelineEvent copyWith({
    String? id,
    String? popId,
    AtlasTimelineEventType? type,
    DateTime? occurredAt,
    String? title,
    String? description,
    Map<String, dynamic>? metadata,
    String? createdBy,
    DateTime? createdAt,
    bool clearCreatedAt = false,
  }) {
    return AtlasTimelineEvent(
      id: id ?? this.id,
      popId: popId ?? this.popId,
      type: type ?? this.type,
      occurredAt: occurredAt ?? this.occurredAt,
      title: title ?? this.title,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
      createdBy: createdBy ?? this.createdBy,
      createdAt: clearCreatedAt ? null : createdAt ?? this.createdAt,
    );
  }

  static Map<String, dynamic> _readMetadata(dynamic rawMetadata) {
    if (rawMetadata is Map) {
      return Map<String, dynamic>.unmodifiable(
        Map<String, dynamic>.from(rawMetadata),
      );
    }

    return const <String, dynamic>{};
  }

  static DateTime _readDateTime(dynamic rawValue) {
    return DateTime.tryParse(rawValue?.toString().trim() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  static DateTime? _readNullableDateTime(dynamic rawValue) {
    final value = rawValue?.toString().trim() ?? '';

    if (value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }

  static String _readCreatedBy(dynamic rawValue) {
    final normalized =
        rawValue?.toString().trim().toLowerCase().replaceAll(' ', '_') ?? '';

    return normalized.isEmpty ? manualCreatedBy : normalized;
  }
}
