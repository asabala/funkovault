// Shared utility functions used by Atlas intelligence engines.
//
// EngineSupport contains deterministic, domain-neutral helpers. Business
// rules such as barcode validation, OCR interpretation, and identity scoring
// remain inside their respective engines.
abstract final class EngineSupport {
  // Normalizes an engine confidence value to the supported 0–1 range.
  //
  // NaN and infinite values use the supplied fallback.
  static double normalizeConfidence(double value, {double fallback = 0.0}) {
    final double normalizedFallback = _normalizeFallback(fallback);

    if (value.isNaN || value.isInfinite) {
      return normalizedFallback;
    }

    return value.clamp(0.0, 1.0);
  }

  // Creates a stable namespaced contribution ID.
  //
  // Each segment is trimmed and URI encoded so values containing spaces,
  // slashes, URLs, or other special characters cannot break the ID format.
  static String buildContributionId({
    required String namespace,
    required Iterable<Object?> segments,
  }) {
    final String normalizedNamespace = requireIdentifier(
      namespace,
      fieldName: 'namespace',
    );

    final List<String> normalizedSegments = segments
        .whereType<Object>()
        .map((Object segment) {
          return segment.toString().trim();
        })
        .where((String segment) {
          return segment.isNotEmpty;
        })
        .map(Uri.encodeComponent)
        .toList(growable: false);

    if (normalizedSegments.isEmpty) {
      throw ArgumentError.value(
        segments,
        'segments',
        'At least one contribution ID segment is required.',
      );
    }

    return <String>[normalizedNamespace, ...normalizedSegments].join('.');
  }

  // Requires a non-empty identifier and returns its trimmed value.
  static String requireIdentifier(String value, {required String fieldName}) {
    final String normalized = value.trim();

    if (normalized.isEmpty) {
      throw ArgumentError.value(
        value,
        fieldName,
        '$fieldName cannot be empty.',
      );
    }

    return normalized;
  }

  // Returns null when a message contains only whitespace.
  static String? normalizeOptionalMessage(String? value) {
    final String? normalized = value?.trim();

    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    return normalized;
  }

  static double _normalizeFallback(double fallback) {
    if (fallback.isNaN || fallback.isInfinite) {
      return 0.0;
    }

    return fallback.clamp(0.0, 1.0);
  }
}
