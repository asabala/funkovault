import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/widgets/pop/pop_form.dart';

void main() {
  group('PopFormValues.validateName', () {
    test('requires a non-empty trimmed name', () {
      expect(PopFormValues.validateName(null), isNotNull);
      expect(PopFormValues.validateName('   '), isNotNull);
      expect(PopFormValues.validateName('  Batman  '), isNull);
    });
  });

  group('PopFormValues.validateOptionalMoney', () {
    String? validate(String? value) => PopFormValues.validateOptionalMoney(
      value,
      fieldLabel: 'Estimated value',
    );

    test('allows blank, zero, integer, and decimal amounts', () {
      expect(validate(null), isNull);
      expect(validate(''), isNull);
      expect(validate('0'), isNull);
      expect(validate('12'), isNull);
      expect(validate('12.50'), isNull);
    });

    test('rejects negative, malformed, and non-finite amounts', () {
      expect(validate('-0.01'), isNotNull);
      expect(validate('twelve'), isNotNull);
      expect(validate('NaN'), isNotNull);
      expect(validate('Infinity'), isNotNull);
    });

    test('parses blank as zero and valid decimal input exactly', () {
      expect(PopFormValues.parseOptionalMoney('  '), 0);
      expect(PopFormValues.parseOptionalMoney(' 12.50 '), 12.5);
    });
  });

  group('PopFormValues.validateQuantity', () {
    test('allows positive whole numbers', () {
      expect(PopFormValues.validateQuantity('1'), isNull);
      expect(PopFormValues.validateQuantity('25'), isNull);
      expect(PopFormValues.parseQuantity(' 25 '), 25);
    });

    test('rejects blank, zero, negative, decimal, and malformed values', () {
      expect(PopFormValues.validateQuantity(null), isNotNull);
      expect(PopFormValues.validateQuantity(''), isNotNull);
      expect(PopFormValues.validateQuantity('0'), isNotNull);
      expect(PopFormValues.validateQuantity('-1'), isNotNull);
      expect(PopFormValues.validateQuantity('1.5'), isNotNull);
      expect(PopFormValues.validateQuantity('many'), isNotNull);
    });
  });
}
