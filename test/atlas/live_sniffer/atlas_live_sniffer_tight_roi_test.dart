import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/live_sniffer/models/atlas_live_sniffer_native_frame.dart';
import 'package:funkovault2/atlas/live_sniffer/models/atlas_live_sniffer_target_state.dart';
import 'package:funkovault2/atlas/live_sniffer/recognition/atlas_live_sniffer_box_candidate_extractor.dart';

void main() {
  test(
    'Fix 6.1 keeps useful scoped nameplate text and filters auction noise',
    () {
      const AtlasLiveSnifferBoxCandidateExtractor extractor =
          AtlasLiveSnifferBoxCandidateExtractor();
      final AtlasLiveSnifferNativeFrame frame = AtlasLiveSnifferNativeFrame(
        capturedAt: DateTime.utc(2026, 9, 9),
        barcodes: const <AtlasLiveSnifferNativeBarcode>[],
        targetState: AtlasLiveSnifferTargetState.locked,
        lockedTrackId: 42,
        textBlocks: const <AtlasLiveSnifferNativeTextBlock>[
          AtlasLiveSnifferNativeTextBlock(
            text: 'SECRE',
            left: 0.40,
            top: 0.60,
            right: 0.58,
            bottom: 0.66,
            trackId: 42,
          ),
          AtlasLiveSnifferNativeTextBlock(
            text: 'Bid \$5',
            left: 0.42,
            top: 0.70,
            right: 0.60,
            bottom: 0.76,
            trackId: 42,
          ),
        ],
      );

      final String text = extractor.extractSupplementalText(
        frame,
        focusX: 0.50,
        focusY: 0.60,
      );

      expect(text, contains('SECRE'));
      expect(text.toLowerCase(), isNot(contains('bid')));
    },
  );

  test(
    'Fix 6.4 rejects static marketplace like-count text as a Pop number',
    () {
      const AtlasLiveSnifferBoxCandidateExtractor extractor =
          AtlasLiveSnifferBoxCandidateExtractor();
      final AtlasLiveSnifferNativeFrame frame = AtlasLiveSnifferNativeFrame(
        capturedAt: DateTime.utc(2026, 9, 9),
        barcodes: const <AtlasLiveSnifferNativeBarcode>[],
        targetState: AtlasLiveSnifferTargetState.acquiring,
        textBlocks: const <AtlasLiveSnifferNativeTextBlock>[
          AtlasLiveSnifferNativeTextBlock(
            text: '100K SUPER LIKES',
            left: 0.38,
            top: 0.20,
            right: 0.62,
            bottom: 0.26,
          ),
        ],
      );

      final candidates = extractor.extract(frame, focusX: 0.50, focusY: 0.60);
      expect(candidates, isEmpty);
    },
  );

  test(
    'Fix 6.4 permits scoped evidence during short tracking decay states',
    () {
      expect(
        AtlasLiveSnifferTargetState.acquiring.mayContributeEvidence,
        isTrue,
      );
      expect(AtlasLiveSnifferTargetState.locked.mayContributeEvidence, isTrue);
      expect(
        AtlasLiveSnifferTargetState.coasting.mayContributeEvidence,
        isTrue,
      );
      expect(
        AtlasLiveSnifferTargetState.reacquiring.mayContributeEvidence,
        isTrue,
      );
      expect(AtlasLiveSnifferTargetState.lost.mayContributeEvidence, isFalse);
    },
  );

  test('Fix 6.5 drops scoped shelf text outside the auction viewport', () {
    const AtlasLiveSnifferBoxCandidateExtractor extractor =
        AtlasLiveSnifferBoxCandidateExtractor();
    final AtlasLiveSnifferNativeFrame frame = AtlasLiveSnifferNativeFrame(
      capturedAt: DateTime.utc(2026, 9, 9),
      barcodes: const <AtlasLiveSnifferNativeBarcode>[],
      targetState: AtlasLiveSnifferTargetState.locked,
      lockedTrackId: 7,
      textBlocks: const <AtlasLiveSnifferNativeTextBlock>[
        AtlasLiveSnifferNativeTextBlock(
          text: 'CRASH BANDICOOT 841',
          left: 0.38,
          top: 0.18,
          right: 0.62,
          bottom: 0.25,
          trackId: 7,
        ),
        AtlasLiveSnifferNativeTextBlock(
          text: 'BELLY DANCER HOMER 1144',
          left: 0.34,
          top: 0.48,
          right: 0.68,
          bottom: 0.58,
          trackId: 7,
        ),
      ],
    );

    final candidates = extractor.extract(frame, focusX: 0.50, focusY: 0.55);
    expect(candidates, isNotEmpty);
    expect(candidates.first.productNumber, '1144');
    expect(
      candidates.any((candidate) => candidate.productNumber == '841'),
      isFalse,
    );
  });
}
