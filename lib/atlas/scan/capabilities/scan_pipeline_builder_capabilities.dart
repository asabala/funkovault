import '../engine/engine_context.dart';
import '../engine/scan_pipeline_builder.dart';
import 'scan_capability_registry.dart';

// Adds capability-registry composition helpers to ScanPipelineBuilder.
extension ScanPipelineBuilderCapabilities on ScanPipelineBuilder {
  ScanPipelineBuilder addAvailableCapabilities(
    ScanCapabilityRegistry registry,
    EngineContext context, {
    bool defaultsOnly = true,
  }) {
    return addAll(
      registry.createAvailableEngines(context, defaultsOnly: defaultsOnly),
    );
  }

  ScanPipelineBuilder addCapabilitiesById(
    ScanCapabilityRegistry registry,
    Iterable<String> capabilityIds, {
    EngineContext? context,
    bool ignoreUnavailable = false,
  }) {
    return addAll(
      registry.createEnginesForCapabilities(
        capabilityIds,
        context: context,
        ignoreUnavailable: ignoreUnavailable,
      ),
    );
  }
}
