import 'normalized_image_region.dart';

enum AtlasInspectionArea {
  frontBox,
  windowSticker,
  bottomStamp,
  packagingCopyright,
  autograph,
  coa,
}

enum AtlasEvidenceCategory {
  variantSticker,
  productionStamp,
  macroPackaging,
  autographCoa,
}

enum AtlasSignalSeverity { info, advisory, moderate, critical }

enum AtlasSignalDisposition { supporting, observational, discrepancy }

final class AtlasVisualEvidenceObservation {
  static const int currentSchemaVersion = 1;

  AtlasVisualEvidenceObservation({
    required String observationId,
    required String sourceEngineId,
    required this.area,
    required this.category,
    required String label,
    required String observedValue,
    required double confidence,
    String? scanImageId,
    this.cropRegion,
    Map<String, Object?> attributes = const <String, Object?>{},
    DateTime? observedAt,
  }) : observationId = _requireText(observationId, 'observationId'),
       sourceEngineId = _requireText(sourceEngineId, 'sourceEngineId'),
       label = _requireText(label, 'label'),
       observedValue = observedValue.trim(),
       confidence = _normalizeConfidence(confidence),
       scanImageId = _optionalText(scanImageId),
       attributes = _deepFreezeMap(attributes),
       observedAt = (observedAt ?? DateTime.now()).toUtc();

  final String observationId;
  final String sourceEngineId;
  final AtlasInspectionArea area;
  final AtlasEvidenceCategory category;
  final String label;
  final String observedValue;
  final double confidence;
  final String? scanImageId;
  final NormalizedImageRegion? cropRegion;
  final Map<String, Object?> attributes;
  final DateTime observedAt;

  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': currentSchemaVersion,
    'observationId': observationId,
    'sourceEngineId': sourceEngineId,
    'area': area.name,
    'category': category.name,
    'label': label,
    'observedValue': observedValue,
    'confidence': confidence,
    'scanImageId': scanImageId,
    'cropRegion': cropRegion?.toJson(),
    'attributes': attributes,
    'observedAt': observedAt.toIso8601String(),
  };

  static AtlasVisualEvidenceObservation? fromJson(Map<String, Object?> json) {
    try {
      if (json['schemaVersion'] != currentSchemaVersion) {
        return null;
      }

      final AtlasInspectionArea? area = _parseArea(json['area']);
      final AtlasEvidenceCategory? category = _parseCategory(json['category']);
      if (area == null || category == null) {
        return null;
      }

      NormalizedImageRegion? crop;
      final Object? rawCrop = json['cropRegion'];
      if (rawCrop != null) {
        if (rawCrop is! Map) {
          return null;
        }
        crop = NormalizedImageRegion.fromJson(
          Map<String, Object?>.from(rawCrop),
        );
        if (crop == null) {
          return null;
        }
      }

      final Object? rawAttributes = json['attributes'];
      final Map<String, Object?> attributes = rawAttributes is Map
          ? Map<String, Object?>.from(rawAttributes)
          : const <String, Object?>{};

      return AtlasVisualEvidenceObservation(
        observationId: json['observationId'] as String,
        sourceEngineId: json['sourceEngineId'] as String,
        area: area,
        category: category,
        label: json['label'] as String,
        observedValue: json['observedValue'] as String,
        confidence: (json['confidence'] as num).toDouble(),
        scanImageId: json['scanImageId'] as String?,
        cropRegion: crop,
        attributes: attributes,
        observedAt: DateTime.parse(json['observedAt'] as String).toUtc(),
      );
    } catch (_) {
      return null;
    }
  }

  static AtlasInspectionArea? _parseArea(Object? value) {
    if (value is! String) return null;
    for (final AtlasInspectionArea area in AtlasInspectionArea.values) {
      if (area.name == value) return area;
    }
    return null;
  }

  static AtlasEvidenceCategory? _parseCategory(Object? value) {
    if (value is! String) return null;
    for (final AtlasEvidenceCategory category in AtlasEvidenceCategory.values) {
      if (category.name == value) return category;
    }
    return null;
  }
}

final class AtlasEvaluatedAuthenticitySignal {
  AtlasEvaluatedAuthenticitySignal({
    required String id,
    required this.area,
    required this.category,
    required this.severity,
    required this.disposition,
    required double confidence,
    required double baseWeight,
    required String rationale,
  }) : id = _requireText(id, 'id'),
       confidence = _normalizeConfidence(confidence),
       baseWeight = _normalizeWeight(baseWeight),
       rationale = _requireText(rationale, 'rationale');

  final String id;
  final AtlasInspectionArea area;
  final AtlasEvidenceCategory category;
  final AtlasSignalSeverity severity;
  final AtlasSignalDisposition disposition;
  final double confidence;
  final double baseWeight;
  final String rationale;

  bool get isDiscrepancy => disposition == AtlasSignalDisposition.discrepancy;
  bool get isSupporting => disposition == AtlasSignalDisposition.supporting;
  double get weightedConcern => isDiscrepancy ? baseWeight * confidence : 0.0;
}

String _requireText(String value, String fieldName) {
  final String normalized = value.trim();
  if (normalized.isEmpty) {
    throw ArgumentError.value(value, fieldName, '$fieldName cannot be empty.');
  }
  return normalized;
}

String? _optionalText(String? value) {
  final String normalized = value?.trim() ?? '';
  return normalized.isEmpty ? null : normalized;
}

double _normalizeConfidence(double value) {
  if (!value.isFinite || value < 0.0 || value > 1.0) {
    throw ArgumentError.value(
      value,
      'confidence',
      'Confidence must be between 0.0 and 1.0.',
    );
  }
  return value;
}

double _normalizeWeight(double value) {
  if (!value.isFinite || value < 0.0) {
    throw ArgumentError.value(
      value,
      'baseWeight',
      'baseWeight must be finite and non-negative.',
    );
  }
  return value;
}

Map<String, Object?> _deepFreezeMap(Map<String, Object?> values) {
  final Map<String, Object?> copy = <String, Object?>{};
  for (final MapEntry<String, Object?> entry in values.entries) {
    copy[entry.key] = _deepFreeze(entry.value);
  }
  return Map<String, Object?>.unmodifiable(copy);
}

Object? _deepFreeze(Object? value) {
  if (value is Map) {
    final Map<String, Object?> mapped = <String, Object?>{};
    for (final MapEntry<Object?, Object?> entry in value.entries) {
      mapped[entry.key.toString()] = _deepFreeze(entry.value);
    }
    return Map<String, Object?>.unmodifiable(mapped);
  }
  if (value is List) {
    return List<Object?>.unmodifiable(value.map<Object?>(_deepFreeze));
  }
  if (value is Set) {
    return Set<Object?>.unmodifiable(value.map<Object?>(_deepFreeze));
  }
  return value;
}
