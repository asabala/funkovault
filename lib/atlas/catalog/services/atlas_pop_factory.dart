import '../../../models/pop.dart';
import '../converters/atlas_catalog_converter.dart';
import '../models/atlas_catalog_product.dart';

// Central creation point for Vault Pop records.
//
// Screens, scanners, imports, catalog browsing, wishlist flows, and future
// Atlas Intelligence features should use this factory rather than constructing
// Pop records directly.
abstract final class AtlasPopFactory {
  // Creates a completely manual Vault record.
  //
  // This is used when no trusted Atlas catalog product is available.
  static Pop createManual({
    required String name,
    required String number,
    required String category,
    required String series,
    String variant = 'Common',
    String retailExclusive = 'None',
    String eventSticker = 'None',
    String limitedEdition = 'None',
    String signature = 'Unsigned',
    double value = 0,
    double pricePaid = 0,
    int quantity = 1,
    String itemCondition = '',
    String boxCondition = '',
    String imageUrl = '',
    String owner = 'Shared',
    bool isWishlist = false,
    DateTime? timestamp,
  }) {
    final DateTime resolvedTimestamp = timestamp ?? DateTime.now();

    final String now = resolvedTimestamp.toIso8601String();

    final String resolvedVariant = _defaultText(variant, fallback: 'Common');

    return Pop(
      id: resolvedTimestamp.microsecondsSinceEpoch.toString(),
      name: name.trim(),
      number: number.trim(),
      category: category.trim(),
      series: series.trim(),
      edition: resolvedVariant,
      variant: resolvedVariant,
      retailExclusive: _defaultText(retailExclusive, fallback: 'None'),
      eventSticker: _defaultText(eventSticker, fallback: 'None'),
      limitedEdition: _defaultText(limitedEdition, fallback: 'None'),
      signature: _defaultText(signature, fallback: 'Unsigned'),
      sourceCatalogId: '',
      sourceCollectibleId: '',
      sourceUpc: '',
      productionStatus: '',
      releaseDate: '',
      gradingCompany: '',
      authenticityNumber: '',
      value: value < 0 ? 0 : value,
      pricePaid: pricePaid < 0 ? 0 : pricePaid,
      quantity: quantity < 1 ? 1 : quantity,
      itemCondition: itemCondition.trim(),
      boxCondition: boxCondition.trim(),
      imageUrl: imageUrl.trim(),
      owner: _defaultText(owner, fallback: 'Shared'),
      isWishlist: isWishlist,
      dateAdded: now,
      lastUpdated: now,
    );
  }

  // Creates a Vault record from a trusted Atlas catalog product.
  //
  // The converter supplies catalog identity, barcode, image, value, and other
  // trusted metadata. Optional overrides allow the user to edit the form
  // before saving without losing the catalog connection.
  static Pop createFromCatalog({
    required AtlasCatalogProduct product,
    String? name,
    String? number,
    String? category,
    String? series,
    String? variant,
    String? retailExclusive,
    String? eventSticker,
    String limitedEdition = 'None',
    String? signature,
    double? value,
    double pricePaid = 0,
    int quantity = 1,
    String itemCondition = '',
    String boxCondition = '',
    String? imageUrl,
    String owner = 'Shared',
    bool isWishlist = false,
    DateTime? timestamp,
  }) {
    final Pop catalogPop = AtlasCatalogConverter.toPop(
      product,
      owner: owner,
      isWishlist: isWishlist,
      quantity: quantity,
      pricePaid: pricePaid,
      itemCondition: itemCondition,
      boxCondition: boxCondition,
      timestamp: timestamp,
    );

    final String resolvedVariant = _defaultText(
      variant ?? catalogPop.variant,
      fallback: 'Common',
    );

    return catalogPop.copyWith(
      name: name?.trim() ?? catalogPop.name,
      number: number?.trim() ?? catalogPop.number,
      category: category?.trim() ?? catalogPop.category,
      series: series?.trim() ?? catalogPop.series,
      edition: resolvedVariant,
      variant: resolvedVariant,
      retailExclusive: retailExclusive == null
          ? catalogPop.retailExclusive
          : _defaultText(retailExclusive, fallback: 'None'),
      eventSticker: eventSticker == null
          ? catalogPop.eventSticker
          : _defaultText(eventSticker, fallback: 'None'),
      limitedEdition: _resolveCatalogIdentity(
        selectedValue: limitedEdition,
        catalogValue: catalogPop.limitedEdition,
        fallback: 'None',
      ),
      signature: signature == null
          ? catalogPop.signature
          : _defaultText(signature, fallback: 'Unsigned'),
      value: value == null
          ? catalogPop.value
          : value < 0
          ? 0
          : value,
      pricePaid: pricePaid < 0 ? 0 : pricePaid,
      quantity: quantity < 1 ? 1 : quantity,
      itemCondition: itemCondition.trim(),
      boxCondition: boxCondition.trim(),
      imageUrl: imageUrl?.trim() ?? catalogPop.imageUrl,
      owner: _defaultText(owner, fallback: 'Shared'),
      isWishlist: isWishlist,
    );
  }

  // Refreshes trusted catalog metadata on an existing Vault record.
  //
  // Personal ownership information remains protected by the converter.
  static Pop refreshFromCatalog({
    required Pop existingPop,
    required AtlasCatalogProduct product,
    DateTime? timestamp,
  }) {
    return AtlasCatalogConverter.applyCatalogMetadata(
      existingPop: existingPop,
      product: product,
      timestamp: timestamp,
    );
  }

  // Creates a wishlist record from a trusted Atlas catalog product.
  static Pop createWishlistFromCatalog({
    required AtlasCatalogProduct product,
    String owner = 'Shared',
    DateTime? timestamp,
  }) {
    return createFromCatalog(
      product: product,
      owner: owner,
      isWishlist: true,
      quantity: 1,
      timestamp: timestamp,
    );
  }

  static String _defaultText(String value, {required String fallback}) {
    final String normalized = value.trim();

    if (normalized.isEmpty) {
      return fallback;
    }

    return normalized;
  }

  static String _resolveCatalogIdentity({
    required String selectedValue,
    required String catalogValue,
    required String fallback,
  }) {
    final String normalizedSelection = selectedValue.trim();

    final bool selectionIsDefault =
        normalizedSelection.isEmpty ||
        normalizedSelection.toLowerCase() == 'none';

    if (!selectionIsDefault) {
      return normalizedSelection;
    }

    final String normalizedCatalogValue = catalogValue.trim();

    if (normalizedCatalogValue.isNotEmpty &&
        normalizedCatalogValue.toLowerCase() != 'none') {
      return normalizedCatalogValue;
    }

    return fallback;
  }
}
