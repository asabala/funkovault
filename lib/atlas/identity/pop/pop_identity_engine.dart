import '../../../models/pop.dart';
import 'pop_identity_rule.dart';
import 'pop_identity_rules.dart';

class PopIdentityEngine {
  const PopIdentityEngine();

  List<PopIdentityBadgeData> buildBadges(Pop pop) {
    final badges = <PopIdentityBadgeData>[];
    final addedIds = <String>{};
    final addedLabels = <String>{};

    void addBadge({
      required String id,
      required String emoji,
      required String label,
    }) {
      final cleanedLabel = _cleanLabel(label);

      if (!_hasMeaningfulValue(cleanedLabel)) {
        return;
      }

      final normalizedId = id.trim().toLowerCase();
      final normalizedLabel = cleanedLabel.toLowerCase();

      if (addedIds.contains(normalizedId) ||
          addedLabels.contains(normalizedLabel)) {
        return;
      }

      addedIds.add(normalizedId);
      addedLabels.add(normalizedLabel);

      badges.add(
        PopIdentityBadgeData(
          id: normalizedId,
          emoji: emoji,
          label: cleanedLabel,
        ),
      );
    }

    final retailExclusive = _cleanLabel(pop.retailExclusive);
    final eventSticker = _cleanLabel(pop.eventSticker);
    final limitedEdition = _cleanLabel(pop.limitedEdition);
    final signature = _cleanLabel(pop.signature);
    final variant = _cleanLabel(pop.variant);

    final hasRetailExclusive = _hasMeaningfulValue(retailExclusive);
    final hasEventSticker = _hasMeaningfulValue(eventSticker);
    final hasLimitedEdition = _hasMeaningfulValue(limitedEdition);
    final hasSignature = _hasMeaningfulValue(signature);
    final hasVariant = _hasMeaningfulValue(variant);

    final combinedIdentityText = [
      pop.collectorLabel,
      retailExclusive,
      eventSticker,
      limitedEdition,
      signature,
      variant,
    ].join(' ').toLowerCase();

    if (hasRetailExclusive) {
      addBadge(
        id: 'retail_exclusive',
        emoji: '🏪',
        label: _exclusiveLabel(retailExclusive),
      );
    }

    if (hasEventSticker) {
      addBadge(
        id: 'event_sticker',
        emoji: '🎟️',
        label: eventSticker,
      );
    }

    if (hasLimitedEdition) {
      addBadge(
        id: 'limited_edition',
        emoji: '🏆',
        label: _limitedEditionLabel(limitedEdition),
      );
    }

    if (hasSignature) {
      addBadge(
        id: 'signed',
        emoji: '🖋️',
        label: _signatureLabel(signature),
      );
    }

    var variantMatchedKnownRule = false;

    for (final rule in PopIdentityRules.all) {
      final matchesCombinedText = rule.matches(combinedIdentityText);

      if (!matchesCombinedText) {
        continue;
      }

      if (rule.id == 'funko_shop' && hasRetailExclusive) {
        continue;
      }

      if (rule.id == 'limited_edition' && hasLimitedEdition) {
        continue;
      }

      if (rule.id == 'signed' && hasSignature) {
        continue;
      }

      if (hasVariant && rule.matches(variant)) {
        variantMatchedKnownRule = true;
      }

      addBadge(
        id: rule.id,
        emoji: rule.emoji,
        label: rule.label,
      );
    }

    if (hasVariant && !variantMatchedKnownRule) {
      addBadge(
        id: 'custom_variant',
        emoji: '🧬',
        label: variant,
      );
    }

    final hasKnownRetailer = PopIdentityRules.knownRetailers.any(
      combinedIdentityText.contains,
    );

    final hasSpecificExclusive =
        hasRetailExclusive || hasKnownRetailer;

    if (!hasSpecificExclusive &&
        combinedIdentityText.contains('exclusive')) {
      addBadge(
        id: 'exclusive',
        emoji: '⭐',
        label: 'Exclusive',
      );
    }

    if (pop.isWishlist) {
      addBadge(
        id: 'wishlist',
        emoji: '❤️',
        label: 'Wishlist',
      );
    }

    return List<PopIdentityBadgeData>.unmodifiable(badges);
  }

  String _exclusiveLabel(String value) {
    final cleaned = _cleanLabel(value);
    final normalized = cleaned.toLowerCase();

    if (normalized == 'exclusive' ||
        normalized == 'retail exclusive' ||
        normalized == 'yes' ||
        normalized == 'true') {
      return 'Exclusive';
    }

    return cleaned;
  }

  String _limitedEditionLabel(String value) {
    final cleaned = _cleanLabel(value);
    final normalized = cleaned.toLowerCase();

    if (normalized == 'limited' ||
        normalized == 'limited edition' ||
        normalized == 'yes' ||
        normalized == 'true') {
      return 'Limited Edition';
    }

    return cleaned;
  }

  String _signatureLabel(String value) {
    final cleaned = _cleanLabel(value);
    final normalized = cleaned.toLowerCase();

    if (normalized == 'signed' ||
        normalized == 'signature' ||
        normalized == 'autographed' ||
        normalized == 'yes' ||
        normalized == 'true') {
      return 'Signed';
    }

    return cleaned;
  }

  bool _hasMeaningfulValue(String value) {
    final cleaned = value.trim().toLowerCase();

    if (cleaned.isEmpty) {
      return false;
    }

    return cleaned != 'none' &&
        cleaned != 'common' &&
        cleaned != 'standard' &&
        cleaned != 'unsigned' &&
        cleaned != 'no' &&
        cleaned != 'false' &&
        cleaned != 'n/a' &&
        cleaned != 'na' &&
        cleaned != 'not entered' &&
        cleaned != 'unknown';
  }

  String _cleanLabel(String value) {
    return value
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(
      RegExp(r'^[-–—\s]+|[-–—\s]+$'),
      '',
    );
  }
}