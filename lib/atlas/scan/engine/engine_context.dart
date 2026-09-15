// Describes the collector's current Atlas access level.
//
// This represents runtime access and pipeline behavior. It does not contain
// billing logic or subscription-provider details.
enum AtlasAccessTier { guest, free, premium, enterprise }

// Describes the network state available to an Atlas engine.
enum EngineConnectivity { online, offline, limited, unknown }

// Describes the type of device executing the engine pipeline.
enum EngineDeviceType { mobile, tablet, desktop, web, server, unknown }

// Immutable runtime information shared with every Atlas engine.
//
// EngineContext contains execution facts that may affect how an engine runs.
// It intentionally does not contain Flutter widgets, BuildContext, database
// clients, repositories, or mutable application state.
class EngineContext {
  EngineContext({
    required this.requestId,
    required this.createdAt,
    this.userId,
    this.activeCollectionId,
    this.accessTier = AtlasAccessTier.free,
    this.connectivity = EngineConnectivity.unknown,
    this.deviceType = EngineDeviceType.unknown,
    this.localeCode = 'en-US',
    this.currencyCode = 'USD',
    Set<String> featureFlags = const <String>{},
    Set<String> deviceCapabilities = const <String>{},
    Set<String> experimentIds = const <String>{},
    Map<String, Object?> attributes = const <String, Object?>{},
  }) : featureFlags = Set<String>.unmodifiable(featureFlags),
       deviceCapabilities = Set<String>.unmodifiable(deviceCapabilities),
       experimentIds = Set<String>.unmodifiable(experimentIds),
       attributes = Map<String, Object?>.unmodifiable(attributes);

  final String requestId;

  final DateTime createdAt;

  final String? userId;

  final String? activeCollectionId;

  final AtlasAccessTier accessTier;

  final EngineConnectivity connectivity;

  final EngineDeviceType deviceType;

  final String localeCode;

  final String currencyCode;

  final Set<String> featureFlags;

  final Set<String> deviceCapabilities;

  final Set<String> experimentIds;

  final Map<String, Object?> attributes;

  bool get isAuthenticated {
    return userId != null && userId!.trim().isNotEmpty;
  }

  bool get hasActiveCollection {
    return activeCollectionId != null && activeCollectionId!.trim().isNotEmpty;
  }

  bool get isGuest {
    return accessTier == AtlasAccessTier.guest;
  }

  bool get isPremium {
    return accessTier == AtlasAccessTier.premium ||
        accessTier == AtlasAccessTier.enterprise;
  }

  bool get isEnterprise {
    return accessTier == AtlasAccessTier.enterprise;
  }

  bool get isOnline {
    return connectivity == EngineConnectivity.online;
  }

  bool get isOffline {
    return connectivity == EngineConnectivity.offline;
  }

  bool get hasLimitedConnectivity {
    return connectivity == EngineConnectivity.limited;
  }

  bool hasFeature(String featureId) {
    final String normalized = featureId.trim();

    return normalized.isNotEmpty && featureFlags.contains(normalized);
  }

  bool hasDeviceCapability(String capabilityId) {
    final String normalized = capabilityId.trim();

    return normalized.isNotEmpty && deviceCapabilities.contains(normalized);
  }

  bool isInExperiment(String experimentId) {
    final String normalized = experimentId.trim();

    return normalized.isNotEmpty && experimentIds.contains(normalized);
  }

  T? attribute<T>(String key) {
    final Object? value = attributes[key];

    if (value is T) {
      return value;
    }

    return null;
  }

  EngineContext copyWith({
    String? requestId,
    DateTime? createdAt,
    String? userId,
    String? activeCollectionId,
    AtlasAccessTier? accessTier,
    EngineConnectivity? connectivity,
    EngineDeviceType? deviceType,
    String? localeCode,
    String? currencyCode,
    Set<String>? featureFlags,
    Set<String>? deviceCapabilities,
    Set<String>? experimentIds,
    Map<String, Object?>? attributes,
  }) {
    return EngineContext(
      requestId: requestId ?? this.requestId,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      activeCollectionId: activeCollectionId ?? this.activeCollectionId,
      accessTier: accessTier ?? this.accessTier,
      connectivity: connectivity ?? this.connectivity,
      deviceType: deviceType ?? this.deviceType,
      localeCode: localeCode ?? this.localeCode,
      currencyCode: currencyCode ?? this.currencyCode,
      featureFlags: featureFlags ?? this.featureFlags,
      deviceCapabilities: deviceCapabilities ?? this.deviceCapabilities,
      experimentIds: experimentIds ?? this.experimentIds,
      attributes: attributes ?? this.attributes,
    );
  }

  EngineContext addFeatureFlag(String featureId) {
    final String normalized = featureId.trim();

    if (normalized.isEmpty || featureFlags.contains(normalized)) {
      return this;
    }

    return copyWith(featureFlags: <String>{...featureFlags, normalized});
  }

  EngineContext addDeviceCapability(String capabilityId) {
    final String normalized = capabilityId.trim();

    if (normalized.isEmpty || deviceCapabilities.contains(normalized)) {
      return this;
    }

    return copyWith(
      deviceCapabilities: <String>{...deviceCapabilities, normalized},
    );
  }

  EngineContext addExperiment(String experimentId) {
    final String normalized = experimentId.trim();

    if (normalized.isEmpty || experimentIds.contains(normalized)) {
      return this;
    }

    return copyWith(experimentIds: <String>{...experimentIds, normalized});
  }

  EngineContext setAttribute(String key, Object? value) {
    final String normalizedKey = key.trim();

    if (normalizedKey.isEmpty) {
      return this;
    }

    return copyWith(
      attributes: <String, Object?>{...attributes, normalizedKey: value},
    );
  }

  @override
  String toString() {
    return 'EngineContext('
        'requestId: $requestId, '
        'accessTier: ${accessTier.name}, '
        'connectivity: ${connectivity.name}, '
        'deviceType: ${deviceType.name}, '
        'localeCode: $localeCode, '
        'currencyCode: $currencyCode, '
        'features: ${featureFlags.length}, '
        'capabilities: ${deviceCapabilities.length}'
        ')';
  }
}
