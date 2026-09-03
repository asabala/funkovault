import '../contributions/authenticity_contribution.dart';
import '../contributions/contribution_conflict_policy.dart';
import '../contributions/visual_inspection_contribution.dart';
import '../engine/abstract_scan_engine.dart';
import '../engine/engine_context.dart';
import '../engine/engine_result.dart';
import '../engine/engine_support.dart';
import '../models/scan_session.dart';
import 'atlas_authenticity_rules.dart';

final class AtlasAuthenticityEngine extends AbstractScanEngine {
  const AtlasAuthenticityEngine();

  static const id = 'atlas.scan.authenticity';
  static const capabilityId = 'atlas.capability.authenticity';

  @override
  String get engineId => id;

  @override
  String get displayName => 'Authenticity Intelligence';

  @override
  Future<EngineResult> execute(
    ScanSession session,
    EngineContext context,
  ) async {
    final visual = session
        .latestContributionOfType<VisualInspectionContribution>();
    if (visual == null) {
      return EngineResult.skipped(
        session: session,
        reason: 'No visual inspection evidence is available.',
      );
    }

    final assessment = AtlasAuthenticityRules.evaluate(
      session: session,
      inspection: visual.inspection,
    );

    final contribution = AuthenticityContribution(
      contributionId: EngineSupport.buildContributionId(
        namespace: 'atlas.authenticity',
        segments: <Object?>[session.sessionId],
      ),
      sourceEngineId: engineId,
      createdAt: DateTime.now().toUtc(),
      assessment: assessment,
      confidence: assessment.evidenceConfidence,
      attributes: <String, Object?>{
        'status': assessment.status.name,
        'concernLevel': assessment.concernLevel.name,
        'evidenceConfidence': assessment.evidenceConfidence,
        'referenceCoverage': assessment.referenceCoverage,
        'inspectionCoverage': assessment.inspectionCoverage,
        'concernScore': assessment.aggregatedConcernScore,
      },
    );

    final updated = session.addContribution(
      contribution,
      conflictPolicy: ContributionConflictPolicy.replaceExisting,
    );

    return EngineResult.success(session: updated);
  }
}
