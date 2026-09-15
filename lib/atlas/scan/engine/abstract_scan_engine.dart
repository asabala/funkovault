import '../models/scan_session.dart';
import 'engine_context.dart';
import 'engine_execution_decision.dart';
import 'engine_result.dart';
import 'scan_engine.dart';

// Reusable base implementation for Atlas scan engines.
//
// Concrete engines implement execute() and may override evaluateExecution()
// when they require connectivity, premium access, device capabilities,
// feature flags, or other runtime conditions.
//
// Timing, exception conversion, and failure policies remain the
// responsibility of ScanPipeline.
abstract base class AbstractScanEngine implements ScanEngine {
  const AbstractScanEngine();

  @override
  Future<EngineResult> process(
    ScanSession session,
    EngineContext context,
  ) async {
    final EngineExecutionDecision decision = evaluateExecution(
      session,
      context,
    );

    if (decision.shouldSkip) {
      return EngineResult.skipped(
        session: session,
        reason: decision.reason ?? 'Engine execution was skipped.',
        attributes: decision.attributes,
      );
    }

    return execute(session, context);
  }

  // Determines whether this engine should execute.
  //
  // Concrete engines should override this only when they have runtime
  // prerequisites. Engines run by default.
  EngineExecutionDecision evaluateExecution(
    ScanSession session,
    EngineContext context,
  ) {
    return EngineExecutionDecision.run();
  }

  // Performs the engine-specific intelligence work.
  //
  // Unexpected exceptions should be allowed to reach ScanPipeline, which
  // converts them into structured EngineFailure results.
  Future<EngineResult> execute(ScanSession session, EngineContext context);

  EngineExecutionDecision requireOnline(
    EngineContext context, {
    String reason = 'An internet connection is required.',
  }) {
    if (context.isOnline) {
      return EngineExecutionDecision.run();
    }

    return EngineExecutionDecision.skip(
      reason: reason,
      attributes: <String, Object?>{
        'requirement': 'online',
        'connectivity': context.connectivity.name,
      },
    );
  }

  EngineExecutionDecision requireAuthentication(
    EngineContext context, {
    String reason = 'An authenticated Atlas account is required.',
  }) {
    if (context.isAuthenticated) {
      return EngineExecutionDecision.run();
    }

    return EngineExecutionDecision.skip(
      reason: reason,
      attributes: const <String, Object?>{'requirement': 'authentication'},
    );
  }

  EngineExecutionDecision requirePremium(
    EngineContext context, {
    String reason = 'Atlas Premium access is required.',
  }) {
    if (context.isPremium) {
      return EngineExecutionDecision.run();
    }

    return EngineExecutionDecision.skip(
      reason: reason,
      attributes: <String, Object?>{
        'requirement': 'premium',
        'accessTier': context.accessTier.name,
      },
    );
  }

  EngineExecutionDecision requireFeature(
    EngineContext context,
    String featureId, {
    String? reason,
  }) {
    final String normalizedFeatureId = featureId.trim();

    if (normalizedFeatureId.isEmpty) {
      throw ArgumentError.value(
        featureId,
        'featureId',
        'Feature ID cannot be empty.',
      );
    }

    if (context.hasFeature(normalizedFeatureId)) {
      return EngineExecutionDecision.run();
    }

    return EngineExecutionDecision.skip(
      reason: reason ?? 'The required Atlas feature is unavailable.',
      attributes: <String, Object?>{
        'requirement': 'feature',
        'featureId': normalizedFeatureId,
      },
    );
  }

  EngineExecutionDecision requireDeviceCapability(
    EngineContext context,
    String capabilityId, {
    String? reason,
  }) {
    final String normalizedCapabilityId = capabilityId.trim();

    if (normalizedCapabilityId.isEmpty) {
      throw ArgumentError.value(
        capabilityId,
        'capabilityId',
        'Capability ID cannot be empty.',
      );
    }

    if (context.hasDeviceCapability(normalizedCapabilityId)) {
      return EngineExecutionDecision.run();
    }

    return EngineExecutionDecision.skip(
      reason: reason ?? 'The device does not support the required capability.',
      attributes: <String, Object?>{
        'requirement': 'deviceCapability',
        'capabilityId': normalizedCapabilityId,
      },
    );
  }
}
