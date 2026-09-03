import '../contributions/contribution_conflict_policy.dart';
import '../contributions/visual_inspection_contribution.dart';
import '../engine/engine_context.dart';
import '../models/scan_session.dart';
import 'atlas_authenticity_engine.dart';
import 'engines/atlas_high_signal_inspection_pipeline.dart';
import 'models/atlas_visual_inspection.dart';

class AtlasVisualInspectionService {
  const AtlasVisualInspectionService({
    this.authenticityEngine = const AtlasAuthenticityEngine(),
    this.highSignalPipeline = const AtlasHighSignalInspectionPipeline(),
  });

  final AtlasAuthenticityEngine authenticityEngine;
  final AtlasHighSignalInspectionPipeline highSignalPipeline;

  Future<ScanSession> inspect({
    required ScanSession session,
    required AtlasVisualInspection inspection,
  }) async {
    final AtlasVisualInspection enrichedInspection = highSignalPipeline.enrich(
      sessionId: session.sessionId,
      inspection: inspection,
      expectedResolvedVariant: session.resolvedProduct?.variantName,
    );

    var updated = session;

    for (final image in enrichedInspection.images) {
      updated = updated.addImage(image);
    }

    updated = updated.addContribution(
      VisualInspectionContribution(
        contributionId: 'visual-inspection-${session.sessionId}',
        sourceEngineId: 'atlas.visual-inspection',
        createdAt: DateTime.now().toUtc(),
        inspection: enrichedInspection,
        confidence: enrichedInspection.resolvedEvidenceConfidence,
        attributes: <String, Object?>{
          'inspectionAreas': enrichedInspection.inspectedAreas
              .map((area) => area.name)
              .toList(growable: false),
          'structuredObservationCount': enrichedInspection.observations.length,
          'hasReferenceCriteria': enrichedInspection.referenceCriteria != null,
          'highSignalEnginesApplied': true,
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
