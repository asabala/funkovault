import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/live_sniffer/recognition/atlas_live_sniffer_identity_gate.dart';

void main() {
  group('AtlasLiveSnifferIdentityGate', () {
    test('rejects Oz #127 when OCR belongs to Tokyo Ghoul #1127', () {
      final evidence = AtlasLiveSnifferIdentityGate.evaluate(
        rawOcr: 'POP ANIMATION TOKYO GHOUL 127 THE',
        displayName: 'Buffy the Vampire Slayer: Oz',
        characterName: 'Oz',
        series: 'Buffy the Vampire Slayer',
        productLine: 'Pop! Television',
      );

      expect(evidence.validated, isFalse);
      expect(evidence.identityHits, 0);
    });

    test('accepts Toru Mutsuki when Tokyo Ghoul identity text is present', () {
      final evidence = AtlasLiveSnifferIdentityGate.evaluate(
        rawOcr: 'POP ANIMATION TOKYO GHOUL 1127',
        displayName: 'Tokyo Ghoul: Toru Mutsuki',
        characterName: 'Toru Mutsuki',
        series: 'Tokyo Ghoul',
        productLine: 'Pop! Animation',
      );

      expect(evidence.validated, isTrue);
      expect(evidence.identityHits, greaterThanOrEqualTo(2));
    });

    test('common word the cannot authorize a catalog identity', () {
      final evidence = AtlasLiveSnifferIdentityGate.evaluate(
        rawOcr: 'POP TELEVISION THE 127',
        displayName: 'Buffy the Vampire Slayer: Oz',
        characterName: 'Oz',
        series: 'Buffy the Vampire Slayer',
        productLine: 'Pop! Television',
      );

      expect(evidence.validated, isFalse);
    });

    test('real Oz and Buffy text can authorize Oz #127', () {
      final evidence = AtlasLiveSnifferIdentityGate.evaluate(
        rawOcr: 'BUFFY OZ 127',
        displayName: 'Buffy the Vampire Slayer: Oz',
        characterName: 'Oz',
        series: 'Buffy the Vampire Slayer',
        productLine: 'Pop! Television',
      );

      expect(evidence.validated, isTrue);
    });

    test('distinctive single-name Pop can still validate', () {
      final evidence = AtlasLiveSnifferIdentityGate.evaluate(
        rawOcr: 'SHREDDER 35',
        displayName: 'Shredder',
      );

      expect(evidence.validated, isTrue);
    });

    test('number and packaging words alone remain unresolved', () {
      final evidence = AtlasLiveSnifferIdentityGate.evaluate(
        rawOcr: 'FUNKO POP VINYL FIGURE 389',
        displayName: 'Yu-Gi-Oh!: Blue-Eyes White Dragon',
        characterName: 'Blue-Eyes White Dragon',
        series: 'Yu-Gi-Oh!',
        productLine: 'Pop! Animation',
      );

      expect(evidence.validated, isFalse);
    });
  });
}
