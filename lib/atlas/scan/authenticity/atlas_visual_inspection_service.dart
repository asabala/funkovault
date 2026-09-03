import '../contributions/contribution_conflict_policy.dart';
import '../contributions/visual_inspection_contribution.dart';
import '../engine/engine_context.dart';
import '../models/scan_session.dart';
import 'atlas_authenticity_engine.dart';
import 'models/atlas_visual_inspection.dart';

class AtlasVisualInspectionService {
  const AtlasVisualInspectionService({
    this.authenticityEngine = const AtlasAuthenticityEngine(),
  });

  final AtlasAuthenticityEngine authenticityEngine;

  Future<ScanSession> inspect({
    required ScanSession session,
    required AtlasVisualInspection inspection,
  }) async {
    var updated = session;

    for (final image in inspection.images) {
      updated = updated.addImage(image);
    }

    updated = updated.addContribution(
      VisualInspectionContribution(
        contributionId: 'visual-inspection-${session.sessionId}',
        sourceEngineId: 'atlas.visual-inspection',
        createdAt: DateTime.now().toUtc(),
        inspection: inspection,
        confidence: inspection.resolvedEvidenceConfidence,
        attributes: <String, Object?>{
          'inspectionAreas': inspection.inspectedAreas
              .map((area) => area.name)
              .toList(growable: false),
          'structuredObservationCount': inspection.observations.length,
          'hasReferenceCriteria': inspection.referenceCriteria != null,
        },
      ),
      conflictPolicy: ContributionConflictPolicy.replaceExisting,
    );

    final result = await authenticityEngine.process(
      updated,
      EngineContext(
        requestId: session.sessionId,
        createdAt: DateTime.now().toUtc(),
        deviceType: EngineDeviceType.mobile,
      ),
    );

    return result.session;
  }
}
