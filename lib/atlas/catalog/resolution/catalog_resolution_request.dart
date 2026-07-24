// Immutable input used by catalog resolution services.
//
// This request contains identity information only. It does not know how
// products are stored, ranked, or resolved.
final class CatalogResolutionRequest {
  CatalogResolutionRequest({
    required String displayName,
    String? categoryCode,
    String? brand,
    String? productLine,
    String? series,
    String? characterName,
    String? productNumber,
    String? variantName,
    Iterable<String> barcodes = const <String>[],
    double sourceConfidence = 0.0,
    Map<String, Object?> attributes =
    const <String, Object?>{},
  })  : displayName = _requireText(
    displayName,
    'displayName',
  ),
        categoryCode = _normalizeOptionalCode(
          categoryCode,
        ),
        brand = _normalizeOptionalText(brand),
        productLine = _normalizeOptionalText(
          productLine,
        ),
        series = _normalizeOptionalText(series),
        characterName = _normalizeOptionalText(
          characterName,
        ),
        productNumber = _normalizeOptionalText(
          productNumber,
        ),
        variantName = _normalizeOptionalText(
          variantName,
        ),
        barcodes = List.unmodifiable(
          _normalizeBarcodes(barcodes),
        ),
        sourceConfidence = _normalizeConfidence(
          sourceConfidence,
        ),
        attributes = Map.unmodifiable(
          Map<String, Object?>.from(attributes),
        );

  final String displayName;

  final String? categoryCode;

  final String? brand;

  final String? productLine;

  final String? series;

  final String? characterName;

  final String? productNumber;

  final String? variantName;

  final List<String> barcodes;

  final double sourceConfidence;

  final Map<String, Object?> attributes;

  bool get hasBarcode {
    return barcodes.isNotEmpty;
  }

  bool get hasProductNumber {
    return productNumber != null;
  }

  bool get hasVariant {
    return variantName != null;
  }

  bool get hasCategory {
    return categoryCode != null;
  }

  T? attribute<T>(
      String key,
      ) {
    final Object? value = attributes[key];

    if (value is T) {
      return value;
    }

    return null;
  }

  bool hasAttribute(
      String key,
      ) {
    return attributes.containsKey(key);
  }

  static String _requireText(
      String value,
      String parameterName,
      ) {
    final String normalized = value.trim();

    if (normalized.isEmpty) {
      throw ArgumentError.value(
        value,
        parameterName,
        '$parameterName cannot be empty.',
      );
    }

    return normalized;
  }

  static String? _normalizeOptionalText(
      String? value,
      ) {
    final String normalized = value?.trim() ?? '';

    if (normalized.isEmpty) {
      return null;
    }

    return normalized;
  }

  static String? _normalizeOptionalCode(
      String? value,
      ) {
    final String normalized =
        value?.trim().toUpperCase() ?? '';

    if (normalized.isEmpty) {
      return null;
    }

    return normalized;
  }

  static List<String> _normalizeBarcodes(
      Iterable<String> values,
      ) {
    final Set<String> normalized = <String>{};

    for (final String value in values) {
      final String barcode = value.replaceAll(
        RegExp(r'[^0-9A-Za-z]'),
        '',
      );

      if (barcode.isNotEmpty) {
        normalized.add(barcode);
      }
    }

    return normalized.toList(
      growable: false,
    );
  }

  static double _normalizeConfidence(
      double value,
      ) {
    return value.clamp(
      0.0,
      1.0,
    );
  }
}