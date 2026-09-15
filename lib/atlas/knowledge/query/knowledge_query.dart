// Represents a category-agnostic request for collectible knowledge.
//
// Providers can inspect the available query fields and determine whether
// they are capable of handling the request.
class KnowledgeQuery {
  KnowledgeQuery({
    this.text,
    this.category,
    this.barcode,
    this.catalogNumber,
    this.externalId,
    Map<String, String> attributes = const <String, String>{},
    Map<String, String> metadata = const <String, String>{},
  }) : attributes = Map<String, String>.unmodifiable(attributes),
       metadata = Map<String, String>.unmodifiable(metadata);

  // General search text supplied by the user or another Atlas engine.
  final String? text;

  // Optional collectible category such as Funko, Pokemon, or comics.
  final String? category;

  // Barcode, UPC, EAN, or another machine-readable product code.
  final String? barcode;

  // Catalog number, card number, issue number, or product index.
  final String? catalogNumber;

  // Identifier from an external provider or catalog.
  final String? externalId;

  // Structured query attributes that providers may understand.
  final Map<String, String> attributes;

  // Additional execution context that should not define identity.
  final Map<String, String> metadata;

  bool get hasText => _hasValue(text);

  bool get hasCategory => _hasValue(category);

  bool get hasBarcode => _hasValue(barcode);

  bool get hasCatalogNumber => _hasValue(catalogNumber);

  bool get hasExternalId => _hasValue(externalId);

  bool get hasAttributes => attributes.isNotEmpty;

  bool get hasSearchInput {
    return hasText ||
        hasBarcode ||
        hasCatalogNumber ||
        hasExternalId ||
        hasAttributes;
  }

  String? attribute(String key) {
    return attributes[key];
  }

  KnowledgeQuery copyWith({
    String? text,
    String? category,
    String? barcode,
    String? catalogNumber,
    String? externalId,
    Map<String, String>? attributes,
    Map<String, String>? metadata,
  }) {
    return KnowledgeQuery(
      text: text ?? this.text,
      category: category ?? this.category,
      barcode: barcode ?? this.barcode,
      catalogNumber: catalogNumber ?? this.catalogNumber,
      externalId: externalId ?? this.externalId,
      attributes: attributes ?? this.attributes,
      metadata: metadata ?? this.metadata,
    );
  }

  bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  @override
  String toString() {
    return 'KnowledgeQuery('
        'text: $text, '
        'category: $category, '
        'barcode: $barcode, '
        'catalogNumber: $catalogNumber, '
        'externalId: $externalId, '
        'attributes: ${attributes.length}'
        ')';
  }
}
