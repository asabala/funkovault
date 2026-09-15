class ValueHistoryEntry {
  const ValueHistoryEntry({
    required this.value,
    required this.recordedAt,
    this.source = manualSource,
  });

  static const String manualSource = 'manual';
  static const String hobbyDbImportSource = 'hobbydb_import';
  static const String atlasCatalogSource = 'atlas_catalog';
  static const String catalogRefreshSource = 'catalog_refresh';
  static const String externalProviderSource = 'external_provider';
  static const String legacyValueSource = 'legacy_value';

  /// Estimated market value recorded at this point in time.
  final double value;

  /// ISO-8601 timestamp for when this value was recorded.
  final DateTime recordedAt;

  /// Machine-readable identifier describing where the value came from.
  ///
  /// Examples:
  /// - manual
  /// - hobbydb_import
  /// - atlas_catalog
  /// - catalog_refresh
  /// - external_provider
  /// - legacy_value
  final String source;

  factory ValueHistoryEntry.fromJson(Map<String, dynamic> json) {
    return ValueHistoryEntry(
      value: _readDouble(json['value']),
      recordedAt: _readDateTime(json['recordedAt']),
      source: _readSource(json['source']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'value': value,
      'recordedAt': recordedAt.toIso8601String(),
      'source': source,
    };
  }

  ValueHistoryEntry copyWith({
    double? value,
    DateTime? recordedAt,
    String? source,
  }) {
    return ValueHistoryEntry(
      value: value ?? this.value,
      recordedAt: recordedAt ?? this.recordedAt,
      source: source ?? this.source,
    );
  }

  String get sourceLabel {
    switch (source) {
      case hobbyDbImportSource:
        return '📥 HobbyDB Import';

      case atlasCatalogSource:
        return '🗃️ Atlas Catalog';

      case catalogRefreshSource:
        return '🔄 Catalog Refresh';

      case externalProviderSource:
        return '🌐 External Provider';

      case legacyValueSource:
        return '🕰️ Existing Value';

      case manualSource:
      default:
        return '✍️ Manual';
    }
  }

  static double _readDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString().trim() ?? '') ?? 0;
  }

  static DateTime _readDateTime(dynamic value) {
    final parsed = DateTime.tryParse(value?.toString().trim() ?? '');

    return parsed ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  static String _readSource(dynamic value) {
    final normalized = value?.toString().trim().toLowerCase() ?? '';

    return normalized.isEmpty ? manualSource : normalized;
  }
}
