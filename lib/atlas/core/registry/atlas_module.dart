// Defines the shared identity of a modular Atlas capability.
//
// Comparators, providers, skills, and future platform modules can
// implement this contract so they can participate in Atlas registries.
abstract interface class AtlasModule {
  // Stable identifier used for registration and lookup.
  String get id;

  // Human-readable module name.
  String get name;

  // Version of the module implementation.
  String get version;
}