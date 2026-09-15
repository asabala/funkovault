// Visual evidence collected while identifying a collectible.
//
// This information supplements traditional identifiers such as UPC,
// QR, and EAN. Over time Atlas Intelligence will continue enriching
// this model as new computer vision capabilities are introduced.
class VisualIdentity {
  const VisualIdentity({
    this.boxNumber,
    this.detectedStickers = const [],
    this.detectedLogos = const [],
    this.detectedAutographs = const [],
    this.detectedCharacters = const [],
    this.imageFingerprint,
    this.visualEmbedding,
    this.colorSignature,
    this.boxConditionScore,
    this.windowConditionScore,
    this.confidence = 0.0,
  });

  final String? boxNumber;

  final List<String> detectedStickers;

  final List<String> detectedLogos;

  final List<String> detectedAutographs;

  final List<String> detectedCharacters;

  final String? imageFingerprint;

  // Reserved for future AI vector embeddings.
  final String? visualEmbedding;

  // Reserved for future color histogram matching.
  final String? colorSignature;

  final double? boxConditionScore;

  final double? windowConditionScore;

  final double confidence;

  bool get hasBoxNumber => boxNumber != null && boxNumber!.isNotEmpty;

  bool get hasStickerEvidence => detectedStickers.isNotEmpty;

  bool get hasAutographEvidence => detectedAutographs.isNotEmpty;

  bool get hasCharacterEvidence => detectedCharacters.isNotEmpty;

  bool get hasImageFingerprint =>
      imageFingerprint != null && imageFingerprint!.isNotEmpty;

  bool get hasVisualEmbedding =>
      visualEmbedding != null && visualEmbedding!.isNotEmpty;

  bool get isEmpty {
    return !hasBoxNumber &&
        !hasStickerEvidence &&
        !hasAutographEvidence &&
        !hasCharacterEvidence &&
        !hasImageFingerprint &&
        !hasVisualEmbedding;
  }

  bool get isNotEmpty => !isEmpty;

  VisualIdentity copyWith({
    String? boxNumber,
    List<String>? detectedStickers,
    List<String>? detectedLogos,
    List<String>? detectedAutographs,
    List<String>? detectedCharacters,
    String? imageFingerprint,
    String? visualEmbedding,
    String? colorSignature,
    double? boxConditionScore,
    double? windowConditionScore,
    double? confidence,
  }) {
    return VisualIdentity(
      boxNumber: boxNumber ?? this.boxNumber,
      detectedStickers: detectedStickers ?? this.detectedStickers,
      detectedLogos: detectedLogos ?? this.detectedLogos,
      detectedAutographs: detectedAutographs ?? this.detectedAutographs,
      detectedCharacters: detectedCharacters ?? this.detectedCharacters,
      imageFingerprint: imageFingerprint ?? this.imageFingerprint,
      visualEmbedding: visualEmbedding ?? this.visualEmbedding,
      colorSignature: colorSignature ?? this.colorSignature,
      boxConditionScore: boxConditionScore ?? this.boxConditionScore,
      windowConditionScore: windowConditionScore ?? this.windowConditionScore,
      confidence: confidence ?? this.confidence,
    );
  }
}
