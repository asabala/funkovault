enum AtlasReferenceCoverageLevel { unknown, limited, partial, comprehensive }

enum AtlasReferenceSourceType {
  officialRecord,
  verifiedCollectorArchive,
  communityConsensus,
  inferredEstimate,
}

final class AtlasReferenceProvenance {
  AtlasReferenceProvenance({
    required this.sourceType,
    required String sourceIdentifier,
    required DateTime lastVerifiedAt,
    this.specialistVetted = false,
  }) : sourceIdentifier = _requireText(sourceIdentifier, 'sourceIdentifier'),
       lastVerifiedAt = lastVerifiedAt.toUtc();

  final AtlasReferenceSourceType sourceType;
  final String sourceIdentifier;
  final DateTime lastVerifiedAt;
  final bool specialistVetted;
}

final class AtlasProductionRunReference {
  AtlasProductionRunReference({
    required String runIdentifier,
    Iterable<String> knownFactoryPrefixes = const <String>[],
    this.earliestKnownDate,
    this.latestKnownDate,
    Iterable<int> expectedCopyrightYears = const <int>[],
    Iterable<String> verifiedStickerFamilies = const <String>[],
    required this.provenance,
  }) : runIdentifier = _requireText(runIdentifier, 'runIdentifier'),
       knownFactoryPrefixes = List<String>.unmodifiable(
         knownFactoryPrefixes
             .map((String value) => value.trim().toUpperCase())
             .where((String value) => value.isNotEmpty)
             .toSet(),
       ),
       expectedCopyrightYears = List<int>.unmodifiable(
         expectedCopyrightYears.where((int value) => value > 1900).toSet(),
       ),
       verifiedStickerFamilies = List<String>.unmodifiable(
         verifiedStickerFamilies
             .map((String value) => value.trim())
             .where((String value) => value.isNotEmpty)
             .toSet(),
       ) {
    if (earliestKnownDate != null &&
        latestKnownDate != null &&
        earliestKnownDate!.isAfter(latestKnownDate!)) {
      throw ArgumentError('earliestKnownDate cannot be after latestKnownDate.');
    }
  }

  final String runIdentifier;
  final List<String> knownFactoryPrefixes;
  final DateTime? earliestKnownDate;
  final DateTime? latestKnownDate;
  final List<int> expectedCopyrightYears;
  final List<String> verifiedStickerFamilies;
  final AtlasReferenceProvenance provenance;

  bool matchesFactoryPrefix(String prefix) {
    if (knownFactoryPrefixes.isEmpty) {
      return true;
    }
    return knownFactoryPrefixes.contains(prefix.trim().toUpperCase());
  }

  bool containsProductionDate(DateTime date) {
    final DateTime normalized = date.toUtc();
    if (earliestKnownDate != null &&
        normalized.isBefore(earliestKnownDate!.toUtc())) {
      return false;
    }
    if (latestKnownDate != null &&
        normalized.isAfter(latestKnownDate!.toUtc())) {
      return false;
    }
    return true;
  }

  bool matchesStamp({required String prefix, required DateTime date}) {
    return matchesFactoryPrefix(prefix) && containsProductionDate(date);
  }
}

final class AtlasInspectionReferenceCriteria {
  AtlasInspectionReferenceCriteria({
    required String productId,
    String? upc,
    required this.coverageLevel,
    required double completenessScore,
    Iterable<AtlasProductionRunReference> knownRuns =
        const <AtlasProductionRunReference>[],
    Iterable<String> legitimateVariantTypes = const <String>[],
    Iterable<String> knownPackagingRevisions = const <String>[],
    Iterable<AtlasReferenceProvenance> provenance =
        const <AtlasReferenceProvenance>[],
    this.highCounterfeitRiskLine = false,
  }) : productId = _requireText(productId, 'productId'),
       upc = _optionalText(upc),
       completenessScore = _normalizeScore(
         completenessScore,
         'completenessScore',
       ),
       knownRuns = List<AtlasProductionRunReference>.unmodifiable(knownRuns),
       legitimateVariantTypes = List<String>.unmodifiable(
         legitimateVariantTypes
             .map((String value) => value.trim())
             .where((String value) => value.isNotEmpty)
             .toSet(),
       ),
       knownPackagingRevisions = List<String>.unmodifiable(
         knownPackagingRevisions
             .map((String value) => value.trim())
             .where((String value) => value.isNotEmpty)
             .toSet(),
       ),
       provenance = List<AtlasReferenceProvenance>.unmodifiable(provenance);

  final String productId;
  final String? upc;
  final AtlasReferenceCoverageLevel coverageLevel;
  final double completenessScore;
  final List<AtlasProductionRunReference> knownRuns;
  final List<String> legitimateVariantTypes;
  final List<String> knownPackagingRevisions;
  final List<AtlasReferenceProvenance> provenance;
  final bool highCounterfeitRiskLine;

  bool get hasUsefulReferenceData {
    return coverageLevel != AtlasReferenceCoverageLevel.unknown &&
        completenessScore > 0.0;
  }

  bool get canSupportConcernAssessment {
    return (coverageLevel == AtlasReferenceCoverageLevel.partial ||
            coverageLevel == AtlasReferenceCoverageLevel.comprehensive) &&
        completenessScore >= 0.50;
  }

  static AtlasInspectionReferenceCriteria unknown({
    required String productId,
    String? upc,
  }) {
    return AtlasInspectionReferenceCriteria(
      productId: productId,
      upc: upc,
      coverageLevel: AtlasReferenceCoverageLevel.unknown,
      completenessScore: 0.0,
    );
  }
}

String _requireText(String value, String fieldName) {
  final String normalized = value.trim();
  if (normalized.isEmpty) {
    throw ArgumentError.value(value, fieldName, '$fieldName cannot be empty.');
  }
  return normalized;
}

String? _optionalText(String? value) {
  final String normalized = value?.trim() ?? '';
  return normalized.isEmpty ? null : normalized;
}

double _normalizeScore(double value, String fieldName) {
  if (!value.isFinite || value < 0.0 || value > 1.0) {
    throw ArgumentError.value(
      value,
      fieldName,
      '$fieldName must be between 0.0 and 1.0.',
    );
  }
  return value;
}
