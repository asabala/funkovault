import 'funko_sticker_evidence.dart';
import 'funko_sticker_type.dart';

// Contains all sticker evidence detected during identity analysis.
final class FunkoStickerDetectionResult {
  const FunkoStickerDetectionResult({
    required this.evidence,
  });

  final List<FunkoStickerEvidence> evidence;

  bool get hasStickers {
    return evidence.isNotEmpty;
  }

  List<FunkoStickerType> get stickers {
    return List<FunkoStickerType>.unmodifiable(
      evidence.map(
            (FunkoStickerEvidence item) =>
        item.sticker,
      ),
    );
  }

  bool contains(
      FunkoStickerType sticker,
      ) {
    return evidence.any(
          (FunkoStickerEvidence item) =>
      item.sticker == sticker,
    );
  }
}