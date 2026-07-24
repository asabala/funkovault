import '../capabilities/standard_scan_capability_registry.dart';
import '../engine/engine_context.dart';
import '../engine/scan_pipeline.dart';
import '../engine/scan_pipeline_builder.dart';

// Builds the default Atlas scan pipeline.
//
// The pipeline is composed from the capability registry rather than
// manually constructing engine instances. New default capabilities can be
// added through registration without changing this class.
abstract final class StandardScanPipeline {
  static ScanPipeline create(
      EngineContext context,
      ) {
    final registry =
    StandardScanCapabilityRegistry.create();

    final ScanPipelineBuilder builder =
    ScanPipelineBuilder()
      ..continueOnFailure()
      ..addAll(
        registry.createAvailableEngines(
          context,
        ),
      );

    return builder.build();
  }

  static ScanPipeline createStrict(
      EngineContext context,
      ) {
    final registry =
    StandardScanCapabilityRegistry.create();

    final ScanPipelineBuilder builder =
    ScanPipelineBuilder()
      ..stopOnFailure()
      ..addAll(
        registry.createAvailableEngines(
          context,
        ),
      );

    return builder.build();
  }
}