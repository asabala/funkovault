import '../engine/engine_context.dart';
import '../engine/scan_engine.dart';
import 'engine_capability_category.dart';

typedef ScanEngineFactory = ScanEngine Function();

// Immutable description of one Atlas intelligence capability.
//
// Registrations store engine factories instead of live engine instances.
// This allows every pipeline to receive a fresh engine instance.
class ScanEngineRegistration {
  factory ScanEngineRegistration({
    required String capabilityId,
    required String engineId,
    required String displayName,
    required String description,
    required EngineCapabilityCategory category,
    required ScanEngineFactory createEngine,
    AtlasAccessTier minimumAccessTier =
        AtlasAccessTier.free,
    bool enabledByDefault = true,
    bool requiresOnline = false,
    Set<String> requiredFeatureFlags =
    const <String>{},
    Set<String> requiredDeviceCapabilities =
    const <String>{},
    Set<String> tags = const <String>{},
    Map<String, Object?> attributes =
    const <String, Object?>{},
  }) {
    final String normalizedCapabilityId =
    capabilityId.trim();

    final String normalizedEngineId = engineId.trim();

    final String normalizedDisplayName =
    displayName.trim();

    final String normalizedDescription =
    description.trim();

    if (normalizedCapabilityId.isEmpty) {
      throw ArgumentError.value(
        capabilityId,
        'capabilityId',
        'Capability ID cannot be empty.',
      );
    }

    if (normalizedEngineId.isEmpty) {
      throw ArgumentError.value(
        engineId,
        'engineId',
        'Engine ID cannot be empty.',
      );
    }

    if (normalizedDisplayName.isEmpty) {
      throw ArgumentError.value(
        displayName,
        'displayName',
        'Display name cannot be empty.',
      );
    }

    if (normalizedDescription.isEmpty) {
      throw ArgumentError.value(
        description,
        'description',
        'Description cannot be empty.',
      );
    }

    return ScanEngineRegistration._(
      capabilityId: normalizedCapabilityId,
      engineId: normalizedEngineId,
      displayName: normalizedDisplayName,
      description: normalizedDescription,
      category: category,
      createEngine: createEngine,
      minimumAccessTier: minimumAccessTier,
      enabledByDefault: enabledByDefault,
      requiresOnline: requiresOnline,
      requiredFeatureFlags: Set<String>.unmodifiable(
        _normalizeValues(requiredFeatureFlags),
      ),
      requiredDeviceCapabilities:
      Set<String>.unmodifiable(
        _normalizeValues(
          requiredDeviceCapabilities,
        ),
      ),
      tags: Set<String>.unmodifiable(
        _normalizeValues(tags),
      ),
      attributes:
      Map<String, Object?>.unmodifiable(
        attributes,
      ),
    );
  }

  const ScanEngineRegistration._({
    required this.capabilityId,
    required this.engineId,
    required this.displayName,
    required this.description,
    required this.category,
    required this.createEngine,
    required this.minimumAccessTier,
    required this.enabledByDefault,
    required this.requiresOnline,
    required this.requiredFeatureFlags,
    required this.requiredDeviceCapabilities,
    required this.tags,
    required this.attributes,
  });

  final String capabilityId;

  final String engineId;

  final String displayName;

  final String description;

  final EngineCapabilityCategory category;

  final ScanEngineFactory createEngine;

  final AtlasAccessTier minimumAccessTier;

  final bool enabledByDefault;

  final bool requiresOnline;

  final Set<String> requiredFeatureFlags;

  final Set<String> requiredDeviceCapabilities;

  final Set<String> tags;

  final Map<String, Object?> attributes;

  bool get isPremiumCapability {
    return minimumAccessTier ==
        AtlasAccessTier.premium ||
        minimumAccessTier ==
            AtlasAccessTier.enterprise;
  }

  bool get isEnterpriseCapability {
    return minimumAccessTier ==
        AtlasAccessTier.enterprise;
  }

  bool isAvailableIn(
      EngineContext context,
      ) {
    if (!_hasRequiredAccess(context.accessTier)) {
      return false;
    }

    if (requiresOnline && !context.isOnline) {
      return false;
    }

    for (final String featureId
    in requiredFeatureFlags) {
      if (!context.hasFeature(featureId)) {
        return false;
      }
    }

    for (final String capabilityId
    in requiredDeviceCapabilities) {
      if (!context.hasDeviceCapability(
        capabilityId,
      )) {
        return false;
      }
    }

    return true;
  }

  ScanEngine create() {
    final ScanEngine engine = createEngine();

    if (engine.engineId != engineId) {
      throw StateError(
        'Capability "$capabilityId" expected engine ID '
            '"$engineId", but the factory created '
            '"${engine.engineId}".',
      );
    }

    return engine;
  }

  bool hasTag(String tag) {
    final String normalized = tag.trim();

    return normalized.isNotEmpty &&
        tags.contains(normalized);
  }

  T? attribute<T>(String key) {
    final Object? value = attributes[key];

    if (value is T) {
      return value;
    }

    return null;
  }

  bool _hasRequiredAccess(
      AtlasAccessTier currentTier,
      ) {
    return _tierRank(currentTier) >=
        _tierRank(minimumAccessTier);
  }

  static int _tierRank(
      AtlasAccessTier tier,
      ) {
    return switch (tier) {
      AtlasAccessTier.guest => 0,
      AtlasAccessTier.free => 1,
      AtlasAccessTier.premium => 2,
      AtlasAccessTier.enterprise => 3,
    };
  }

  static Set<String> _normalizeValues(
      Iterable<String> values,
      ) {
    return values
        .map(
          (String value) => value.trim(),
    )
        .where(
          (String value) => value.isNotEmpty,
    )
        .toSet();
  }

  @override
  String toString() {
    return 'ScanEngineRegistration('
        'capabilityId: $capabilityId, '
        'engineId: $engineId, '
        'category: ${category.name}, '
        'minimumAccessTier: '
        '${minimumAccessTier.name}, '
        'enabledByDefault: $enabledByDefault'
        ')';
  }
}