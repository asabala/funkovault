import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/live_sniffer/atlas_live_sniffer_recognition_bridge.dart';
import 'package:funkovault2/atlas/live_sniffer/atlas_live_sniffer_recognition_controller.dart';
import 'package:funkovault2/atlas/live_sniffer/models/atlas_live_sniffer_scan_mode.dart';

final class _FakeRecognitionPlatform
    implements AtlasLiveSnifferRecognitionPlatform {
  final StreamController<Map<Object?, Object?>> controller =
      StreamController<Map<Object?, Object?>>.broadcast();
  final List<String> hudUpdates = <String>[];

  @override
  Stream<Map<Object?, Object?>> get frames => controller.stream;

  @override
  Future<void> updateHud(
    String text, {
    bool showScanChoices = false,
    int detectedCount = 0,
  }) async {
    hudUpdates.add(text);
  }

  Future<void> dispose() => controller.close();
}

void main() {
  test('session starts auction HUD and can stop cleanly', () async {
    final _FakeRecognitionPlatform platform = _FakeRecognitionPlatform();
    final AtlasLiveSnifferRecognitionController controller =
        AtlasLiveSnifferRecognitionController(platform: platform);

    controller.startSession(
      collectionName: 'Arthur Collection',
      collectionPops: const [],
    );
    await Future<void>.delayed(Duration.zero);

    expect(controller.sessionActive, isTrue);
    expect(platform.hudUpdates.last, contains('Auction Fast Mode'));

    await controller.stopSession();
    expect(controller.sessionActive, isFalse);

    controller.dispose();
    await platform.dispose();
  });

  test('scan mode can change before session but not while live', () async {
    final _FakeRecognitionPlatform platform = _FakeRecognitionPlatform();
    final AtlasLiveSnifferRecognitionController controller =
        AtlasLiveSnifferRecognitionController(platform: platform);

    controller.setScanMode(AtlasLiveSnifferScanMode.allVisible);
    expect(controller.scanMode, AtlasLiveSnifferScanMode.allVisible);

    controller.startSession(
      collectionName: 'Arthur Collection',
      collectionPops: const [],
    );
    controller.setScanMode(AtlasLiveSnifferScanMode.featured);
    expect(controller.scanMode, AtlasLiveSnifferScanMode.allVisible);

    await controller.stopSession();
    controller.dispose();
    await platform.dispose();
  });

  test(
    'target selection pauses recognition until the user taps a Pop',
    () async {
      final _FakeRecognitionPlatform platform = _FakeRecognitionPlatform();
      final AtlasLiveSnifferRecognitionController controller =
          AtlasLiveSnifferRecognitionController(platform: platform);

      controller.startSession(
        collectionName: 'Arthur Collection',
        collectionPops: const [],
      );
      platform.controller.add(<Object?, Object?>{
        'type': 'control',
        'action': 'targetSelectionStarted',
      });
      await Future<void>.delayed(Duration.zero);

      expect(controller.scanMode, AtlasLiveSnifferScanMode.featured);
      expect(controller.hud.toOverlayText(), contains('Tap the Pop'));
      expect(controller.hud.toOverlayText(), contains('paused'));

      await controller.stopSession();
      controller.dispose();
      await platform.dispose();
    },
  );

  test(
    'target tap locks featured mode and clears automatic choice state',
    () async {
      final _FakeRecognitionPlatform platform = _FakeRecognitionPlatform();
      final AtlasLiveSnifferRecognitionController controller =
          AtlasLiveSnifferRecognitionController(platform: platform);

      controller.startSession(
        collectionName: 'Arthur Collection',
        collectionPops: const [],
      );
      platform.controller.add(<Object?, Object?>{
        'type': 'control',
        'action': 'targetTap',
        'x': 0.52,
        'y': 0.58,
      });
      await Future<void>.delayed(Duration.zero);

      expect(controller.scanMode, AtlasLiveSnifferScanMode.featured);
      expect(controller.hud.toOverlayText(), contains('Target selected'));
      expect(controller.hud.toOverlayText(), contains('only this target'));

      await controller.stopSession();
      controller.dispose();
      await platform.dispose();
    },
  );

  test(
    'starting a new session replaces prior read-only pipeline state',
    () async {
      final _FakeRecognitionPlatform platform = _FakeRecognitionPlatform();
      final AtlasLiveSnifferRecognitionController controller =
          AtlasLiveSnifferRecognitionController(platform: platform);

      controller.startSession(
        collectionName: 'Arthur Collection',
        collectionPops: const [],
      );
      controller.startSession(
        collectionName: 'Entire Family Collection',
        collectionPops: const [],
      );
      await Future<void>.delayed(Duration.zero);

      expect(controller.sessionActive, isTrue);
      expect(controller.hud.toOverlayText(), contains('Auction Fast Mode'));

      await controller.stopSession();
      controller.dispose();
      await platform.dispose();
    },
  );

  test('Fix 6 ignores stale selection generations', () async {
    final _FakeRecognitionPlatform platform = _FakeRecognitionPlatform();
    final AtlasLiveSnifferRecognitionController controller =
        AtlasLiveSnifferRecognitionController(platform: platform);

    controller.startSession(
      collectionName: 'Arthur Collection',
      collectionPops: const [],
    );
    platform.controller.add(<Object?, Object?>{
      'type': 'control',
      'action': 'targetTap',
      'x': 0.5,
      'y': 0.5,
      'selectionGeneration': 9,
    });
    await Future<void>.delayed(Duration.zero);

    platform.controller.add(<Object?, Object?>{
      'type': 'frame',
      'capturedAtMicros': 1700000000250000,
      'frameSequence': 10,
      'selectionGeneration': 8,
      'targetState': 'lost',
      'barcodes': const <Object?>[],
      'textBlocks': const <Object?>[],
    });
    await Future<void>.delayed(Duration.zero);

    expect(controller.hud.toOverlayText(), contains('Target selected'));
    expect(controller.hud.toOverlayText(), isNot(contains('Target lost')));

    await controller.stopSession();
    controller.dispose();
    await platform.dispose();
  });

  test(
    'Fix 6 target loss waits for retap and never switches to Scan All',
    () async {
      final _FakeRecognitionPlatform platform = _FakeRecognitionPlatform();
      final AtlasLiveSnifferRecognitionController controller =
          AtlasLiveSnifferRecognitionController(platform: platform);

      controller.startSession(
        collectionName: 'Arthur Collection',
        collectionPops: const [],
      );
      platform.controller.add(<Object?, Object?>{
        'type': 'control',
        'action': 'targetTap',
        'x': 0.52,
        'y': 0.58,
        'selectionGeneration': 12,
      });
      await Future<void>.delayed(Duration.zero);

      platform.controller.add(<Object?, Object?>{
        'type': 'frame',
        'capturedAtMicros': 1700000000500000,
        'frameSequence': 20,
        'selectionGeneration': 12,
        'targetState': 'lost',
        'barcodes': const <Object?>[],
        'textBlocks': const <Object?>[],
      });
      await Future<void>.delayed(Duration.zero);

      expect(controller.scanMode, AtlasLiveSnifferScanMode.featured);
      expect(controller.hud.toOverlayText(), contains('Target lost'));
      expect(controller.hud.toOverlayText(), contains('tap'));

      await controller.stopSession();
      controller.dispose();
      await platform.dispose();
    },
  );

  test('Fix 6 drops out-of-order frame sequence', () async {
    final _FakeRecognitionPlatform platform = _FakeRecognitionPlatform();
    final AtlasLiveSnifferRecognitionController controller =
        AtlasLiveSnifferRecognitionController(platform: platform);

    controller.startSession(
      collectionName: 'Arthur Collection',
      collectionPops: const [],
    );
    platform.controller.add(<Object?, Object?>{
      'type': 'control',
      'action': 'targetTap',
      'x': 0.5,
      'y': 0.5,
      'selectionGeneration': 15,
    });
    await Future<void>.delayed(Duration.zero);

    platform.controller.add(<Object?, Object?>{
      'type': 'frame',
      'capturedAtMicros': 1700000001000000,
      'frameSequence': 40,
      'selectionGeneration': 15,
      'targetState': 'coasting',
      'barcodes': const <Object?>[],
      'textBlocks': const <Object?>[],
    });
    await Future<void>.delayed(Duration.zero);
    expect(controller.hud.toOverlayText(), contains('Tracking selected Pop'));

    platform.controller.add(<Object?, Object?>{
      'type': 'frame',
      'capturedAtMicros': 1700000001250000,
      'frameSequence': 39,
      'selectionGeneration': 15,
      'targetState': 'lost',
      'barcodes': const <Object?>[],
      'textBlocks': const <Object?>[],
    });
    await Future<void>.delayed(Duration.zero);

    expect(controller.hud.toOverlayText(), contains('Tracking selected Pop'));
    expect(controller.hud.toOverlayText(), isNot(contains('Target lost')));

    await controller.stopSession();
    controller.dispose();
    await platform.dispose();
  });
}
