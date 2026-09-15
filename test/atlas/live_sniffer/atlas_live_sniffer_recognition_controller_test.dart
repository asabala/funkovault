import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/live_sniffer/atlas_live_sniffer_recognition_bridge.dart';
import 'package:funkovault2/atlas/live_sniffer/atlas_live_sniffer_recognition_controller.dart';
import 'package:funkovault2/atlas/live_sniffer/models/atlas_live_sniffer_scan_mode.dart';

final class _FakeRecognitionPlatform
    implements
        AtlasLiveSnifferRecognitionPlatform,
        AtlasLiveSnifferRecognitionTurnoverPlatform {
  final StreamController<Map<Object?, Object?>> controller =
      StreamController<Map<Object?, Object?>>.broadcast();
  final List<String> hudUpdates = <String>[];
  int restartSelectedTargetCalls = 0;

  @override
  Stream<Map<Object?, Object?>> get frames => controller.stream;

  @override
  Future<bool> restartSelectedTarget() async {
    restartSelectedTargetCalls++;
    return true;
  }

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
    expect(platform.hudUpdates.last, contains('LiveLens Auction Mode'));

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
      expect(controller.hud.title, 'Selected Pop');
      expect(controller.hud.statusLabel, 'Scanning selected area...');
      expect(controller.hud.detail, contains('Rotate the box'));

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
      expect(controller.hud.toOverlayText(), contains('LiveLens Auction Mode'));

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

    expect(controller.hud.title, 'Selected Pop');
    expect(controller.hud.statusLabel, 'Scanning selected area...');
    expect(controller.hud.toOverlayText(), isNot(contains('Target lost')));

    await controller.stopSession();
    controller.dispose();
    await platform.dispose();
  });

  test(
    'selected target survives transient native track loss without identity reset',
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
      expect(controller.hud.title, 'Selected Pop');
      expect(controller.hud.statusLabel, 'Reacquiring selected Pop...');
      expect(controller.hud.detail, contains('Holding your selected Pop'));
      expect(controller.hud.toOverlayText(), isNot(contains('Target lost')));

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

  test(
    'Fix 6.2 rolls identity generation without carrying stale target state',
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
        'x': 0.5,
        'y': 0.5,
        'selectionGeneration': 21,
      });
      await Future<void>.delayed(Duration.zero);

      platform.controller.add(<Object?, Object?>{
        'type': 'control',
        'action': 'targetGenerationRolled',
        'selectionGeneration': 22,
      });
      await Future<void>.delayed(Duration.zero);

      expect(controller.scanMode, AtlasLiveSnifferScanMode.featured);
      expect(controller.hud.toOverlayText(), contains('New target detected'));
      expect(
        controller.hud.toOverlayText(),
        contains('Old Pop evidence was cleared'),
      );

      platform.controller.add(<Object?, Object?>{
        'type': 'frame',
        'capturedAtMicros': 1700000001500000,
        'frameSequence': 50,
        'selectionGeneration': 21,
        'targetState': 'lost',
        'barcodes': const <Object?>[],
        'textBlocks': const <Object?>[],
      });
      await Future<void>.delayed(Duration.zero);

      expect(controller.hud.toOverlayText(), contains('New target detected'));
      expect(controller.hud.toOverlayText(), isNot(contains('Target lost')));

      await controller.stopSession();
      controller.dispose();
      await platform.dispose();
    },
  );

  test(
    'Fix 6.2 scene discontinuity starts a fresh selected-target identity',
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
        'action': 'sceneDiscontinuity',
        'selectionGeneration': 31,
      });
      await Future<void>.delayed(Duration.zero);

      expect(controller.scanMode, AtlasLiveSnifferScanMode.featured);
      expect(controller.hud.toOverlayText(), contains('New auction scene'));
      expect(
        controller.hud.toOverlayText(),
        contains('Reading fresh identity'),
      );

      await controller.stopSession();
      controller.dispose();
      await platform.dispose();
    },
  );

  test(
    'Fix 6.3 accepts automatic turnover control as a fresh generation',
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
        'x': 0.5,
        'y': 0.5,
        'selectionGeneration': 40,
      });
      await Future<void>.delayed(Duration.zero);

      platform.controller.add(<Object?, Object?>{
        'type': 'control',
        'action': 'automaticTurnover',
        'selectionGeneration': 41,
      });
      await Future<void>.delayed(Duration.zero);

      expect(controller.scanMode, AtlasLiveSnifferScanMode.featured);
      expect(controller.hud.toOverlayText(), contains('New Pop detected'));
      expect(
        controller.hud.toOverlayText(),
        contains('Reading fresh identity'),
      );

      await controller.stopSession();
      controller.dispose();
      await platform.dispose();
    },
  );

  test(
    'Fix 6.3 restarts selected target after repeated strong number contradiction',
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
        'x': 0.5,
        'y': 0.5,
        'selectionGeneration': 50,
      });
      await Future<void>.delayed(Duration.zero);

      Map<Object?, Object?> frame(int sequence, int number) =>
          <Object?, Object?>{
            'type': 'frame',
            'capturedAtMicros': 1700000010000000 + (sequence * 250000),
            'frameSequence': sequence,
            'selectionGeneration': 50,
            'targetState': 'locked',
            'lockedTrackId': 7,
            'trackedBoundingBox': <Object?, Object?>{
              'left': 0.25,
              'top': 0.25,
              'right': 0.75,
              'bottom': 0.82,
            },
            'barcodes': const <Object?>[],
            'textBlocks': <Object?>[
              <Object?, Object?>{
                'text': 'POP! ANIMATION $number',
                'left': 0.38,
                'top': 0.38,
                'right': 0.64,
                'bottom': 0.45,
                'trackId': 7,
              },
              <Object?, Object?>{
                'text': number == 867 ? 'TANJIRO KAMADO' : 'SHOHEI OHTANI',
                'left': 0.35,
                'top': 0.64,
                'right': 0.66,
                'bottom': 0.70,
                'trackId': 7,
              },
            ],
          };

      platform.controller.add(frame(100, 867));
      await Future<void>.delayed(Duration.zero);
      platform.controller.add(frame(101, 867));
      await Future<void>.delayed(Duration.zero);
      platform.controller.add(frame(102, 126));
      await Future<void>.delayed(Duration.zero);
      platform.controller.add(frame(103, 126));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(platform.restartSelectedTargetCalls, 1);
      expect(controller.hud.toOverlayText(), contains('New Pop detected'));
      expect(controller.hud.toOverlayText(), contains('Resetting target'));

      await controller.stopSession();
      controller.dispose();
      await platform.dispose();
    },
  );

  test(
    'Fix 6.4 accepts contradictory foreground evidence while reacquiring',
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
        'x': 0.5,
        'y': 0.58,
        'selectionGeneration': 60,
      });
      await Future<void>.delayed(Duration.zero);

      Map<Object?, Object?> frame(int sequence, int number, String state) =>
          <Object?, Object?>{
            'type': 'frame',
            'capturedAtMicros': 1700000020000000 + (sequence * 250000),
            'frameSequence': sequence,
            'selectionGeneration': 60,
            'targetState': state,
            'lockedTrackId': 9,
            'trackedBoundingBox': <Object?, Object?>{
              'left': 0.28,
              'top': 0.28,
              'right': 0.72,
              'bottom': 0.84,
            },
            'barcodes': const <Object?>[],
            'textBlocks': <Object?>[
              <Object?, Object?>{
                'text': 'POP! $number',
                'left': 0.43,
                'top': 0.45,
                'right': 0.61,
                'bottom': 0.51,
                'trackId': 9,
              },
              <Object?, Object?>{
                'text': number == 867 ? 'TANJIRO KAMADO' : 'SHOHEI OHTANI',
                'left': 0.35,
                'top': 0.66,
                'right': 0.66,
                'bottom': 0.72,
                'trackId': 9,
              },
            ],
          };

      platform.controller.add(frame(200, 867, 'locked'));
      await Future<void>.delayed(Duration.zero);
      platform.controller.add(frame(201, 867, 'locked'));
      await Future<void>.delayed(Duration.zero);
      platform.controller.add(frame(202, 126, 'reacquiring'));
      await Future<void>.delayed(Duration.zero);
      platform.controller.add(frame(203, 126, 'reacquiring'));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(platform.restartSelectedTargetCalls, 1);
      expect(controller.hud.toOverlayText(), contains('New Pop detected'));

      await controller.stopSession();
      controller.dispose();
      await platform.dispose();
    },
  );

  test(
    'Fix 6.4 suppresses repeated shelf number outside foreground core',
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
        'x': 0.5,
        'y': 0.65,
        'selectionGeneration': 70,
      });
      await Future<void>.delayed(Duration.zero);

      Map<Object?, Object?> frame(int sequence, int number, double centerY) =>
          <Object?, Object?>{
            'type': 'frame',
            'capturedAtMicros': 1700000030000000 + (sequence * 250000),
            'frameSequence': sequence,
            'selectionGeneration': 70,
            'targetState': 'locked',
            'lockedTrackId': 11,
            'trackedBoundingBox': <Object?, Object?>{
              'left': 0.25,
              'top': 0.25,
              'right': 0.75,
              'bottom': 0.88,
            },
            'barcodes': const <Object?>[],
            'textBlocks': <Object?>[
              <Object?, Object?>{
                'text': 'POP! $number',
                'left': 0.42,
                'top': centerY - 0.03,
                'right': 0.60,
                'bottom': centerY + 0.03,
                'trackId': 11,
              },
              <Object?, Object?>{
                'text': number == 1889 ? 'TOJI FUSHIGURO' : 'DEMON SLAYER',
                'left': 0.35,
                'top': centerY + 0.05,
                'right': 0.67,
                'bottom': centerY + 0.11,
                'trackId': 11,
              },
            ],
          };

      platform.controller.add(frame(300, 1889, 0.62));
      await Future<void>.delayed(Duration.zero);
      platform.controller.add(frame(301, 1889, 0.62));
      await Future<void>.delayed(Duration.zero);

      // A sharp shelf number is repeated well above the user's selected foreground
      // core. It must not create an automatic target restart.
      platform.controller.add(frame(302, 1597, 0.38));
      await Future<void>.delayed(Duration.zero);
      platform.controller.add(frame(303, 1597, 0.38));
      await Future<void>.delayed(Duration.zero);
      platform.controller.add(frame(304, 1597, 0.38));
      await Future<void>.delayed(Duration.zero);

      expect(platform.restartSelectedTargetCalls, 0);

      await controller.stopSession();
      controller.dispose();
      await platform.dispose();
    },
  );
}
