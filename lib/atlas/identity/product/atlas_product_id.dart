// Canonical identifier for a product known by Atlas.
//
// Example:
//
// ATLAS-FNK-000001
//
// This ID is owned by Atlas and remains stable regardless of changes to
// external product databases.
final class AtlasProductId {
  AtlasProductId({required String categoryCode, required int numericId})
    : categoryCode = _normalizeCategoryCode(categoryCode),
      numericId = _validateNumericId(numericId);

  // Convenience constructor for Funko products.
  AtlasProductId.funko({required int numericId})
    : this(categoryCode: 'FNK', numericId: numericId);

  // Future convenience constructors.
  AtlasProductId.pokemon({required int numericId})
    : this(categoryCode: 'PKM', numericId: numericId);

  AtlasProductId.hotWheels({required int numericId})
    : this(categoryCode: 'HW', numericId: numericId);

  AtlasProductId.sports({required int numericId})
    : this(categoryCode: 'SPT', numericId: numericId);

  // Product family/category.
  final String categoryCode;

  // Stable Atlas-owned identifier.
  final int numericId;

  String get formattedNumericId {
    return numericId.toString().padLeft(6, '0');
  }

  // Human-readable identifier.
  String get value {
    return 'ATLAS-$categoryCode-$formattedNumericId';
  }

  // Atlas URI.
  Uri get uri {
    return Uri(scheme: 'atlas', host: 'product', pathSegments: <String>[value]);
  }

  static String _normalizeCategoryCode(String value) {
    final String normalized = value.trim().toUpperCase();

    if (normalized.isEmpty) {
      throw ArgumentError.value(
        value,
        'categoryCode',
        'Category code cannot be empty.',
      );
    }

    return normalized;
  }

  static int _validateNumericId(int value) {
    if (value <= 0) {
      throw ArgumentError.value(
        value,
        'numericId',
        'Numeric ID must be greater than zero.',
      );
    }

    return value;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AtlasProductId &&
            other.categoryCode == categoryCode &&
            other.numericId == numericId;
  }

  @override
  int get hashCode {
    return Object.hash(categoryCode, numericId);
  }

  @override
  String toString() {
    return value;
  }
}
