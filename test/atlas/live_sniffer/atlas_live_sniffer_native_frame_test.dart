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
}
