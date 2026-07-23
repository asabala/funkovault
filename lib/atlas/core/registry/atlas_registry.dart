import 'atlas_module.dart';

// Stores and discovers one category of Atlas modules.
//
// Domain-specific registries can compose this registry while retaining
// responsibility for capability checks and module execution.
class AtlasRegistry<T extends AtlasModule> {
  const AtlasRegistry(
      this._modules,
      );

  final List<T> _modules;

  // Returns all registered modules as an immutable collection.
  List<T> get modules {
    return List<T>.unmodifiable(_modules);
  }

  bool get isEmpty => _modules.isEmpty;

  bool get isNotEmpty => _modules.isNotEmpty;

  int get length => _modules.length;

  // Returns the module matching the supplied stable identifier.
  T? byId(String id) {
    final String normalizedId = id.trim();

    for (final T module in _modules) {
      if (module.id == normalizedId) {
        return module;
      }
    }

    return null;
  }

  // Returns whether a module with the supplied identifier exists.
  bool contains(String id) {
    return byId(id) != null;
  }

  // Returns all modules satisfying the supplied condition.
  List<T> where(
      bool Function(T module) test,
      ) {
    return List<T>.unmodifiable(
      _modules.where(test),
    );
  }

  // Returns all registered module identifiers.
  Set<String> get ids {
    return Set<String>.unmodifiable(
      _modules.map(
            (T module) => module.id,
      ),
    );
  }

  // Returns all registered module names.
  List<String> get names {
    return List<String>.unmodifiable(
      _modules.map(
            (T module) => module.name,
      ),
    );
  }

  // Returns all registered module versions by identifier.
  Map<String, String> get versions {
    return Map<String, String>.unmodifiable(
      <String, String>{
        for (final T module in _modules)
          module.id: module.version,
      },
    );
  }
}