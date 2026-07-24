import '../models/scan_session.dart';
import 'engine_result.dart';

// Immutable summary of a complete ScanPipeline execution.
class PipelineExecutionResult {
  factory PipelineExecutionResult({
    required ScanSession initialSession,
    required ScanSession finalSession,
    required List<EngineResult> engineResults,
  }) {
    return PipelineExecutionResult._(
      initialSession: initialSession,
      finalSession: finalSession,
      engineResults: List<EngineResult>.unmodifiable(
        engineResults,
      ),
    );
  }

  const PipelineExecutionResult._({
    required this.initialSession,
    required this.finalSession,
    required this.engineResults,
  });

  final ScanSession initialSession;

  final ScanSession finalSession;

  final List<EngineResult> engineResults;

  int get executedEngineCount {
    return engineResults.length;
  }

  int get successfulEngineCount {
    return engineResults
        .where(
          (EngineResult result) => result.isSuccessful,
    )
        .length;
  }

  int get skippedEngineCount {
    return engineResults
        .where(
          (EngineResult result) => result.wasSkipped,
    )
        .length;
  }

  int get failedEngineCount {
    return engineResults
        .where(
          (EngineResult result) => result.hasFailed,
    )
        .length;
  }

  int get warningCount {
    return engineResults.fold<int>(
      0,
          (
          int total,
          EngineResult result,
          ) {
        return total + result.warnings.length;
      },
    );
  }

  bool get completedSuccessfully {
    return failedEngineCount == 0;
  }

  bool get hasFailures {
    return failedEngineCount > 0;
  }

  bool get hasWarnings {
    return warningCount > 0;
  }

  bool get wasPartiallySuccessful {
    return hasFailures && successfulEngineCount > 0;
  }

  Duration get totalEngineDuration {
    return engineResults.fold<Duration>(
      Duration.zero,
          (
          Duration total,
          EngineResult result,
          ) {
        return total +
            (result.metadata?.duration ?? Duration.zero);
      },
    );
  }

  List<EngineResult> get failures {
    return List<EngineResult>.unmodifiable(
      engineResults.where(
            (EngineResult result) => result.hasFailed,
      ),
    );
  }

  List<EngineResult> get skipped {
    return List<EngineResult>.unmodifiable(
      engineResults.where(
            (EngineResult result) => result.wasSkipped,
      ),
    );
  }

  @override
  String toString() {
    return 'PipelineExecutionResult('
        'executed: $executedEngineCount, '
        'successful: $successfulEngineCount, '
        'skipped: $skippedEngineCount, '
        'failed: $failedEngineCount, '
        'warnings: $warningCount'
        ')';
  }
}