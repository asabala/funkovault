import '../models/catalog_match.dart';

// Immutable result returned by the catalog resolution service.
//
// A result always contains the ranked candidate list and may contain a
// selected match when Atlas has enough confidence to resolve the product.
final class CatalogResolutionResult {
  CatalogResolutionResult({
    this.selectedMatch,
    Iterable<CatalogMatch> candidateMatches = const <CatalogMatch>[],
    this.requiresReview = false,
    this.resolutionReason,
    Map<String, Object?> attributes = const <String, Object?>{},
  }) : candidateMatches = List.unmodifiable(candidateMatches),
       attributes = Map.unmodifiable(Map<String, Object?>.from(attributes));

  final CatalogMatch? selectedMatch;

  final List<CatalogMatch> candidateMatches;

  final bool requiresReview;

  final String? resolutionReason;

  final Map<String, Object?> attributes;

  bool get hasMatch {
    return selectedMatch != null;
  }

  bool get hasCandidates {
    return candidateMatches.isNotEmpty;
  }

  double get confidence {
    return selectedMatch?.confidence ?? 0.0;
  }

  CatalogMatch? get bestCandidate {
    if (candidateMatches.isEmpty) {
      return null;
    }

    return candidateMatches.first;
  }

  List<CatalogMatch> get alternatives {
    if (candidateMatches.length <= 1) {
      return const <CatalogMatch>[];
    }

    return candidateMatches.skip(1).toList(growable: false);
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
}
