import '../contributions/contribution_conflict_policy.dart';
import '../contributions/visual_inspection_contribution.dart';
import '../engine/engine_context.dart';
import '../models/scan_session.dart';
import '../variant/atlas_variant_resolution_bridge.dart';
import 'atlas_authenticity_engine.dart';
import 'engines/atlas_high_signal_inspection_pipeline.dart';
import 'models/atlas_visual_inspection.dart';

class AtlasVisualInspectionService {
  const AtlasVisualInspectionService({
    this.authenticityEngine = const AtlasAuthenticityEngine(),
    this.highSignalPipeline = const AtlasHighSignalInspectionPipeline(),
    this.variantResolutionBridge = const AtlasVariantResolutionBridge(),
  });

  final AtlasAuthenticityEngine authenticityEngine;
  final AtlasHighSignalInspectionPipeline highSignalPipeline;
  final AtlasVariantResolutionBridge variantResolutionBridge;

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

    // Scanner 5D interprets the structured sticker evidence for the existing
    // variant-resolution model. This intentionally happens outside the session
    // projector so visual evidence cannot replace canonical product identity.
    final variantResolution = variantResolutionBridge.resolve(updated);
    if (variantResolution != null) {
      updated = updated.copyWith(variantResolution: variantResolution);
    }

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
