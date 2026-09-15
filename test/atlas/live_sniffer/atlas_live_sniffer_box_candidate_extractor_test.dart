import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/live_sniffer/models/atlas_live_sniffer_native_frame.dart';
import 'package:funkovault2/atlas/live_sniffer/models/atlas_live_sniffer_target_state.dart';
import 'package:funkovault2/atlas/live_sniffer/models/atlas_live_sniffer_track.dart';
import 'package:funkovault2/atlas/live_sniffer/recognition/atlas_live_sniffer_box_candidate_extractor.dart';

void main() {
  const extractor = AtlasLiveSnifferBoxCandidateExtractor();

  test('extracts multiple spatial Pop candidates from one auction frame', () {
    final frame = AtlasLiveSnifferNativeFrame(
      capturedAt: DateTime.utc(2026, 9, 3),
      barcodes: const [],
      textBlocks: const <AtlasLiveSnifferNativeTextBlock>[
        AtlasLiveSnifferNativeTextBlock(
          text: 'POP! Funko 11',
          left: 0.22,
          top: 0.29,
          right: 0.43,
          bottom: 0.34,
        ),
        AtlasLiveSnifferNativeTextBlock(
          text: 'SALTY',
          left: 0.25,
          top: 0.47,
          right: 0.40,
          bottom: 0.51,
        ),
        AtlasLiveSnifferNativeTextBlock(
          text: 'POP! Funko 217',
          left: 0.05,
          top: 0.54,
          right: 0.30,
          bottom: 0.59,
        ),
        AtlasLiveSnifferNativeTextBlock(
          text: 'POP! Funko 12',
          left: 0.48,
          top: 0.54,
          right: 0.72,
          bottom: 0.59,
        ),
        AtlasLiveSnifferNativeTextBlock(
          text: 'FIN DU CHOMP',
          left: 0.50,
          top: 0.74,
          right: 0.72,
          bottom: 0.78,
        ),
      ],
    );

    final candidates = extractor.extract(frame);

    expect(
      candidates.map((candidate) => candidate.productNumber),
      containsAll(<String>['11', '217', '12']),
    );
  });

  test(
    'ignores Atlas HUD number and prefers Fire Force 979 foreground box',
    () {
      final frame = AtlasLiveSnifferNativeFrame(
        capturedAt: DateTime.utc(2026, 9, 3),
        barcodes: const [],
        textBlocks: const <AtlasLiveSnifferNativeTextBlock>[
          AtlasLiveSnifferNativeTextBlock(
            text: '#9',
            left: 0.35,
            top: 0.15,
            right: 0.41,
            bottom: 0.18,
          ),
          AtlasLiveSnifferNativeTextBlock(
            text: 'FIRE FORCE 979',
            left: 0.35,
            top: 0.30,
            right: 0.78,
            bottom: 0.36,
          ),
          AtlasLiveSnifferNativeTextBlock(
            text: 'POP! ANIMATION',
            left: 0.18,
            top: 0.29,
            right: 0.36,
            bottom: 0.35,
          ),
          AtlasLiveSnifferNativeTextBlock(
            text: 'IRIS',
            left: 0.48,
            top: 0.69,
            right: 0.60,
            bottom: 0.73,
          ),
        ],
      );

      final candidates = extractor.extract(frame);

      expect(candidates, isNotEmpty);
      expect(candidates.first.productNumber, '979');
      expect(candidates.first.text, contains('IRIS'));
      expect(
        candidates.map((candidate) => candidate.productNumber),
        isNot(contains('9')),
      );
    },
  );

  test('keeps four digit foreground product number intact', () {
    final frame = AtlasLiveSnifferNativeFrame(
      capturedAt: DateTime.utc(2026, 9, 3),
      barcodes: const [],
      textBlocks: const <AtlasLiveSnifferNativeTextBlock>[
        AtlasLiveSnifferNativeTextBlock(
          text: 'POP! ONE PIECE 2172',
          left: 0.25,
          top: 0.39,
          right: 0.70,
          bottom: 0.45,
        ),
        AtlasLiveSnifferNativeTextBlock(
          text: 'MONKEY D. GARP',
          left: 0.34,
          top: 0.69,
          right: 0.66,
          bottom: 0.74,
        ),
      ],
    );

    final candidates = extractor.extract(frame);

    expect(candidates, isNotEmpty);
    expect(candidates.first.productNumber, '2172');
    expect(candidates.first.text, contains('MONKEY D. GARP'));
  });

  test(
    'touch focus excludes background shelf numbers and keeps selected box',
    () {
      final frame = AtlasLiveSnifferNativeFrame(
        capturedAt: DateTime.utc(2026, 9, 3),
        barcodes: const [],
        textBlocks: const <AtlasLiveSnifferNativeTextBlock>[
          AtlasLiveSnifferNativeTextBlock(
            text: 'POP! 222',
            left: 0.05,
            top: 0.30,
            right: 0.22,
            bottom: 0.35,
          ),
          AtlasLiveSnifferNativeTextBlock(
            text: 'BACKGROUND POP',
            left: 0.05,
            top: 0.50,
            right: 0.25,
            bottom: 0.55,
          ),
          AtlasLiveSnifferNativeTextBlock(
            text: 'POP! 402',
            left: 0.47,
            top: 0.34,
            right: 0.66,
            bottom: 0.40,
          ),
          AtlasLiveSnifferNativeTextBlock(
            text: 'SELECTED POP',
            left: 0.46,
            top: 0.66,
            right: 0.69,
            bottom: 0.72,
          ),
        ],
      );

      final candidates = extractor.extract(frame, focusX: 0.56, focusY: 0.53);

      expect(candidates, isNotEmpty);
      expect(candidates.first.productNumber, '402');
      expect(candidates.first.text, contains('SELECTED POP'));
      expect(
        candidates.map((candidate) => candidate.productNumber),
        isNot(contains('222')),
      );
    },
  );

  test('ranked number parser keeps #422 when OCR also sees a year', () {
    final frame = AtlasLiveSnifferNativeFrame(
      capturedAt: DateTime.utc(2026, 9, 15),
      barcodes: const [],
      textBlocks: const <AtlasLiveSnifferNativeTextBlock>[
        AtlasLiveSnifferNativeTextBlock(
          text: 'POP! #422 2024',
          left: 0.35,
          top: 0.40,
          right: 0.66,
          bottom: 0.46,
        ),
        AtlasLiveSnifferNativeTextBlock(
          text: 'QUI-GON JINN',
          left: 0.37,
          top: 0.62,
          right: 0.64,
          bottom: 0.68,
        ),
      ],
    );

    final candidates = extractor.extract(frame, focusX: 0.50, focusY: 0.54);

    expect(candidates, isNotEmpty);
    expect(candidates.first.productNumber, '422');
    expect(candidates.first.text, contains('QUI-GON JINN'));
  });

  test('ranked number parser ignores dimension after #2148', () {
    final frame = AtlasLiveSnifferNativeFrame(
      capturedAt: DateTime.utc(2026, 9, 15),
      barcodes: const [],
      textBlocks: const <AtlasLiveSnifferNativeTextBlock>[
        AtlasLiveSnifferNativeTextBlock(
          text: '#2148 4 INCH',
          left: 0.34,
          top: 0.40,
          right: 0.66,
          bottom: 0.46,
        ),
        AtlasLiveSnifferNativeTextBlock(
          text: 'TONY TONY CHOPPER',
          left: 0.31,
          top: 0.62,
          right: 0.69,
          bottom: 0.68,
        ),
      ],
    );

    final candidates = extractor.extract(frame, focusX: 0.50, focusY: 0.54);

    expect(candidates, isNotEmpty);
    expect(candidates.first.productNumber, '2148');
  });

  test('ranked number parser ignores age rating after Funko number', () {
    final frame = AtlasLiveSnifferNativeFrame(
      capturedAt: DateTime.utc(2026, 9, 15),
      barcodes: const [],
      textBlocks: const <AtlasLiveSnifferNativeTextBlock>[
        AtlasLiveSnifferNativeTextBlock(
          text: 'FUNKO 127 6+',
          left: 0.35,
          top: 0.40,
          right: 0.65,
          bottom: 0.46,
        ),
        AtlasLiveSnifferNativeTextBlock(
          text: 'YUJI ITADORI',
          left: 0.36,
          top: 0.62,
          right: 0.64,
          bottom: 0.68,
        ),
      ],
    );

    final candidates = extractor.extract(frame, focusX: 0.50, focusY: 0.54);

    expect(candidates, isNotEmpty);
    expect(candidates.first.productNumber, '127');
  });

  test('ranked number parser ignores bid price and keeps explicit Pop number', () {
    final frame = AtlasLiveSnifferNativeFrame(
      capturedAt: DateTime.utc(2026, 9, 15),
      barcodes: const [],
      textBlocks: const <AtlasLiveSnifferNativeTextBlock>[
        AtlasLiveSnifferNativeTextBlock(
          text: r'$35 #422',
          left: 0.35,
          top: 0.40,
          right: 0.65,
          bottom: 0.46,
        ),
        AtlasLiveSnifferNativeTextBlock(
          text: 'QUI-GON JINN',
          left: 0.37,
          top: 0.62,
          right: 0.64,
          bottom: 0.68,
        ),
      ],
    );

    final candidates = extractor.extract(frame, focusX: 0.50, focusY: 0.54);

    expect(candidates, isNotEmpty);
    expect(candidates.first.productNumber, '422');
    expect(
      candidates.map((candidate) => candidate.productNumber),
      isNot(contains('35')),
    );
  });

  test('ranked number parser preserves valid 19xx Pop number near year metadata', () {
    final frame = AtlasLiveSnifferNativeFrame(
      capturedAt: DateTime.utc(2026, 9, 15),
      barcodes: const [],
      textBlocks: const <AtlasLiveSnifferNativeTextBlock>[
        AtlasLiveSnifferNativeTextBlock(
          text: 'POP! #1925 © 2024',
          left: 0.34,
          top: 0.40,
          right: 0.67,
          bottom: 0.46,
        ),
        AtlasLiveSnifferNativeTextBlock(
          text: 'ELPHABA',
          left: 0.42,
          top: 0.62,
          right: 0.59,
          bottom: 0.68,
        ),
      ],
    );

    final candidates = extractor.extract(frame, focusX: 0.50, focusY: 0.54);

    expect(candidates, isNotEmpty);
    expect(candidates.first.productNumber, '1925');
    expect(candidates.first.text, contains('ELPHABA'));
  });


  test('front panel ranker prefers 1447 over title sequel number 2', () {
    final frame = AtlasLiveSnifferNativeFrame(
      capturedAt: DateTime.utc(2026, 9, 15),
      barcodes: const [],
      targetState: AtlasLiveSnifferTargetState.locked,
      lockedTrackId: 7,
      trackedBoundingBox: const AtlasLiveSnifferNormalizedRect(left: 0.30, top: 0.36, right: 0.70, bottom: 0.80),
      textBlocks: const <AtlasLiveSnifferNativeTextBlock>[
        AtlasLiveSnifferNativeTextBlock(text: 'POP! INSIDE OUT 2 1447', left: 0.34, top: 0.40, right: 0.66, bottom: 0.46, trackId: 7),
        AtlasLiveSnifferNativeTextBlock(text: 'ANXIETY', left: 0.42, top: 0.68, right: 0.58, bottom: 0.73, trackId: 7),
      ],
    );
    final candidates = extractor.extract(frame, focusX: 0.50, focusY: 0.56);
    expect(candidates, isNotEmpty);
    expect(candidates.first.productNumber, '1447');
  });

  test('selected front panel 1114 outranks bare background shelf marker 22', () {
    final frame = AtlasLiveSnifferNativeFrame(
      capturedAt: DateTime.utc(2026, 9, 15),
      barcodes: const [],
      targetState: AtlasLiveSnifferTargetState.locked,
      lockedTrackId: 9,
      trackedBoundingBox: const AtlasLiveSnifferNormalizedRect(left: 0.29, top: 0.42, right: 0.66, bottom: 0.82),
      textBlocks: const <AtlasLiveSnifferNativeTextBlock>[
        AtlasLiveSnifferNativeTextBlock(text: '22', left: 0.36, top: 0.34, right: 0.42, bottom: 0.37, trackId: 9),
        AtlasLiveSnifferNativeTextBlock(text: 'POP! JUJUTSU KAISEN 1114', left: 0.32, top: 0.45, right: 0.63, bottom: 0.51, trackId: 9),
        AtlasLiveSnifferNativeTextBlock(text: 'SATORU GOJO', left: 0.37, top: 0.68, right: 0.59, bottom: 0.73, trackId: 9),
      ],
    );
    final candidates = extractor.extract(frame, focusX: 0.50, focusY: 0.57);
    expect(candidates, isNotEmpty);
    expect(candidates.first.productNumber, '1114');
    expect(candidates.map((candidate) => candidate.productNumber), isNot(contains('22')));
  });

}
