import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/live_sniffer/models/atlas_live_sniffer_native_frame.dart';
import 'package:funkovault2/atlas/live_sniffer/recognition/atlas_live_sniffer_native_observation_adapter.dart';

void main() {
  test(
    'native frame maps supported barcode geometry into Atlas observation',
    () {
      final AtlasLiveSnifferNativeFrame frame =
          AtlasLiveSnifferNativeFrame.fromMap(<Object?, Object?>{
            'capturedAtMicros': 1700000000000000,
            'barcodes': <Object?>[
              <Object?, Object?>{
                'rawValue': '012345678905',
                'format': 'UPC_A',
                'left': 0.10,
                'top': 0.20,
                'right': 0.50,
                'bottom': 0.60,
              },
            ],
          });

      final observations = AtlasLiveSnifferNativeObservationAdapter.fromFrame(
        frame,
      );

      expect(observations, hasLength(1));
      expect(observations.single.code?.normalizedValue, '012345678905');
      expect(observations.single.hasGeometry, isTrue);
      expect(observations.single.normalizedBounds?.left, 0.10);
      expect(observations.single.normalizedBounds?.bottom, 0.60);
    },
  );

  test('empty native frame remains a valid perception frame', () {
    final AtlasLiveSnifferNativeFrame frame =
        AtlasLiveSnifferNativeFrame.fromMap(<Object?, Object?>{
          'capturedAtMicros': 1700000000000000,
          'barcodes': const <Object?>[],
          'recognizedText': 'Funko Pop Spider-Man',
          'textBlocks': <Object?>[
            <Object?, Object?>{
              'text': 'SPIDER-MAN 1169',
              'left': 0.2,
              'top': 0.2,
              'right': 0.6,
              'bottom': 0.3,
            },
          ],
        });

    expect(AtlasLiveSnifferNativeObservationAdapter.fromFrame(frame), isEmpty);
    expect(frame.recognizedText, 'Funko Pop Spider-Man');
    expect(frame.textBlocks, hasLength(1));
    expect(frame.textBlocks.single.text, 'SPIDER-MAN 1169');
  });

  fix6NativeFrameContractTests();
}

// Fix 6 contract coverage lives outside main() in older snapshots, so keep a
// second group entrypoint-style test declaration in the same library.
void fix6NativeFrameContractTests() {
  test(
    'Fix 6 frame carries target generation, sequence, track and geometry',
    () {
      final AtlasLiveSnifferNativeFrame frame =
          AtlasLiveSnifferNativeFrame.fromMap(<Object?, Object?>{
            'capturedAtMicros': 1700000000250000,
            'nativeTimestampMs': 1700000000250,
            'frameSequence': 44,
            'selectionGeneration': 7,
            'lockedTrackId': 91,
            'targetState': 'locked',
            'trackedBoundingBox': <Object?, Object?>{
              'left': 0.2,
              'top': 0.25,
              'right': 0.7,
              'bottom': 0.8,
            },
            'activeTracks': <Object?>[
              <Object?, Object?>{
                'trackId': 91,
                'boundingBox': <Object?, Object?>{
                  'left': 0.2,
                  'top': 0.25,
                  'right': 0.7,
                  'bottom': 0.8,
                },
              },
            ],
            'barcodes': const <Object?>[],
            'textBlocks': <Object?>[
              <Object?, Object?>{
                'text': 'FRODO 1389',
                'left': 0.3,
                'top': 0.4,
                'right': 0.6,
                'bottom': 0.5,
                'trackId': 91,
              },
            ],
          });

      expect(frame.frameSequence, 44);
      expect(frame.selectionGeneration, 7);
      expect(frame.lockedTrackId, 91);
      expect(frame.targetState.name, 'locked');
      expect(frame.trackedBoundingBox?.centerX, closeTo(0.45, 0.001));
      expect(frame.activeTracks.single.trackId, 91);
      expect(frame.textBlocks.single.trackId, 91);
    },
  );
}
