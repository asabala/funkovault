import '../../knowledge/atlas_collector_rules.dart';

class AtlasInsight {
  const AtlasInsight({required this.title, required this.message});

  final String title;
  final String message;
}

class AtlasInsightEngine {
  const AtlasInsightEngine();

  AtlasInsight buildCollectorIdentityInsight({
    required String variant,
    required String retailExclusive,
    required String eventSticker,
    required String limitedEdition,
    required String signature,
  }) {
    if (signature != 'Unsigned') {
      if (AtlasCollectorRules.isAuthenticated(signature)) {
        return const AtlasInsight(
          title: 'Authenticated Signature Detected',
          message:
              'Atlas recognizes this as an authenticated signed collectible. Signed Pops are tracked separately from unsigned versions.',
        );
      }

      return const AtlasInsight(
        title: 'Signed Collectible Detected',
        message:
            'Signed Pops are part of collector identity. Atlas will treat this differently from an unsigned version.',
      );
    }

    if (AtlasCollectorRules.isLimitedEdition(limitedEdition)) {
      return const AtlasInsight(
        title: 'Limited Edition Detected',
        message:
            'Limited Edition Pops are part of collector identity. Atlas will distinguish this from a standard release.',
      );
    }

    if (AtlasCollectorRules.isConventionSticker(eventSticker)) {
      return const AtlasInsight(
        title: 'Convention Sticker Detected',
        message:
            'Convention stickers matter. Atlas will distinguish event stickers from shared or standard releases.',
      );
    }

    if (eventSticker == 'Shared Exclusive') {
      return const AtlasInsight(
        title: 'Shared Exclusive Detected',
        message:
            'Shared Exclusives may look similar to convention releases, but Atlas tracks them separately.',
      );
    }

    if (AtlasCollectorRules.isExclusive(retailExclusive)) {
      return const AtlasInsight(
        title: 'Retail Exclusive Detected',
        message:
            'Retail exclusives are tracked separately so Atlas can prevent false duplicates and improve search later.',
      );
    }

    if (AtlasCollectorRules.isRareVariant(variant)) {
      return const AtlasInsight(
        title: 'Rare Variant Detected',
        message:
            'Variants such as Chase, Glow, Flocked, Metallic, and Blacklight are tracked separately from Common Pops.',
      );
    }

    return const AtlasInsight(
      title: 'Collector Identity Matters',
      message:
          'Variant, retail exclusive, event sticker, limited edition, and signature help Atlas tell similar Pops apart.',
    );
  }
}
