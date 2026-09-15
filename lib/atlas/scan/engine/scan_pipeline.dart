import '../models/scan_session.dart';
import 'engine_context.dart';
import 'engine_execution_metadata.dart';
import 'engine_failure.dart';
import 'engine_result.dart';
import 'pipeline_execution_result.dart';
import 'pipeline_failure_policy.dart';
import 'scan_engine.dart';

// Executes an immutable sequence of ScanEngines.
//
// Each engine receives the session produced by the previous engine.
// The pipeline records execution metadata and converts unexpected
// exceptions into structured EngineFailure results.
class ScanPipeline {
  factory ScanPipeline({
    required List<ScanEngine> engines,
    PipelineFailurePolicy failurePolicy = PipelineFailurePolicy.stop,
  }) {
    return ScanPipeline._(
      engines: List<ScanEngine>.unmodifiable(engines),
      failurePolicy: failurePolicy,
    );
  }

  const ScanPipeline._({required this.failurePolicy, required this._engines});

  final List<ScanEngine> _engines;

  final PipelineFailurePolicy failurePolicy;

  List<ScanEngine> get engines => _engines;

  bool get isEmpty => _engines.isEmpty;

  bool get isNotEmpty => _engines.isNotEmpty;

  int get engineCount => _engines.length;

  Future<PipelineExecutionResult> process(
    ScanSession session,
    EngineContext context,
  ) async {
    ScanSession currentSession = session;

    final List<EngineResult> engineResults = <EngineResult>[];

    for (final ScanEngine engine in _engines) {
      final DateTime startedAt = DateTime.now().toUtc();
      final Stopwatch stopwatch = Stopwatch()..start();

      EngineResult result;

      try {
        final EngineResult rawResult = await engine.process(
          currentSession,
          context,
        );

        stopwatch.stop();

        final DateTime completedAt = DateTime.now().toUtc();

        result = rawResult.withMetadata(
          EngineExecutionMetadata(
            engineId: engine.engineId,
            engineDisplayName: engine.displayName,
            startedAt: startedAt,
            completedAt: completedAt,
            duration: stopwatch.elapsed,
            usedCache: rawResult.attribute<bool>('usedCache') ?? false,
          ),
        );
      } catch (error, stackTrace) {
        stopwatch.stop();

        final DateTime completedAt = DateTime.now().toUtc();

        result =
            EngineResult.failed(
              session: currentSession,
              failure: EngineFailure(
                code: 'unhandled_engine_exception',
                message: error.toString(),
                isRetryable: false,
                details: <String, Object?>{
                  'engineId': engine.engineId,
                  'exceptionType': error.runtimeType.toString(),
                  'stackTrace': stackTrace.toString(),
                },
              ),
            ).withMetadata(
              EngineExecutionMetadata(
                engineId: engine.engineId,
                engineDisplayName: engine.displayName,
                startedAt: startedAt,
                completedAt: completedAt,
                duration: stopwatch.elapsed,
              ),
            );
      }

      engineResults.add(result);
      currentSession = result.session;

      if (result.hasFailed && failurePolicy == PipelineFailurePolicy.stop) {
        break;
      }
    }

    return PipelineExecutionResult(
      initialSession: session,
      finalSession: currentSession,
      engineResults: engineResults,
    );
  }

  Future<ScanSession> processSession(
    ScanSession session,
    EngineContext context,
  ) async {
    final PipelineExecutionResult result = await process(session, context);

    return result.finalSession;
  }
}
