import 'atlas_variant_evidence.dart';
import 'atlas_variant_type.dart';

// Represents the result of variant detection for a single item.
final class AtlasVariantDetectionResult {
  const AtlasVariantDetectionResult({required this.evidence});

  final List<AtlasVariantEvidence> evidence;

  bool get hasVariants => evidence.isNotEmpty;

  List<AtlasVariantType> get variants {
    return List<AtlasVariantType>.unmodifiable(
      evidence.map((item) => item.type),
    );
  }

  bool contains(AtlasVariantType variant) {
    return evidence.any((item) => item.type == variant);
  }
}
