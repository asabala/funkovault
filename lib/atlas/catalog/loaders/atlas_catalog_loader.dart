import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:funkovault2/atlas/catalog/mappers/pop_vinyl_catalog_mapper.dart';
import 'package:funkovault2/atlas/catalog/models/atlas_catalog_product.dart';

abstract final class AtlasCatalogLoader {
  static const String popVinylAssetPath = 'assets/data/pop_vinyl_products.json';

  static Future<List<AtlasCatalogProduct>> loadPopVinylCatalog() async {
    final List<Map<String, Object?>> records = await loadJsonRecords(
      assetPath: popVinylAssetPath,
    );

    return records.map(PopVinylCatalogMapper.fromJson).toList(growable: false);
  }

  static Future<List<Map<String, Object?>>> loadJsonRecords({
    required String assetPath,
  }) async {
    final String jsonText;

    try {
      jsonText = await rootBundle.loadString(assetPath);
    } on FlutterError catch (error) {
      throw AtlasCatalogLoadException(
        assetPath: assetPath,
        message: 'Unable to load the catalog asset.',
        cause: error,
      );
    }

    final Object? decodedJson;

    try {
      decodedJson = jsonDecode(jsonText);
    } on FormatException catch (error) {
      throw AtlasCatalogLoadException(
        assetPath: assetPath,
        message: 'The catalog asset contains invalid JSON.',
        cause: error,
      );
    }

    if (decodedJson is! List<Object?>) {
      throw AtlasCatalogLoadException(
        assetPath: assetPath,
        message: 'The catalog JSON must contain a top-level list.',
      );
    }

    final List<Map<String, Object?>> records = <Map<String, Object?>>[];

    for (int index = 0; index < decodedJson.length; index++) {
      final Object? record = decodedJson[index];

      if (record is! Map) {
        throw AtlasCatalogLoadException(
          assetPath: assetPath,
          message:
              'Catalog record at index $index '
              'must be a JSON object.',
        );
      }

      try {
        records.add(Map<String, Object?>.from(record));
      } on TypeError catch (error) {
        throw AtlasCatalogLoadException(
          assetPath: assetPath,
          message:
              'Catalog record at index $index '
              'contains an invalid object key.',
          cause: error,
        );
      }
    }

    return List<Map<String, Object?>>.unmodifiable(records);
  }
}

final class AtlasCatalogLoadException implements Exception {
  const AtlasCatalogLoadException({
    required this.assetPath,
    required this.message,
    this.cause,
  });

  final String assetPath;

  final String message;

  final Object? cause;

  @override
  String toString() {
    final String causeText = switch (cause) {
      null => '',
      final Object value => ' Cause: $value',
    };

    return 'AtlasCatalogLoadException: $message '
        'Asset: $assetPath.$causeText';
  }
}
