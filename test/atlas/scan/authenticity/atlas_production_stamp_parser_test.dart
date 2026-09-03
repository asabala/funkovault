import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/scan/authenticity/atlas_production_stamp_parser.dart';

void main() {
  test('recognizes JJL date and batch evidence', () {
    final stamp = AtlasProductionStampParser.parse('JJL 240815');
    expect(stamp.factoryCode, 'JJL');
    expect(stamp.itemBatch, '240815');
    expect(stamp.productionDate, DateTime.utc(2024, 8, 15));
    expect(stamp.isValid, isTrue);
  });

  test('recognizes FAC batch without inventing a date', () {
    final stamp = AtlasProductionStampParser.parse('FAC-053571-19029');
    expect(stamp.factoryCode, 'FAC');
    expect(stamp.itemBatch, '053571-19029');
    expect(stamp.productionDate, isNull);
    expect(stamp.isValid, isTrue);
  });

  test('preserves unknown stamp as invalid evidence', () {
    final stamp = AtlasProductionStampParser.parse('unknown 123');
    expect(stamp.rawInput, 'unknown 123');
    expect(stamp.factoryCode, isEmpty);
    expect(stamp.isValid, isFalse);
  });
}
