import 'pipeline_failure_policy.dart';
import 'scan_engine.dart';
import 'scan_pipeline.dart';

// Builds immutable ScanPipeline instances.
//
// Applications can compose different engine configurations without
// modifying ScanPipeline itself.
class ScanPipelineBuilder {
  final List<ScanEngine> _engines = <ScanEngine>[];

  PipelineFailurePolicy _failurePolicy =
      PipelineFailurePolicy.stop;

  ScanPipelineBuilder add(
      ScanEngine engine,
      ) {
    _engines.add(engine);
    return this;
  }

  ScanPipelineBuilder addAll(
      Iterable<ScanEngine> engines,
      ) {
    _engines.addAll(engines);
    return this;
  }

  ScanPipelineBuilder removeById(
      String engineId,
      ) {
    final String normalized = engineId.trim();

    if (normalized.isEmpty) {
      return this;
    }

    _engines.removeWhere(
          (ScanEngine engine) {
        return engine.engineId == normalized;
      },
    );

    return this;
  }

  ScanPipelineBuilder stopOnFailure() {
    _failurePolicy = PipelineFailurePolicy.stop;
    return this;
  }

  ScanPipelineBuilder continueOnFailure() {
    _failurePolicy =
        PipelineFailurePolicy.continueExecution;

    return this;
  }

  ScanPipelineBuilder clear() {
    _engines.clear();
    return this;
  }

  ScanPipeline build() {
    return ScanPipeline(
      engines: _engines,
      failurePolicy: _failurePolicy,
    );
  }
}