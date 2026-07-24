// Represents one possible collectible identity inferred from recognition
// evidence.
//
// A hypothesis is intentionally not treated as a confirmed product. It records
// the identity Atlas currently believes is possible, along with the evidence
// supporting that belief.
final class IdentityHypothesis {
  IdentityHypothesis({
    required this.hypothesisId,
    required this.displayName,
    this.productLine,
    this.brand,
    this.series,
    this.characterName,
    this.productNumber,
    this.variantName,
    this.confidence,
    List<String> supportingContributionIds = const <String>[],
    Map<String, Object?> attributes = const <String, Object?>{},
  }) : supportingContributionIds = List<String>.unmodifiable(
    supportingContributionIds,
  ),
        attributes = Map<String, Object?>.unmodifiable(
          attributes,
        );

  // Stable identifier for this hypothesis within the current identity process.
  final String hypothesisId;

  // Human-readable identity summary.
  final String displayName;

  // Core identity fields inferred from recognition evidence.
  final String? productLine;
  final String? brand;
  final String? series;
  final String? characterName;
  final String? productNumber;

  // Variant wording such as Chase, Glow, Metallic, or Special Edition.
  final String? variantName;

  // Confidence assigned by the identity engine.
  final double? confidence;

  // Contributions that support this hypothesis.
  final List<String> supportingContributionIds;

  // Extensible metadata that does not yet deserve a first-class field.
  final Map<String, Object?> attributes;

  bool get hasDisplayName {
    return displayName.trim().isNotEmpty;
  }

  bool get hasProductLine {
    return productLine?.trim().isNotEmpty ?? false;
  }

  bool get hasBrand {
    return brand?.trim().isNotEmpty ?? false;
  }

  bool get hasSeries {
    return series?.trim().isNotEmpty ?? false;
  }

  bool get hasCharacterName {
    return characterName?.trim().isNotEmpty ?? false;
  }

  bool get hasProductNumber {
    return productNumber?.trim().isNotEmpty ?? false;
  }

  bool get hasVariantName {
    return variantName?.trim().isNotEmpty ?? false;
  }

  bool get hasConfidence {
    return confidence != null;
  }

  bool get hasSupportingEvidence {
    return supportingContributionIds.isNotEmpty;
  }

  bool get hasCoreIdentity {
    return hasCharacterName ||
        hasProductNumber ||
        hasSeries ||
        hasProductLine;
  }

  T? attribute<T>(String key) {
    final Object? value = attributes[key];

    if (value is T) {
      return value;
    }

    return null;
  }

  bool hasAttribute(String key) {
    return attributes.containsKey(key);
  }

  @override
  String toString() {
    return 'IdentityHypothesis('
        'hypothesisId: $hypothesisId, '
        'displayName: $displayName, '
        'productNumber: $productNumber, '
        'variantName: $variantName, '
        'confidence: $confidence, '
        'supportingEvidence: ${supportingContributionIds.length}'
        ')';
  }
}