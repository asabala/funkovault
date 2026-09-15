import '../models/scan_session.dart';
import 'engine_context.dart';
import 'engine_result.dart';

// Shared contract for engines that enrich an Atlas scan session.
//
// Each engine receives the current immutable ScanSession and EngineContext.
// The returned EngineResult describes both the updated session and the
// execution outcome.
abstract interface class ScanEngine {
  String get engineId;

  String get displayName;

  Future<EngineResult> process(ScanSession session, EngineContext context);
}
