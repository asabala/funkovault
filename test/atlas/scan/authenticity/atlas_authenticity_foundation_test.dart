import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/scan/authenticity/models/atlas_authenticity_evidence.dart';
import 'package:funkovault2/atlas/scan/authenticity/models/normalized_image_region.dart';

void main() {
  test('normalized image region rejects invalid release-build values', () {
    expect(
      () => NormalizedImageRegion(
        left: double.nan,
        top: 0.0,
        width: 0.5,
        height: 0.5,
      ),
      throwsArgumentError,
    );
    expect(
      () => NormalizedImageRegion(left: 0.8, top: 0.0, width: 0.3, height: 0.5),
      throwsArgumentError,
    );
  });

  test('visual observation round trips without image bytes', () {
    final original = AtlasVisualEvidenceObservation(
      observationId: 'obs-1',
      sourceEngineId: 'atlas.test',
      area: AtlasInspectionArea.windowSticker,
      category: AtlasEvidenceCategory.variantSticker,
      label: 'Sticker',
      observedValue: 'Chase',
      confidence: 0.94,
      scanImageId: 'scan-image-1',
      cropRegion: NormalizedImageRegion(
        left: 0.1,
        top: 0.2,
        width: 0.3,
        height: 0.4,
      ),
      attributes: <String, Object?>{
        'nested': <String>['a', 'b'],
      },
      observedAt: DateTime.parse('2026-09-03T16:00:00.000Z'),
    );

    final json = original.toJson();
    expect(json['schemaVersion'], 1);
    expect(json.containsKey('imageBytes'), isFalse);

    final restored = AtlasVisualEvidenceObservation.fromJson(json);
    expect(restored, isNotNull);
    expect(restored!.observationId, original.observationId);
    expect(restored.cropRegion, original.cropRegion);
    expect(restored.observedAt, original.observedAt);
    expect(restored.observedAt.isUtc, isTrue);
    expect(restored.scanImageId, 'scan-image-1');
  });

  test('visual observation attributes are deeply immutable', () {
    final observation = AtlasVisualEvidenceObservation(
      observationId: 'obs-immutable',
      sourceEngineId: 'atlas.test',
      area: AtlasInspectionArea.frontBox,
      category: AtlasEvidenceCategory.macroPackaging,
      label: 'Front',
      observedValue: 'Observed',
      confidence: 0.9,
      attributes: <String, Object?>{
        'items': <String>['one', 'two'],
        'nested': <String, Object?>{'value': 1},
      },
    );

    expect(() => observation.attributes['new'] = true, throwsUnsupportedError);
    expect(
      () => (observation.attributes['items'] as List<Object?>).add('three'),
      throwsUnsupportedError,
    );
    expect(
      () => (observation.attributes['nested'] as Map<String, Object?>)['x'] = 2,
      throwsUnsupportedError,
    );
  });

  test('unknown schema and enum values fail safely', () {
    final observation = AtlasVisualEvidenceObservation(
      observationId: 'obs-schema',
      sourceEngineId: 'atlas.test',
      area: AtlasInspectionArea.frontBox,
      category: AtlasEvidenceCategory.macroPackaging,
      label: 'Front',
      observedValue: 'Observed',
      confidence: 0.9,
    );

    final json = observation.toJson();
    expect(
      AtlasVisualEvidenceObservation.fromJson(
        Map<String, Object?>.from(json)..['schemaVersion'] = 2,
      ),
      isNull,
    );
    expect(
      AtlasVisualEvidenceObservation.fromJson(
        Map<String, Object?>.from(json)..['area'] = 'unknownArea',
      ),
      isNull,
    );
  });
}
