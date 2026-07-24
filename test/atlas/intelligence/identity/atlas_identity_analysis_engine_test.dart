import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/intelligence/funko/retailer/funko_retailer.dart';
import 'package:funkovault2/atlas/intelligence/funko/sticker/funko_sticker_type.dart';
import 'package:funkovault2/atlas/intelligence/identity/atlas_identity_analysis_engine.dart';
import 'package:funkovault2/atlas/intelligence/variant/atlas_variant_type.dart';

void main() {
  group('AtlasIdentityAnalysisEngine', () {
    final AtlasIdentityAnalysisEngine engine =
    AtlasIdentityAnalysisEngine();

    test('detects glow variant', () {
      final result = engine.analyze(
        'Batman #01 Glow in the Dark',
      );

      expect(
        result.variantResult.contains(
          AtlasVariantType.glow,
        ),
        isTrue,
      );
    });

    test('detects chase variant', () {
      final result = engine.analyze(
        'Batman #01 Chase',
      );

      expect(
        result.variantResult.contains(
          AtlasVariantType.chase,
        ),
        isTrue,
      );
    });

    test(
      'returns no variants for a standard product',
          () {
        final result = engine.analyze(
          'Batman #01',
        );

        expect(
          result.variantResult.hasVariants,
          isFalse,
        );
      },
    );

    test('detects Hot Topic retailer', () {
      final result = engine.analyze(
        'Batman #01 Hot Topic Exclusive',
      );

      expect(
        result.retailerResult.contains(
          FunkoRetailer.hotTopic,
        ),
        isTrue,
      );
    });

    test(
      'detects Entertainment Earth alias',
          () {
        final result = engine.analyze(
          'Batman #01 EE Exclusive',
        );

        expect(
          result.retailerResult.contains(
            FunkoRetailer.entertainmentEarth,
          ),
          isTrue,
        );
      },
    );

    test('detects Pokemon Center retailer', () {
      final result = engine.analyze(
        'Pikachu #353 Pokemon Center',
      );

      expect(
        result.retailerResult.contains(
          FunkoRetailer.pokemonCenter,
        ),
        isTrue,
      );
    });

    test(
      'does not treat Funko brand text as Funko Shop',
          () {
        final result = engine.analyze(
          'Funko Pop Batman #01',
        );

        expect(
          result.retailerResult.contains(
            FunkoRetailer.funkoShop,
          ),
          isFalse,
        );
      },
    );

    test(
      'returns no retailer for a standard product',
          () {
        final result = engine.analyze(
          'Batman #01',
        );

        expect(
          result.retailerResult.hasRetailers,
          isFalse,
        );
      },
    );

    test(
      'detects variant and retailer together',
          () {
        final result = engine.analyze(
          'Batman #01 Hot Topic Glow Exclusive',
        );

        expect(
          result.variantResult.contains(
            AtlasVariantType.glow,
          ),
          isTrue,
        );

        expect(
          result.retailerResult.contains(
            FunkoRetailer.hotTopic,
          ),
          isTrue,
        );

        expect(
          result.hasFindings,
          isTrue,
        );
      },
    );

    test('detects Special Edition sticker', () {
      final result = engine.analyze(
        'Batman #01 Special Edition',
      );

      expect(
        result.stickerResult.contains(
          FunkoStickerType.specialEdition,
        ),
        isTrue,
      );
    });

    test('detects Shared Exclusive sticker', () {
      final result = engine.analyze(
        'Batman #01 Shared Exclusive',
      );

      expect(
        result.stickerResult.contains(
          FunkoStickerType.sharedConvention,
        ),
        isTrue,
      );
    });

    test('detects Official Convention sticker', () {
      final result = engine.analyze(
        'Batman #01 Official Convention Exclusive',
      );

      expect(
        result.stickerResult.contains(
          FunkoStickerType.officialConvention,
        ),
        isTrue,
      );
    });
  });
}