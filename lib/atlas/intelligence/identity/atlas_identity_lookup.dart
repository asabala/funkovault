import '../event/funko_event.dart';
import '../registry/atlas_registry.dart';
import '../registry/atlas_registry_domain.dart';
import '../retailer/funko_retailer.dart';
import '../sticker/funko_sticker_type.dart';
import '../variant/atlas_variant_type.dart';

// Provides a single access point for Atlas identity lookups.
//
// Detectors depend on this class rather than AtlasRegistry directly.
// Future improvements such as OCR cleanup, fuzzy matching, aliases,
// confidence scoring, and typo correction can be implemented here
// without changing detector code.
final class AtlasIdentityLookup {
  const AtlasIdentityLookup(this._registry);

  final AtlasRegistry _registry;

  AtlasVariantType? variant(String value) {
    return _resolve<AtlasVariantType>(
      domain: AtlasRegistryDomain.variant,
      value: value,
      fromCode: AtlasVariantType.fromCode,
      isUnknown: (variant) {
        return variant == AtlasVariantType.unknown;
      },
    );
  }

  FunkoRetailer? retailer(String value) {
    return _resolve<FunkoRetailer>(
      domain: AtlasRegistryDomain.retailer,
      value: value,
      fromCode: FunkoRetailer.fromCode,
      isUnknown: (retailer) {
        return retailer == FunkoRetailer.unknown;
      },
    );
  }

  FunkoStickerType? sticker(String value) {
    return _resolve<FunkoStickerType>(
      domain: AtlasRegistryDomain.sticker,
      value: value,
      fromCode: FunkoStickerType.fromCode,
      isUnknown: (sticker) {
        return sticker == FunkoStickerType.unknown;
      },
    );
  }

  FunkoEvent? event(String value) {
    return _resolve<FunkoEvent>(
      domain: AtlasRegistryDomain.event,
      value: value,
      fromCode: FunkoEvent.fromCode,
      isUnknown: (event) {
        return event == FunkoEvent.unknown;
      },
    );
  }

  T? _resolve<T>({
    required AtlasRegistryDomain domain,
    required String value,
    required T Function(String code) fromCode,
    required bool Function(T result) isUnknown,
  }) {
    final entry = _registry.firstByDomain(
      domain,
      value,
    );

    if (entry == null) {
      return null;
    }

    final T result = fromCode(
      entry.id,
    );

    if (isUnknown(result)) {
      return null;
    }

    return result;
  }
}