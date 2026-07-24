import 'atlas_engine.dart';
import 'atlas_engine_configuration.dart';

// Fluent builder for AtlasEngine.
//
// The builder allows applications to configure Atlas before creating
// the immutable engine instance.
class AtlasEngineBuilder {
  AtlasEngineBuilder();

  AtlasEngineConfiguration? _configuration;

  // Supplies the configuration used when building the engine.
  AtlasEngineBuilder configuration(
      AtlasEngineConfiguration configuration,
      ) {
    _configuration = configuration;
    return this;
  }

  // Returns the configured AtlasEngine.
  AtlasEngine build() {
    final AtlasEngineConfiguration? configuration =
        _configuration;

    if (configuration == null) {
      throw StateError(
        'AtlasEngineConfiguration must be supplied before '
            'building the AtlasEngine.',
      );
    }

    return AtlasEngine(
      configuration: configuration,
    );
  }
}