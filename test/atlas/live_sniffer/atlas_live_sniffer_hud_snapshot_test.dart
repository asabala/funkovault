import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/live_sniffer/models/atlas_live_sniffer_hud_snapshot.dart';

void main() {
  test('overlay text includes cached value when available', () {
    const AtlasLiveSnifferHudSnapshot snapshot = AtlasLiveSnifferHudSnapshot(
      state: AtlasLiveSnifferHudState.owned,
      title: 'Freddy Funko #01',
      statusLabel: 'OWNED x1',
      cachedValue: 85,
    );

    expect(
      snapshot.toOverlayText(),
      'ATLAS LIVELENS\nFreddy Funko #01\nPPG: \$85\nHave: YES',
    );
  });

  test('overlay text does not invent unavailable price fields', () {
    const AtlasLiveSnifferHudSnapshot snapshot = AtlasLiveSnifferHudSnapshot(
      state: AtlasLiveSnifferHudState.possibleVariant,
      title: 'Possible Match',
      statusLabel: 'POSSIBLE VARIANT',
      detail: 'Review in Atlas',
    );

    final String text = snapshot.toOverlayText();

    expect(text, contains('Have: REVIEW'));
    expect(text, contains('Status: Review variant'));
    expect(text, isNot(contains('Target')));
    expect(text, isNot(contains('Current Bid')));
  });
}
