import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/academy/academy_ids.dart';
import 'package:funkovault2/academy/engines/academy_explainer_engine.dart';

void main() {
  group('AcademyExplainerEngine', () {
    const AcademyExplainerEngine engine = AcademyExplainerEngine();

    test('resolves a Common question to the Common lesson', () {
      final AcademyExplainerResult? result = engine.explain(
        'What is a Common?',
      );

      expect(result?.lesson?.id, AcademyLessonIds.funkoCommon);
    });

    test('resolves a Chase question to the Chase lesson', () {
      final AcademyExplainerResult? result = engine.explain('What is a Chase?');

      expect(result?.lesson?.id, AcademyLessonIds.funkoChase);
    });

    test('resolves rare variant to Chase rather than Common', () {
      final AcademyExplainerResult? result = engine.explain(
        'What is a rare variant?',
      );

      expect(result?.lesson?.id, AcademyLessonIds.funkoChase);
      expect(result?.lesson?.id, isNot(AcademyLessonIds.funkoCommon));
    });

    test('resolves regular release to the Common lesson', () {
      final AcademyExplainerResult? result = engine.explain(
        'What is a regular release?',
      );

      expect(result?.lesson?.id, AcademyLessonIds.funkoCommon);
    });

    test('returns null for a blank question', () {
      expect(engine.explain('   '), isNull);
    });
  });
}
