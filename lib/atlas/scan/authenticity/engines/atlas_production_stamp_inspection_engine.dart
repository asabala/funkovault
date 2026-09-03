import '../atlas_production_stamp_parser.dart';
import '../models/atlas_authenticity_evidence.dart';
import '../models/atlas_visual_inspection.dart';

final class AtlasProductionStampInspectionEngine {
  const AtlasProductionStampInspectionEngine();

  static const String id = 'atlas.scan.authenticity.production-stamp';

  List<AtlasVisualEvidenceObservation> inspect({
    required String sessionId,
    required AtlasVisualInspection inspection,
    required DateTime observedAt,
  }) {
    final String raw = inspection.productionStampText.trim();
    if (raw.isEmpty) {
      return const <AtlasVisualEvidenceObservation>[];
    }

    final stamp = AtlasProductionStampParser.parse(raw);
    final Map<String, Object?> attributes = <String, Object?>{
      'recognizedFormat': stamp.isValid,
      if (stamp.factoryCode.trim().isNotEmpty)
        'factoryPrefix': stamp.factoryCode.trim().toUpperCase(),
      if (stamp.itemBatch != null && stamp.itemBatch!.trim().isNotEmpty)
        'itemBatch': stamp.itemBatch!.trim(),
      if (stamp.productionDate != null) 'parsedDate': stamp.productionDate,
    };

    return <AtlasVisualEvidenceObservation>[
      AtlasVisualEvidenceObservation(
        observationId: 'scanner5c-$sessionId-production-stamp',
        sourceEngineId: id,
        area: AtlasInspectionArea.bottomStamp,
        category: AtlasEvidenceCategory.productionStamp,
        label: stamp.isValid
            ? 'Production stamp parsed'
            : 'Production stamp recorded',
        observedValue: raw,
        confidence: inspection.resolvedEvidenceConfidence,
        scanImageId: _bottomImageId(inspection),
        attributes: attributes,
        observedAt: observedAt,
      ),
    ];
  }

  static String? _bottomImageId(AtlasVisualInspection inspection) {
    for (final image in inspection.images) {
      if (image.type.name == 'bottomBox') return image.imageId;
    }
    return null;
  }
}
