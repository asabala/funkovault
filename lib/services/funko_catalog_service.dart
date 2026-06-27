import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/funko_catalog_item.dart';

class FunkoCatalogService {
  static Future<List<FunkoCatalogItem>>
  loadCatalog() async {
    final jsonString =
    await rootBundle.loadString(
      'assets/data/funko_pop.json',
    );

    final List<dynamic> data =
    json.decode(jsonString);

    return data
        .map(
          (item) =>
          FunkoCatalogItem.fromJson(
            item,
          ),
    )
        .toList();
  }
}