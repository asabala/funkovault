import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/intelligence/event/funko_event.dart';
import 'package:funkovault2/atlas/intelligence/identity/atlas_identity_analysis_engine.dart';
import 'package:funkovault2/atlas/intelligence/retailer/funko_retailer.dart';
import 'package:funkovault2/atlas/intelligence/sticker/funko_sticker_type.dart';
import 'package:funkovault2/atlas/intelligence/variant/atlas_variant_type.dart';

void main() {
  group('AtlasIdentityAnalysisEngine', () {
    final AtlasIdentityAnalysisEngine engine =
        AtlasIdentityAnalysisEngine.create();

    test('detects glow variant', () {
      final result = engine.analyze('Batman #01 Glow in the Dark');

      expect(result.variantResult.contains(AtlasVariantType.glow), isTrue);
    });

    test('detects chase variant', () {
      final result = engine.analyze('Batman #01 Chase');

      expect(result.variantResult.contains(AtlasVariantType.chase), isTrue);
    });

    test('returns no variants for a standard product', () {
      final result = engine.analyze('Batman #01');

      expect(result.variantResult.hasVariants, isFalse);
    });

    test('detects Hot Topic retailer', () {
      final result = engine.analyze('Batman #01 Hot Topic Exclusive');

      expect(result.retailerResult.contains(FunkoRetailer.hotTopic), isTrue);
    });

    test('detects Entertainment Earth alias', () {
      final result = engine.analyze('Batman #01 EE Exclusive');

      expect(
        result.retailerResult.contains(FunkoRetailer.entertainmentEarth),
        isTrue,
      );
    });

    test('detects Pokemon Center retailer', () {
      final result = engine.analyze('Pikachu #353 Pokemon Center');

      expect(
        result.retailerResult.contains(FunkoRetailer.pokemonCenter),
        isTrue,
      );
    });

    test('does not treat Funko brand text as Funko Shop', () {
      final result = engine.analyze('Funko Pop Batman #01');

      expect(result.retailerResult.contains(FunkoRetailer.funkoShop), isFalse);
    });

    test('returns no retailer for a standard product', () {
      final result = engine.analyze('Batman #01');

      expect(result.retailerResult.hasRetailers, isFalse);
    });

    test('detects variant and retailer together', () {
      final result = engine.analyze('Batman #01 Hot Topic Glow Exclusive');

      expect(result.variantResult.contains(AtlasVariantType.glow), isTrue);

      expect(result.retailerResult.contains(FunkoRetailer.hotTopic), isTrue);

      expect(result.hasFindings, isTrue);
    });

    test('detects Special Edition sticker', () {
      final result = engine.analyze('Batman #01 Special Edition');

      expect(
        result.stickerResult.contains(FunkoStickerType.specialEdition),
        isTrue,
      );
    });

    test('detects Shared Convention sticker', () {
      final result = engine.analyze('Batman #01 Shared Convention');

      expect(
        result.stickerResult.contains(FunkoStickerType.sharedConvention),
        isTrue,
      );
    });

    test('detects Official Convention sticker', () {
      final result = engine.analyze('Batman #01 Official Convention');

      expect(
        result.stickerResult.contains(FunkoStickerType.officialConvention),
        isTrue,
      );
    });

    test('detects SDCC event', () {
      final result = engine.analyze('Batman #01 SDCC');

      expect(result.eventResult.contains(FunkoEvent.sdcc), isTrue);
    });

    test('detects NYCC event', () {
      final result = engine.analyze('Batman #01 New York Comic Con');

      expect(result.eventResult.contains(FunkoEvent.nycc), isTrue);
    });

    test('detects Funko Fundays event', () {
      final result = engine.analyze('Batman #01 Funko Fundays');

      expect(result.eventResult.contains(FunkoEvent.fundays), isTrue);
    });

    test('detects variant, retailer, sticker and event together', () {
      final result = engine.analyze(
        'Batman #01 SDCC Hot Topic Glow Special Edition',
      );

      expect(result.variantResult.contains(AtlasVariantType.glow), isTrue);

      expect(result.retailerResult.contains(FunkoRetailer.hotTopic), isTrue);

      expect(
        result.stickerResult.contains(FunkoStickerType.specialEdition),
        isTrue,
      );

      expect(result.eventResult.contains(FunkoEvent.sdcc), isTrue);

      expect(result.hasFindings, isTrue);
    });
  });
}
