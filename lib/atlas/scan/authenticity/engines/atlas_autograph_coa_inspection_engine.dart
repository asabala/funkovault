import '../models/atlas_authenticity_evidence.dart';
import '../models/atlas_visual_inspection.dart';
import '../providers/atlas_authentication_evidence_interpreter.dart';

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
          observationId: 'scanner5e-$sessionId-autograph',
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
            'verificationState': 'notAttempted',
          },
          observedAt: observedAt,
        ),
      );
    }

    final AtlasAuthenticationEvidenceInterpretation authentication =
        AtlasAuthenticationEvidenceInterpreter.interpret(
          provider: inspection.authenticationProvider,
          certificateNumber: inspection.authenticityNumber,
          certificationText: inspection.certificationText,
          hasCoa: inspection.hasCoa,
        );

    final bool hasAuthenticationObservation =
        inspection.hasCoa != null ||
        authentication.hasProvider ||
        authentication.hasCertificateNumber ||
        inspection.certificationText.trim().isNotEmpty;

    if (hasAuthenticationObservation) {
      final String observedValue = <String>[
        if (authentication.providerDisplayName.isNotEmpty)
          authentication.providerDisplayName,
        if (authentication.certificateNumber.isNotEmpty)
          authentication.certificateNumber,
      ].join(' - ');

      result.add(
        AtlasVisualEvidenceObservation(
          observationId: 'scanner5e-$sessionId-coa',
          sourceEngineId: id,
          area: AtlasInspectionArea.coa,
          category: AtlasEvidenceCategory.autographCoa,
          label: 'COA / authentication observation',
          observedValue: observedValue.isEmpty
              ? 'Authentication documentation observed'
              : observedValue,
          confidence: inspection.resolvedEvidenceConfidence,
          scanImageId: _imageId(inspection, 'certification'),
          attributes: <String, Object?>{
            if (inspection.hasCoa != null) 'hasCoa': inspection.hasCoa,
            if (authentication.providerDisplayName.isNotEmpty)
              'provider': authentication.providerDisplayName,
            if (authentication.certificateNumber.isNotEmpty)
              'certificateNumber': authentication.certificateNumber,
            if (inspection.certificationText.trim().isNotEmpty)
              'certificationText': inspection.certificationText.trim(),
            if (authentication.detectedProviderDisplayName.isNotEmpty)
              'detectedProvider': authentication.detectedProviderDisplayName,
            if (authentication.detectedCertificateNumber.isNotEmpty)
              'detectedCertificateNumber':
                  authentication.detectedCertificateNumber,
            'providerKind': authentication.providerKind.name,
            'documentationState': authentication.documentationState.name,
            'providerFieldMismatch': authentication.providerFieldMismatch,
            'certificateNumberMismatch':
                authentication.certificateNumberMismatch,
            'internalMismatch': authentication.hasInternalMismatch,
            'providerVerified': false,
            'verificationState': 'notAttempted',
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
