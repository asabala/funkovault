import 'models/atlas_production_stamp.dart';

abstract final class AtlasProductionStampParser {
  static AtlasProductionStamp parse(String input) {
    final raw = input.trim();
    final normalized = raw.toUpperCase().replaceAll(RegExp(r'\s+'), ' ');
    final match = RegExp(
      r'\b(JJL|FAC)\b[\s:_-]*([A-Z0-9-]+)?',
    ).firstMatch(normalized);
    if (match == null) {
      return AtlasProductionStamp(
        rawInput: raw,
        factoryCode: '',
        productionDate: null,
        itemBatch: raw.isEmpty ? null : normalized,
        isValid: false,
      );
    }

    final factory = match.group(1)!;
    final batch = match.group(2)?.trim();
    return AtlasProductionStamp(
      rawInput: raw,
      factoryCode: factory,
      productionDate: _dateFrom(batch),
      itemBatch: batch?.isEmpty == true ? null : batch,
      isValid: batch != null && batch.isNotEmpty,
    );
  }

  static DateTime? _dateFrom(String? batch) {
    final digits = batch?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
    if (digits.length < 6) return null;
    final value = digits.substring(0, 6);
    final year = 2000 + int.parse(value.substring(0, 2));
    final month = int.parse(value.substring(2, 4));
    final day = int.parse(value.substring(4, 6));
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    final date = DateTime.utc(year, month, day);
    return date.month == month && date.day == day ? date : null;
  }
}
