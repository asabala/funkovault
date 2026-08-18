abstract final class PopFormValues {
  static String? validateName(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'Pop name is required.';
    }

    return null;
  }

  static String? validateOptionalMoney(
    String? value, {
    required String fieldLabel,
  }) {
    final normalized = (value ?? '').trim();

    if (normalized.isEmpty) {
      return null;
    }

    final parsed = double.tryParse(normalized);

    if (parsed == null || !parsed.isFinite || parsed < 0) {
      return '$fieldLabel must be a valid amount of 0 or more.';
    }

    return null;
  }

  static String? validateQuantity(String? value) {
    final normalized = (value ?? '').trim();
    final parsed = int.tryParse(normalized);

    if (parsed == null || parsed < 1) {
      return 'Enter a whole-number quantity of 1 or more.';
    }

    return null;
  }

  static double parseOptionalMoney(String value) {
    final normalized = value.trim();

    if (normalized.isEmpty) {
      return 0;
    }

    return double.parse(normalized);
  }

  static int parseQuantity(String value) {
    return int.parse(value.trim());
  }
}
