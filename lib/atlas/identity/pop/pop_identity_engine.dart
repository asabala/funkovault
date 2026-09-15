import '../../../models/pop.dart';
import 'pop_identity_rule.dart';
import 'pop_identity_rules.dart';

class PopIdentityEngine {
  const PopIdentityEngine();

  List<PopIdentityBadgeData> buildBadges(Pop pop) {
    final List<PopIdentityBadgeData> badges = <PopIdentityBadgeData>[];

    final Set<String> addedIds = <String>{};
    final Set<String> addedLabels = <String>{};

    void addBadge({
      required String id,
      required String emoji,
      required String label,
    }) {
      final String cleanedLabel = _cleanLabel(label);

      if (!_hasMeaningfulValue(cleanedLabel)) {
        return;
      }

      final String normalizedId = id.trim().toLowerCase();

      final String normalizedLabel = cleanedLabel.toLowerCase();

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

    final String retailExclusive = _cleanLabel(pop.retailExclusive);

    final String eventSticker = _cleanLabel(pop.eventSticker);

    final String limitedEdition = _cleanLabel(pop.limitedEdition);

    final String signature = _cleanLabel(pop.signature);

    final String variant = _cleanLabel(pop.variant);

    final String collectorLabel = _cleanLabel(pop.collectorLabel);

    final bool hasRetailExclusive = _hasMeaningfulValue(retailExclusive);

    final bool hasEventSticker = _hasMeaningfulValue(eventSticker);

    final bool hasLimitedEdition = _hasMeaningfulValue(limitedEdition);

    final bool hasSignature = _hasMeaningfulValue(signature);

    final bool hasVariant = _hasMeaningfulValue(variant);

    // Direct fields remain authoritative.
    if (hasRetailExclusive) {
      addBadge(
        id: 'retail_exclusive',
        emoji: '🏪',
        label: _exclusiveLabel(retailExclusive),
      );
    }

    if (hasEventSticker) {
      addBadge(id: 'event_sticker', emoji: '🎟️', label: eventSticker);
    }

    if (hasLimitedEdition) {
      addBadge(
        id: 'limited_edition',
        emoji: '🏆',
        label: _limitedEditionLabel(limitedEdition),
      );
    }

    if (hasSignature) {
      addBadge(id: 'signed', emoji: '🖋️', label: _signatureLabel(signature));
    }

    bool variantMatchedKnownRule = false;

    for (final PopIdentityRule rule in PopIdentityRules.all) {
      final bool matchesRule = _ruleMatchesPop(
        rule: rule,
        variant: variant,
        retailExclusive: retailExclusive,
        eventSticker: eventSticker,
        limitedEdition: limitedEdition,
        signature: signature,
        collectorLabel: collectorLabel,
      );

      if (!matchesRule) {
        continue;
      }

      if (rule.targets(PopIdentityScope.variant) && rule.matches(variant)) {
        variantMatchedKnownRule = true;
      }

      addBadge(id: rule.id, emoji: rule.emoji, label: rule.label);
    }

    if (hasVariant && !variantMatchedKnownRule) {
      addBadge(id: 'custom_variant', emoji: '🧬', label: variant);
    }

    final String exclusiveText = <String>[
      retailExclusive,
      eventSticker,
      variant,
    ].join(' ').toLowerCase();

    final bool hasKnownRetailer = PopIdentityRules.knownRetailers.any((
      String retailer,
    ) {
      return exclusiveText.contains(retailer.toLowerCase());
    });

    final bool hasSpecificExclusive = hasRetailExclusive || hasKnownRetailer;

    if (!hasSpecificExclusive && exclusiveText.contains('exclusive')) {
      addBadge(id: 'exclusive', emoji: '⭐', label: 'Exclusive');
    }

    if (pop.isWishlist) {
      addBadge(id: 'wishlist', emoji: '❤️', label: 'Wishlist');
    }

    return List<PopIdentityBadgeData>.unmodifiable(badges);
  }

  bool _ruleMatchesPop({
    required PopIdentityRule rule,
    required String variant,
    required String retailExclusive,
    required String eventSticker,
    required String limitedEdition,
    required String signature,
    required String collectorLabel,
  }) {
    final Map<PopIdentityScope, String> scopedValues =
        <PopIdentityScope, String>{
          PopIdentityScope.variant: variant,
          PopIdentityScope.retailExclusive: retailExclusive,
          PopIdentityScope.eventSticker: eventSticker,
          PopIdentityScope.limitedEdition: limitedEdition,
          PopIdentityScope.signature: signature,
          PopIdentityScope.collectorLabel: collectorLabel,
        };

    for (final PopIdentityScope scope in rule.targetScopes) {
      final String scopedValue = scopedValues[scope] ?? '';

      if (!_hasMeaningfulValue(scopedValue)) {
        continue;
      }

      if (rule.matches(scopedValue)) {
        return true;
      }
    }

    return false;
  }

  String _exclusiveLabel(String value) {
    final String cleaned = _cleanLabel(value);

    final String normalized = cleaned.toLowerCase();

    if (normalized == 'exclusive' ||
        normalized == 'retail exclusive' ||
        normalized == 'yes' ||
        normalized == 'true') {
      return 'Exclusive';
    }

    return cleaned;
  }

  String _limitedEditionLabel(String value) {
    final String cleaned = _cleanLabel(value);

    final String normalized = cleaned.toLowerCase();

    if (normalized == 'limited' ||
        normalized == 'limited edition' ||
        normalized == 'yes' ||
        normalized == 'true') {
      return 'Limited Edition';
    }

    return cleaned;
  }

  String _signatureLabel(String value) {
    final String cleaned = _cleanLabel(value);

    final String normalized = cleaned.toLowerCase();

    if (normalized == 'signed' ||
        normalized == 'signature' ||
        normalized == 'autographed' ||
        normalized == 'autograph' ||
        normalized == 'yes' ||
        normalized == 'true') {
      return 'Signed';
    }

    return cleaned;
  }

  bool _hasMeaningfulValue(String value) {
    final String cleaned = value.trim().toLowerCase();

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
        .replaceAll(RegExp(r'^[-–—\s]+|[-–—\s]+$'), '');
  }
}
