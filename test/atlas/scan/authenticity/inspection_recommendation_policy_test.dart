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
    },
  );
}
