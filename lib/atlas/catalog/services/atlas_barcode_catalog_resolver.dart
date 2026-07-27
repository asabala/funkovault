import 'package:funkovault2/atlas/catalog/models/atlas_catalog_product.dart';
import 'package:funkovault2/atlas/catalog/services/atlas_catalog_service.dart';

/// Describes the outcome of resolving a scanned barcode against
/// the Atlas product catalog.
enum AtlasBarcodeResolutionStatus {
  invalidBarcode,
  noMatch,
  singleMatch,
  multipleMatches,
}

/// Immutable result returned after checking a barcode against
/// the Atlas product catalog.
final class AtlasBarcodeResolution {
  const AtlasBarcodeResolution._({
    required this.barcode,
    required this.status,
    required this.matches,
  });

  factory AtlasBarcodeResolution.invalid({
    required String barcode,
  }) {
    return AtlasBarcodeResolution._(
      barcode: barcode,
      status: AtlasBarcodeResolutionStatus.invalidBarcode,
      matches: const <AtlasCatalogProduct>[],
    );
  }

  factory AtlasBarcodeResolution.noMatch({
    required String barcode,
  }) {
    return AtlasBarcodeResolution._(
      barcode: barcode,
      status: AtlasBarcodeResolutionStatus.noMatch,
      matches: const <AtlasCatalogProduct>[],
    );
  }

  factory AtlasBarcodeResolution.matches({
    required String barcode,
    required List<AtlasCatalogProduct> matches,
  }) {
    final List<AtlasCatalogProduct> immutableMatches =
    List<AtlasCatalogProduct>.unmodifiable(
      matches,
    );

    return AtlasBarcodeResolution._(
      barcode: barcode,
      status: immutableMatches.length == 1
          ? AtlasBarcodeResolutionStatus.singleMatch
          : AtlasBarcodeResolutionStatus.multipleMatches,
      matches: immutableMatches,
    );
  }

  final String barcode;

  final AtlasBarcodeResolutionStatus status;

  final List<AtlasCatalogProduct> matches;

  bool get isValidBarcode {
    return status != AtlasBarcodeResolutionStatus.invalidBarcode;
  }

  bool get hasMatch {
    return matches.isNotEmpty;
  }

  bool get hasSingleMatch {
    return status == AtlasBarcodeResolutionStatus.singleMatch;
  }

  bool get hasMultipleMatches {
    return status == AtlasBarcodeResolutionStatus.multipleMatches;
  }

  AtlasCatalogProduct? get singleMatch {
    if (!hasSingleMatch) {
      return null;
    }

    return matches.first;
  }
}

/// Resolves scanner barcode values through the shared Atlas catalog service.
///
/// Scanner screens and scan workflows should use this resolver rather than
/// creating repository implementations or performing catalog scans directly.
final class AtlasBarcodeCatalogResolver {
  AtlasBarcodeCatalogResolver({
    AtlasCatalogService? catalogService,
  }) : _catalogService =
      catalogService ?? AtlasCatalogService.instance;

  final AtlasCatalogService _catalogService;

  Future<AtlasBarcodeResolution> resolve(
      String barcode,
      ) async {
    final String normalizedBarcode = _normalizeBarcode(
      barcode,
    );

    if (normalizedBarcode.isEmpty) {
      return AtlasBarcodeResolution.invalid(
        barcode: barcode,
      );
    }

    final List<AtlasCatalogProduct> matches =
    await _catalogService.findByBarcode(
      normalizedBarcode,
    );

    if (matches.isEmpty) {
      return AtlasBarcodeResolution.noMatch(
        barcode: normalizedBarcode,
      );
    }

    return AtlasBarcodeResolution.matches(
      barcode: normalizedBarcode,
      matches: matches,
    );
  }

  static String _normalizeBarcode(
      String value,
      ) {
    return value.replaceAll(
      RegExp(r'[^0-9A-Za-z]'),
      '',
    );
  }
}