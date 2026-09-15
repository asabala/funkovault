import '../../attribute/identity_attribute.dart';
import '../../attribute/identity_classification.dart';
import '../../attribute/identity_role.dart';
import '../../observation/identity_presence.dart';
import '../../profile/identity_profile.dart';
import 'funko_identity_keys.dart';

// Converts Funko catalog data into a universal IdentityProfile.
//
// This adapter contains only factory and catalog identity traits.
// Physical-copy traits such as signatures, grading, condition,
// certification, and protection belong to the Instance domain.
class FunkoIdentityAdapter {
  const FunkoIdentityAdapter();

  IdentityProfile build({
    required String name,
    required String boxNumber,
    String? line,
    String? series,
    String? upc,
    String? productionCode,
    String? finish,
    String? scale,
    String? buildType,
    String? sculpt,
    String? pose,
    String? productForm,
    String? factoryError,
    String? stickerClass,
    String? stickerName,
    String? retailer,
    String? region,
    String? distribution,
    String? productionGeneration,
    bool isLimitedEdition = false,
    String? pieceCount,
    String? numberedPiece,
    String? releaseYear,
  }) {
    final attributes = <IdentityAttribute>[
      _attribute(
        key: FunkoIdentityKeys.category,
        role: IdentityRole.category,
        classification: IdentityClassification.contextual,
        value: 'Funko Pop',
      ),
      _attribute(
        key: FunkoIdentityKeys.maker,
        role: IdentityRole.maker,
        classification: IdentityClassification.contextual,
        value: 'Funko',
      ),
      _attribute(
        key: FunkoIdentityKeys.name,
        role: IdentityRole.entityAnchor,
        classification: IdentityClassification.defining,
        value: name,
      ),
      _attribute(
        key: FunkoIdentityKeys.boxNumber,
        role: IdentityRole.catalogIndex,
        classification: IdentityClassification.defining,
        value: boxNumber,
      ),
    ];

    _addOptional(
      attributes,
      key: FunkoIdentityKeys.line,
      role: IdentityRole.primaryDescriptor,
      classification: IdentityClassification.defining,
      value: line,
    );

    _addOptional(
      attributes,
      key: FunkoIdentityKeys.series,
      role: IdentityRole.primaryDescriptor,
      classification: IdentityClassification.contextual,
      value: series,
    );

    _addOptional(
      attributes,
      key: FunkoIdentityKeys.upc,
      role: IdentityRole.catalogIndex,
      classification: IdentityClassification.defining,
      value: upc,
    );

    _addOptional(
      attributes,
      key: FunkoIdentityKeys.productionCode,
      role: IdentityRole.temporalMarker,
      classification: IdentityClassification.influencing,
      value: productionCode,
    );

    _addOptional(
      attributes,
      key: _finishKey(finish),
      role: IdentityRole.variantModifier,
      classification: IdentityClassification.influencing,
      value: finish,
    );

    _addOptional(
      attributes,
      key: FunkoIdentityKeys.scale,
      role: IdentityRole.variantModifier,
      classification: IdentityClassification.influencing,
      value: scale,
    );

    _addOptional(
      attributes,
      key: FunkoIdentityKeys.build,
      role: IdentityRole.variantModifier,
      classification: IdentityClassification.influencing,
      value: buildType,
    );

    _addOptional(
      attributes,
      key: FunkoIdentityKeys.sculpt,
      role: IdentityRole.variantModifier,
      classification: IdentityClassification.influencing,
      value: sculpt,
    );

    _addOptional(
      attributes,
      key: FunkoIdentityKeys.pose,
      role: IdentityRole.variantModifier,
      classification: IdentityClassification.influencing,
      value: pose,
    );

    _addOptional(
      attributes,
      key: FunkoIdentityKeys.productForm,
      role: IdentityRole.variantModifier,
      classification: IdentityClassification.influencing,
      value: productForm,
    );

    _addOptional(
      attributes,
      key: FunkoIdentityKeys.factoryError,
      role: IdentityRole.variantModifier,
      classification: IdentityClassification.influencing,
      value: factoryError,
    );

    _addOptional(
      attributes,
      key: FunkoIdentityKeys.stickerClass,
      role: IdentityRole.releaseContext,
      classification: IdentityClassification.influencing,
      value: stickerClass,
    );

    _addOptional(
      attributes,
      key: FunkoIdentityKeys.stickerName,
      role: IdentityRole.releaseContext,
      classification: IdentityClassification.influencing,
      value: stickerName,
    );

    _addOptional(
      attributes,
      key: FunkoIdentityKeys.retailer,
      role: IdentityRole.releaseContext,
      classification: IdentityClassification.influencing,
      value: retailer,
    );

    _addOptional(
      attributes,
      key: FunkoIdentityKeys.region,
      role: IdentityRole.releaseContext,
      classification: IdentityClassification.influencing,
      value: region,
    );

    _addOptional(
      attributes,
      key: FunkoIdentityKeys.distribution,
      role: IdentityRole.releaseContext,
      classification: IdentityClassification.influencing,
      value: distribution,
    );

    _addOptional(
      attributes,
      key: FunkoIdentityKeys.productionGeneration,
      role: IdentityRole.releaseContext,
      classification: IdentityClassification.influencing,
      value: productionGeneration,
    );

    if (isLimitedEdition) {
      attributes.add(
        _attribute(
          key: FunkoIdentityKeys.limitedEdition,
          role: IdentityRole.releaseContext,
          classification: IdentityClassification.influencing,
          value: 'Limited Edition',
        ),
      );
    }

    _addOptional(
      attributes,
      key: FunkoIdentityKeys.pieceCount,
      role: IdentityRole.releaseContext,
      classification: IdentityClassification.influencing,
      value: pieceCount,
    );

    _addOptional(
      attributes,
      key: FunkoIdentityKeys.numberedPiece,
      role: IdentityRole.releaseContext,
      classification: IdentityClassification.influencing,
      value: numberedPiece,
    );

    _addOptional(
      attributes,
      key: FunkoIdentityKeys.releaseYear,
      role: IdentityRole.temporalMarker,
      classification: IdentityClassification.contextual,
      value: releaseYear,
    );

    return IdentityProfile(attributes: attributes);
  }

  void _addOptional(
    List<IdentityAttribute> attributes, {
    required String key,
    required IdentityRole role,
    required IdentityClassification classification,
    required String? value,
  }) {
    final normalizedValue = value?.trim();

    if (normalizedValue == null || normalizedValue.isEmpty) {
      return;
    }

    attributes.add(
      _attribute(
        key: key,
        role: role,
        classification: classification,
        value: normalizedValue,
      ),
    );
  }

  IdentityAttribute _attribute({
    required String key,
    required IdentityRole role,
    required IdentityClassification classification,
    required String value,
  }) {
    return IdentityAttribute(
      key: key,
      role: role,
      classification: classification,
      resolvedValue: value.trim(),
      resolvedPresence: IdentityPresence.known,
      resolutionConfidence: 1.0,
    );
  }

  String _finishKey(String? finish) {
    final normalizedFinish = finish?.trim().toLowerCase();

    return switch (normalizedFinish) {
      'glow' || 'glow in the dark' || 'gitd' => FunkoIdentityKeys.finishGlow,
      'metallic' => FunkoIdentityKeys.finishMetallic,
      'flocked' => FunkoIdentityKeys.finishFlocked,
      'diamond' || 'diamond collection' => FunkoIdentityKeys.finishDiamond,
      'glitter' => FunkoIdentityKeys.finishGlitter,
      'chrome' ||
      'gold chrome' ||
      'silver chrome' ||
      'red chrome' ||
      'blue chrome' => FunkoIdentityKeys.finishChrome,
      'translucent' || 'clear' => FunkoIdentityKeys.finishTranslucent,
      'blood splatter' || 'bloody' => FunkoIdentityKeys.finishBloodSplatter,
      'patina' => FunkoIdentityKeys.finishPatina,
      'bronze' => FunkoIdentityKeys.finishBronze,
      'wood deco' || 'wood' => FunkoIdentityKeys.finishWoodDeco,
      _ => 'funko.identity.finish.other',
    };
  }
}
