import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String boxName = 'funko_vault';

  static Future<Box> openBox() async {
    return await Hive.openBox(boxName);
  }

  static Future<void> saveData(String key, Map<String, dynamic> data) async {
    final box = Hive.box(boxName);

    await box.put(key, jsonEncode(data));
  }

  static Map<String, dynamic>? loadData(String key) {
    final box = Hive.box(boxName);

    final value = box.get(key);

    if (value == null) {
      return null;
    }

    return jsonDecode(value);
  }
}
