import '../engine/engine_context.dart';
import '../engine/scan_engine.dart';
import 'engine_capability_category.dart';
import 'scan_engine_registration.dart';

// Immutable runtime catalog of Atlas scan capabilities.
class ScanCapabilityRegistry {
  factory ScanCapabilityRegistry({
    required Iterable<ScanEngineRegistration> registrations,
  }) {
    final Map<String, ScanEngineRegistration> byCapabilityId =
        <String, ScanEngineRegistration>{};

    final Map<String, ScanEngineRegistration> byEngineId =
        <String, ScanEngineRegistration>{};

    for (final ScanEngineRegistration registration in registrations) {
      if (byCapabilityId.containsKey(registration.capabilityId)) {
        throw StateError(
          'Duplicate capability ID: '
          '${registration.capabilityId}',
        );
      }

      if (byEngineId.containsKey(registration.engineId)) {
        throw StateError(
          'Duplicate engine ID: '
          '${registration.engineId}',
        );
      }

      byCapabilityId[registration.capabilityId] = registration;

      byEngineId[registration.engineId] = registration;
    }

    return ScanCapabilityRegistry._(
      byCapabilityId: Map<String, ScanEngineRegistration>.unmodifiable(
        byCapabilityId,
      ),
      byEngineId: Map<String, ScanEngineRegistration>.unmodifiable(byEngineId),
    );
  }

  const ScanCapabilityRegistry._({
    required this._byCapabilityId,
    required this._byEngineId,
  });

  final Map<String, ScanEngineRegistration> _byCapabilityId;

  final Map<String, ScanEngineRegistration> _byEngineId;

  int get capabilityCount {
    return _byCapabilityId.length;
  }

  bool get isEmpty {
    return _byCapabilityId.isEmpty;
  }

  bool get isNotEmpty {
    return _byCapabilityId.isNotEmpty;
  }

  List<ScanEngineRegistration> get registrations {
    return List<ScanEngineRegistration>.unmodifiable(_byCapabilityId.values);
  }

  bool containsCapability(String capabilityId) {
    return _byCapabilityId.containsKey(capabilityId.trim());
  }

  bool containsEngine(String engineId) {
    return _byEngineId.containsKey(engineId.trim());
  }

  ScanEngineRegistration? registrationForCapability(String capabilityId) {
    return _byCapabilityId[capabilityId.trim()];
  }

  ScanEngineRegistration? registrationForEngine(String engineId) {
    return _byEngineId[engineId.trim()];
  }

  List<ScanEngineRegistration> registrationsForCategory(
    EngineCapabilityCategory category,
  ) {
    return List<ScanEngineRegistration>.unmodifiable(
      _byCapabilityId.values.where((ScanEngineRegistration registration) {
        return registration.category == category;
      }),
    );
  }

  List<ScanEngineRegistration> registrationsWithTag(String tag) {
    final String normalized = tag.trim();

    if (normalized.isEmpty) {
      return const <ScanEngineRegistration>[];
    }

    return List<ScanEngineRegistration>.unmodifiable(
      _byCapabilityId.values.where((ScanEngineRegistration registration) {
        return registration.hasTag(normalized);
      }),
    );
  }

  List<ScanEngineRegistration> availableRegistrations(
    EngineContext context, {
    bool defaultsOnly = false,
  }) {
    return List<ScanEngineRegistration>.unmodifiable(
      _byCapabilityId.values.where((ScanEngineRegistration registration) {
        if (defaultsOnly && !registration.enabledByDefault) {
          return false;
        }

        return registration.isAvailableIn(context);
      }),
    );
  }

  List<ScanEngine> createAvailableEngines(
    EngineContext context, {
    bool defaultsOnly = true,
  }) {
    return List<ScanEngine>.unmodifiable(
      availableRegistrations(context, defaultsOnly: defaultsOnly).map((
        ScanEngineRegistration registration,
      ) {
        return registration.create();
      }),
    );
  }

  List<ScanEngine> createEnginesForCapabilities(
    Iterable<String> capabilityIds, {
    EngineContext? context,
    bool ignoreUnavailable = false,
  }) {
    final List<ScanEngine> engines = <ScanEngine>[];

    final Set<String> processedIds = <String>{};

    for (final String capabilityId in capabilityIds) {
      final String normalized = capabilityId.trim();

      if (normalized.isEmpty || !processedIds.add(normalized)) {
        continue;
      }

      final ScanEngineRegistration? registration = registrationForCapability(
        normalized,
      );

      if (registration == null) {
        throw StateError('Unknown Atlas capability: $normalized');
      }

      if (context != null && !registration.isAvailableIn(context)) {
        if (ignoreUnavailable) {
          continue;
        }

        throw StateError(
          'Atlas capability "$normalized" is not '
          'available in the current engine context.',
        );
      }

      engines.add(registration.create());
    }

    return List<ScanEngine>.unmodifiable(engines);
  }

  @override
  String toString() {
    return 'ScanCapabilityRegistry('
        'capabilityCount: $capabilityCount'
        ')';
  }
}

// Mutable setup tool that produces an immutable registry.
//
// The builder should be used during application composition. Runtime systems
// should receive the completed ScanCapabilityRegistry.
class ScanCapabilityRegistryBuilder {
  final Map<String, ScanEngineRegistration> _registrations =
      <String, ScanEngineRegistration>{};

  ScanCapabilityRegistryBuilder register(ScanEngineRegistration registration) {
    if (_registrations.containsKey(registration.capabilityId)) {
      throw StateError(
        'Capability "${registration.capabilityId}" '
        'is already registered.',
      );
    }

    final bool engineIdExists = _registrations.values.any((
      ScanEngineRegistration existing,
    ) {
      return existing.engineId == registration.engineId;
    });

    if (engineIdExists) {
      throw StateError(
        'Engine "${registration.engineId}" '
        'is already registered.',
      );
    }

    _registrations[registration.capabilityId] = registration;

    return this;
  }

  ScanCapabilityRegistryBuilder registerAll(
    Iterable<ScanEngineRegistration> registrations,
  ) {
    for (final ScanEngineRegistration registration in registrations) {
      register(registration);
    }

    return this;
  }

  ScanCapabilityRegistryBuilder replace(ScanEngineRegistration registration) {
    final String capabilityId = registration.capabilityId;

    final ScanEngineRegistration? existing = _registrations[capabilityId];

    if (existing == null) {
      throw StateError('Capability "$capabilityId" is not registered.');
    }

    final bool engineIdConflict = _registrations.values.any((
      ScanEngineRegistration candidate,
    ) {
      return candidate.capabilityId != capabilityId &&
          candidate.engineId == registration.engineId;
    });

    if (engineIdConflict) {
      throw StateError(
        'Engine "${registration.engineId}" '
        'is already registered to another capability.',
      );
    }

    _registrations[capabilityId] = registration;

    return this;
  }

  ScanCapabilityRegistryBuilder unregister(String capabilityId) {
    final String normalized = capabilityId.trim();

    if (normalized.isNotEmpty) {
      _registrations.remove(normalized);
    }

    return this;
  }

  ScanCapabilityRegistryBuilder clear() {
    _registrations.clear();
    return this;
  }

  ScanCapabilityRegistry build() {
    return ScanCapabilityRegistry(registrations: _registrations.values);
  }
}
