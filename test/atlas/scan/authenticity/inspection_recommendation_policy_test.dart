import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/scan/authenticity/models/atlas_inspection_reference.dart';
import 'package:funkovault2/atlas/scan/authenticity/policies/inspection_recommendation_policy.dart';

void main() {
  test(
    'grail guard recommends inspection without making authenticity claim',
    () {
      final reference = AtlasInspectionReferenceCriteria(
        productId: 'ATLAS-FNK-000001',
        coverageLevel: AtlasReferenceCoverageLevel.partial,
        completenessScore: 0.75,
        highCounterfeitRiskLine: true,
      );

      final result = const AtlasStandardGrailGuardPolicy().evaluate(
        reference: reference,
        context: AtlasInspectionRecommendationContext(
          marketValue: 250.0,
          collectorValueThreshold: 100.0,
        ),
      );

      expect(result.isRecommended, isTrue);
      expect(result.badgeLabel, contains('Grail Guard'));
      expect(result.explanation!.toLowerCase(), contains('inspection'));
      expect(result.explanation!.toLowerCase(), isNot(contains('fake')));
      expect(result.explanation!.toLowerCase(), isNot(contains('authentic')));
    },
  );

  test('high collector value alone can recommend a deeper inspection', () {
    final reference = AtlasInspectionReferenceCriteria.unknown(
      productId: 'ATLAS-FNK-000002',
    );

    final result = const AtlasStandardGrailGuardPolicy().evaluate(
      reference: reference,
      context: AtlasInspectionRecommendationContext(
        marketValue: 150.0,
        collectorValueThreshold: 100.0,
      ),
    );

    expect(result.isRecommended, isTrue);
    expect(result.reasons, contains('Collector value threshold exceeded'));
  });

  test(
    'variant uncertainty recommends inspection without rewriting identity',
    () {
      final reference = AtlasInspectionReferenceCriteria.unknown(
        productId: 'ATLAS-FNK-000003',
      );

      final result = const AtlasStandardGrailGuardPolicy().evaluate(
        reference: reference,
        context: AtlasInspectionRecommendationContext(
          collectorValueThreshold: 100.0,
          requiresVariantConfirmation: true,
        ),
      );

      expect(result.isRecommended, isTrue);
      expect(result.badgeLabel, contains('Variant Review'));
      expect(result.reasons, contains('Variant confirmation required'));
    },
  );

  test('limited signed release recommends collector inspection', () {
    final reference = AtlasInspectionReferenceCriteria.unknown(
      productId: 'ATLAS-FNK-000004',
    );

    final result = const AtlasStandardGrailGuardPolicy().evaluate(
      reference: reference,
      context: AtlasInspectionRecommendationContext(
        collectorValueThreshold: 100.0,
        isLimitedEdition: true,
        hasAutographOrAuthentication: true,
      ),
    );

    expect(result.isRecommended, isTrue);
    expect(result.reasons, contains('Limited or restricted release'));
    expect(
      result.reasons,
      contains('Autograph or authentication evidence recorded'),
    );
  });

  test('weak reference coverage by itself does not create a grail warning', () {
    final reference = AtlasInspectionReferenceCriteria.unknown(
      productId: 'ATLAS-FNK-000005',
    );

    final result = const AtlasStandardGrailGuardPolicy().evaluate(
      reference: reference,
      context: AtlasInspectionRecommendationContext(
        collectorValueThreshold: 100.0,
        hasWeakReferenceCoverage: true,
      ),
    );

    expect(result.isRecommended, isFalse);
  });
}
