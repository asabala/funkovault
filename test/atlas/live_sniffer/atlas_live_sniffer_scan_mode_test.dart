import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/live_sniffer/models/atlas_live_sniffer_scan_mode.dart';

void main() {
  test('auction modes support automatic one-or-all choice', () {
    expect(AtlasLiveSnifferScanMode.automatic.label, 'Auto');
    expect(AtlasLiveSnifferScanMode.featured.label, 'Featured Pop');
    expect(AtlasLiveSnifferScanMode.allVisible.label, 'All Visible');
    expect(AtlasLiveSnifferScanMode.automatic.description, contains('ask'));
    expect(AtlasLiveSnifferScanMode.featured.description, contains('retarget'));
    expect(
      AtlasLiveSnifferScanMode.allVisible.description,
      contains('parallel'),
    );
  });
}
