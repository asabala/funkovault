import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/scan/authenticity/models/atlas_authenticity_assessment.dart';
import 'package:funkovault2/atlas/scan/authenticity/models/atlas_visual_inspection.dart';
import 'package:funkovault2/atlas/scan/models/scan_session.dart';
import 'package:funkovault2/atlas/scan/models/scanner_type.dart';
import 'package:funkovault2/atlas/scan/results/scan_variant_status.dart';
import 'package:funkovault2/atlas/scan/workflow/scan_intent.dart';
import 'package:funkovault2/atlas/scan/workflow/scan_performance_mode.dart';
import 'package:funkovault2/widgets/scanner/atlas_authenticity_card.dart';
import 'package:funkovault2/widgets/scanner/atlas_inspection_intelligence_dashboard.dart';

void main() {
  testWidgets('dashboard exposes all five Scanner 5F intelligence surfaces', (
    WidgetTester tester,
  ) async {
    final ScanSession session = ScanSession(
      sessionId: 'scanner-5f-test',
      startedAt: DateTime.utc(2026, 9, 3),
      intent: ScanIntent.identifyProduct,
      performanceMode: ScanPerformanceMode.fullAnalysis,
      scannerType: ScannerType.mobileScanner,
      variantResolution: const ScanVariantResolution(
        status: ScanVariantStatus.visualConfirmationRequired,
        candidateProductIds: <String>['ATLAS-FNK-000001'],
        unconfirmedTraits: <String>['Chase sticker'],
        confidence: 0.82,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AtlasInspectionIntelligenceDashboard(
              session: session,
              inspection: AtlasVisualInspection(
                signature: 'Jane Doe',
                hasAutograph: true,
                hasCoa: false,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('📷 Evidence Confidence'), findsOneWidget);
    expect(find.text('📚 Reference Coverage'), findsOneWidget);
    expect(find.text('🛡️ Authenticity Concern'), findsOneWidget);
    expect(find.text('🧩 Variant Confirmation'), findsOneWidget);
    expect(find.text('✍️ Autograph / 📜 COA Evidence'), findsOneWidget);
    expect(find.text('Visual confirmation needed'), findsOneWidget);
    expect(find.text('Jane Doe'), findsOneWidget);
  });

  testWidgets('authenticity card keeps concern wording non-definitive', (
    WidgetTester tester,
  ) async {
    final assessment = AtlasAuthenticityAssessment(
      status: AtlasAuthenticityStatus.reviewRecommended,
      concernLevel: AtlasAuthenticityConcernLevel.significantInconsistencies,
      evidenceConfidence: 0.84,
      referenceCoverage: 0.62,
      inspectionCoverage: 0.67,
      aggregatedConcernScore: 0.41,
      summary: 'Some inspected evidence should be reviewed.',
      signals: const [],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AtlasAuthenticityCard(assessment: assessment)),
      ),
    );

    expect(find.text('🧠 Inspection Assessment'), findsOneWidget);
    expect(find.text('Significant inconsistencies'), findsOneWidget);
    expect(find.textContaining('not a certification'), findsOneWidget);
  });
}
