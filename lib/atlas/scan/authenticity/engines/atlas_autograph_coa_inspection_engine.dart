import '../models/atlas_authenticity_evidence.dart';
import '../models/atlas_visual_inspection.dart';

final class AtlasAutographCoaInspectionEngine {
  const AtlasAutographCoaInspectionEngine();

  static const String id = 'atlas.scan.authenticity.autograph-coa';

  List<AtlasVisualEvidenceObservation> inspect({
    required String sessionId,
    required AtlasVisualInspection inspection,
    required DateTime observedAt,
  }) {
    final List<AtlasVisualEvidenceObservation> result =
        <AtlasVisualEvidenceObservation>[];

    final String signature = inspection.signature.trim();
    if (inspection.hasAutograph != null || signature.isNotEmpty) {
      result.add(
        AtlasVisualEvidenceObservation(
          observationId: 'scanner5c-$sessionId-autograph',
          sourceEngineId: id,
          area: AtlasInspectionArea.autograph,
          category: AtlasEvidenceCategory.autographCoa,
          label: 'Autograph observation',
          observedValue: signature.isEmpty
              ? 'Autograph presence recorded'
              : signature,
          confidence: inspection.resolvedEvidenceConfidence,
          scanImageId: _imageId(inspection, 'autograph'),
          attributes: <String, Object?>{
            if (inspection.hasAutograph != null)
              'hasAutograph': inspection.hasAutograph,
            if (signature.isNotEmpty) 'signature': signature,
            'providerVerified': false,
          },
          observedAt: observedAt,
        ),
      );
    }

    final String provider = inspection.authenticationProvider.trim();
    final String number = inspection.authenticityNumber.trim();
    if (inspection.hasCoa != null || provider.isNotEmpty || number.isNotEmpty) {
      result.add(
        AtlasVisualEvidenceObservation(
          observationId: 'scanner5c-$sessionId-coa',
          sourceEngineId: id,
          area: AtlasInspectionArea.coa,
          category: AtlasEvidenceCategory.autographCoa,
          label: 'COA / authentication observation',
          observedValue: <String>[
            if (provider.isNotEmpty) provider,
            if (number.isNotEmpty) number,
          ].join(' - '),
          confidence: inspection.resolvedEvidenceConfidence,
          scanImageId: _imageId(inspection, 'certification'),
          attributes: <String, Object?>{
            if (inspection.hasCoa != null) 'hasCoa': inspection.hasCoa,
            if (provider.isNotEmpty) 'provider': provider,
            if (number.isNotEmpty) 'certificateNumber': number,
            'providerVerified': false,
          },
          observedAt: observedAt,
        ),
      );
    }

    return List<AtlasVisualEvidenceObservation>.unmodifiable(result);
  }

  static String? _imageId(AtlasVisualInspection inspection, String typeName) {
    for (final image in inspection.images) {
      if (image.type.name == typeName) return image.imageId;
    }
    return null;
  }
}
