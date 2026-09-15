import 'package:funkovault2/atlas/catalog/models/atlas_catalog_attribute_keys.dart';
import 'package:funkovault2/atlas/catalog/models/atlas_catalog_product.dart';
import 'package:funkovault2/atlas/identity/product/atlas_product_id.dart';

abstract final class PopVinylCatalogMapper {
  static AtlasCatalogProduct fromJson(Map<String, Object?> json) {
    final int productId = _requiredPositiveInt(
      json['productId'],
      fieldName: 'productId',
    );

    final String displayName = _requiredText(json['name'], fieldName: 'name');

    final String? printing = _optionalText(json['extPrinting']);

    final String? treatment = _optionalText(json['extTreatment']);

    return AtlasCatalogProduct(
      productId: AtlasProductId.funko(numericId: productId),
      displayName: displayName,
      categoryCode: 'FNK',
      brand: 'Funko',
      productLine: 'Pop! Vinyl',
      series: _optionalText(json['extSeries']),
      characterName: _characterNameFrom(displayName),
      productNumber: _optionalText(json['extNumber']),
      variantName: _variantNameFrom(printing: printing, treatment: treatment),
      barcodes: _barcodesFrom(json),
      attributes: _attributesFrom(
        json,
        printing: printing,
        treatment: treatment,
      ),
    );
  }

  static List<AtlasCatalogProduct> fromJsonList(Iterable<Object?> values) {
    return values
        .whereType<Map>()
        .map((Map value) => fromJson(Map<String, Object?>.from(value)))
        .toList(growable: false);
  }

  static List<String> _barcodesFrom(Map<String, Object?> json) {
    final List<String> barcodes = <String>[];

    final String? upc = _optionalText(json['extUPC']);

    final String? gtin = _optionalText(json['extGTIN']);

    if (upc != null) {
      barcodes.add(upc);
    }

    if (gtin != null) {
      barcodes.add(gtin);
    }

    return barcodes;
  }

  static Map<String, Object?> _attributesFrom(
    Map<String, Object?> json, {
    required String? printing,
    required String? treatment,
  }) {
    final Map<String, Object?> attributes = <String, Object?>{};

    _addText(attributes, AtlasCatalogAttributeKeys.source, 'TCGCSV');

    _addText(
      attributes,
      AtlasCatalogAttributeKeys.sourceProductId,
      json['productId'],
    );

    _addText(
      attributes,
      AtlasCatalogAttributeKeys.sourceCategoryId,
      json['categoryId'],
    );

    _addText(
      attributes,
      AtlasCatalogAttributeKeys.sourceGroupId,
      json['groupId'],
    );

    _addText(attributes, AtlasCatalogAttributeKeys.sourceUrl, json['url']);

    _addText(
      attributes,
      AtlasCatalogAttributeKeys.cleanName,
      json['cleanName'],
    );

    _addText(attributes, AtlasCatalogAttributeKeys.imageUrl, json['imageUrl']);

    _addInteger(
      attributes,
      AtlasCatalogAttributeKeys.imageCount,
      json['imageCount'],
    );

    _addText(
      attributes,
      AtlasCatalogAttributeKeys.modifiedOn,
      json['modifiedOn'],
    );

    _addText(attributes, AtlasCatalogAttributeKeys.rarity, json['extRarity']);

    _addText(
      attributes,
      AtlasCatalogAttributeKeys.description,
      json['extDescription'],
    );

    _addText(attributes, AtlasCatalogAttributeKeys.genre, json['extGenre']);

    _addText(attributes, AtlasCatalogAttributeKeys.model, json['extModel']);

    _addText(attributes, AtlasCatalogAttributeKeys.gtin, json['extGTIN']);

    _addText(attributes, AtlasCatalogAttributeKeys.upc, json['extUPC']);

    if (printing != null) {
      attributes[AtlasCatalogAttributeKeys.printing] = printing;
    }

    if (treatment != null) {
      attributes[AtlasCatalogAttributeKeys.treatment] = treatment;
    }

    _addText(
      attributes,
      AtlasCatalogAttributeKeys.subTypeName,
      json['subTypeName'],
    );

    _addDecimal(
      attributes,
      AtlasCatalogAttributeKeys.lowPrice,
      json['lowPrice'],
    );

    _addDecimal(
      attributes,
      AtlasCatalogAttributeKeys.midPrice,
      json['midPrice'],
    );

    _addDecimal(
      attributes,
      AtlasCatalogAttributeKeys.highPrice,
      json['highPrice'],
    );

    _addDecimal(
      attributes,
      AtlasCatalogAttributeKeys.marketPrice,
      json['marketPrice'],
    );

    _addDecimal(
      attributes,
      AtlasCatalogAttributeKeys.directLowPrice,
      json['directLowPrice'],
    );

    return attributes;
  }

  static String? _characterNameFrom(String displayName) {
    final List<String> segments = displayName
        .split(':')
        .map((String value) => value.trim())
        .where((String value) => value.isNotEmpty)
        .toList(growable: false);

    if (segments.length < 2) {
      return null;
    }

    return segments.last;
  }

  static String? _variantNameFrom({
    required String? printing,
    required String? treatment,
  }) {
    final List<String> values = <String>[?printing, ?treatment];

    if (values.isEmpty) {
      return null;
    }

    return values.join(' · ');
  }

  static void _addText(
    Map<String, Object?> attributes,
    String key,
    Object? value,
  ) {
    final String? normalized = _optionalText(value);

    if (normalized != null) {
      attributes[key] = normalized;
    }
  }

  static void _addInteger(
    Map<String, Object?> attributes,
    String key,
    Object? value,
  ) {
    final int? parsed = _optionalInt(value);

    if (parsed != null) {
      attributes[key] = parsed;
    }
  }

  static void _addDecimal(
    Map<String, Object?> attributes,
    String key,
    Object? value,
  ) {
    final double? parsed = _optionalDouble(value);

    if (parsed != null) {
      attributes[key] = parsed;
    }
  }

  static String _requiredText(Object? value, {required String fieldName}) {
    final String? normalized = _optionalText(value);

    if (normalized == null) {
      throw FormatException(
        'Pop Vinyl catalog field "$fieldName" is required.',
      );
    }

    return normalized;
  }

  static int _requiredPositiveInt(Object? value, {required String fieldName}) {
    final int? parsed = _optionalInt(value);

    if (parsed == null || parsed <= 0) {
      throw FormatException(
        'Pop Vinyl catalog field "$fieldName" must be a positive integer.',
      );
    }

    return parsed;
  }

  static String? _optionalText(Object? value) {
    if (value == null) {
      return null;
    }

    final String normalized = value.toString().trim();

    if (normalized.isEmpty) {
      return null;
    }

    return normalized;
  }

  static int? _optionalInt(Object? value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    final String? normalized = _optionalText(value);

    if (normalized == null) {
      return null;
    }

    return int.tryParse(normalized);
  }

  static double? _optionalDouble(Object? value) {
    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    final String? normalized = _optionalText(value);

    if (normalized == null) {
      return null;
    }

    return double.tryParse(normalized.replaceAll(RegExp(r'[^0-9.\-]'), ''));
  }
}
