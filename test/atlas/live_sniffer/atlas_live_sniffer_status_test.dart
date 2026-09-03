import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/live_sniffer/atlas_live_sniffer_status.dart';

void main() {
  test('parses native status map', () {
    final status = AtlasLiveSnifferStatus.fromMap(<Object?, Object?>{
      'supported': true,
      'overlayPermissionGranted': true,
      'notificationPermissionGranted': true,
      'isCapturing': true,
      'isOverlayVisible': true,
      'lastError': ' ',
    });

    expect(status.supported, isTrue);
    expect(status.isReadyToStart, isTrue);
    expect(status.isCapturing, isTrue);
    expect(status.isOverlayVisible, isTrue);
    expect(status.lastError, isNull);
  });
}
