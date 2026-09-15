import 'package:funkovault2/atlas/collection/models/atlas_collector_state.dart';
import 'package:funkovault2/models/pop.dart';

class AtlasCollectorStateEngine {
  const AtlasCollectorStateEngine();

  AtlasCollectorState evaluate({
    required Pop product,
    required List<Pop> collectionPops,
    String scannedBarcode = '',
    Set<String> ownedWishlistIdentityKeys = const <String>{},
  }) {
    final Set<String> scannedBarcodeCandidates = _barcodeCandidates(
      scannedBarcode,
    );

    final String productIdentityKey = product.collectibleIdentityKey.trim();

    final String productSimilarityKey = product.similarityReviewKey.trim();

    final List<Pop> ownedMatches = <Pop>[];
    final List<Pop> wishlistMatches = <Pop>[];
    final List<Pop> relatedMatches = <Pop>[];

    for (final Pop collectionPop in collectionPops) {
      final bool isExactMatch = _isExactMatch(
        product: product,
        collectionPop: collectionPop,
        productIdentityKey: productIdentityKey,
        scannedBarcodeCandidates: scannedBarcodeCandidates,
      );

      if (isExactMatch) {
        if (collectionPop.isWishlist) {
          wishlistMatches.add(collectionPop);
        } else {
          ownedMatches.add(collectionPop);
        }

        continue;
      }

      final String collectionSimilarityKey = collectionPop.similarityReviewKey
          .trim();

      final bool isRelatedMatch =
          productSimilarityKey.isNotEmpty &&
          collectionSimilarityKey.isNotEmpty &&
          collectionSimilarityKey == productSimilarityKey;

      if (isRelatedMatch) {
        relatedMatches.add(collectionPop);
      }
    }

    final bool isProductIdentityWishlisted =
        productIdentityKey.isNotEmpty &&
        ownedWishlistIdentityKeys.contains(productIdentityKey);

    final bool isOwnedMatchWishlisted = ownedMatches.any((Pop ownedPop) {
      final String identityKey = ownedPop.collectibleIdentityKey.trim();

      return identityKey.isNotEmpty &&
          ownedWishlistIdentityKeys.contains(identityKey);
    });

    final bool isOwnedWishlisted =
        isProductIdentityWishlisted || isOwnedMatchWishlisted;

    return AtlasCollectorState(
      ownedMatches: ownedMatches,
      wishlistMatches: wishlistMatches,
      relatedMatches: relatedMatches,
      isOwnedWishlisted: isOwnedWishlisted,
    );
  }

  List<Pop> findByBarcode({
    required String barcode,
    required List<Pop> collectionPops,
  }) {
    final Set<String> barcodeCandidates = _barcodeCandidates(barcode);

    if (barcodeCandidates.isEmpty) {
      return const <Pop>[];
    }

    final List<Pop> matches = <Pop>[];

    for (final Pop pop in collectionPops) {
      final Set<String> popBarcodeCandidates = _barcodeCandidates(
        pop.sourceUpc,
      );

      final bool matchesBarcode =
          popBarcodeCandidates.isNotEmpty &&
          barcodeCandidates.any(popBarcodeCandidates.contains);

      if (matchesBarcode) {
        matches.add(pop);
      }
    }

    return List<Pop>.unmodifiable(matches);
  }

  bool _isExactMatch({
    required Pop product,
    required Pop collectionPop,
    required String productIdentityKey,
    required Set<String> scannedBarcodeCandidates,
  }) {
    final String collectionIdentityKey = collectionPop.collectibleIdentityKey
        .trim();

    // Strongest release-level comparison.
    if (productIdentityKey.isNotEmpty &&
        collectionIdentityKey.isNotEmpty &&
        productIdentityKey == collectionIdentityKey) {
      return true;
    }

    final Set<String> collectionBarcodeCandidates = _barcodeCandidates(
      collectionPop.sourceUpc,
    );

    final bool isBarcodeMatch =
        scannedBarcodeCandidates.isNotEmpty &&
        collectionBarcodeCandidates.isNotEmpty &&
        scannedBarcodeCandidates.any(collectionBarcodeCandidates.contains);

    if (isBarcodeMatch) {
      return true;
    }

    final String productRecordKey = product.collectionRecordKey.trim();

    final String collectionRecordKey = collectionPop.collectionRecordKey.trim();

    return productRecordKey.isNotEmpty &&
        collectionRecordKey.isNotEmpty &&
        productRecordKey == collectionRecordKey;
  }

  Set<String> _barcodeCandidates(String value) {
    final String normalizedBarcode = _normalizeBarcode(value);

    if (normalizedBarcode.isEmpty) {
      return const <String>{};
    }

    final Set<String> candidates = <String>{normalizedBarcode};

    if (normalizedBarcode.length == 13 && normalizedBarcode.startsWith('0')) {
      candidates.add(normalizedBarcode.substring(1));
    }

    if (normalizedBarcode.length == 12) {
      candidates.add('0$normalizedBarcode');
    }

    return candidates;
  }

  String _normalizeBarcode(String value) {
    return value.replaceAll(RegExp(r'[^0-9A-Za-z]'), '');
  }
}
