// Describes the outcome of one Atlas engine execution.
enum EngineStatus {
  succeeded,
  completedWithWarnings,
  skipped,
  failed,
}

extension EngineStatusX on EngineStatus {
  bool get isSuccessful {
    return this == EngineStatus.succeeded ||
        this == EngineStatus.completedWithWarnings;
  }

  bool get hasWarnings {
    return this == EngineStatus.completedWithWarnings;
  }

  bool get wasSkipped {
    return this == EngineStatus.skipped;
  }

  bool get hasFailed {
    return this == EngineStatus.failed;
  }

  bool get shouldContinue {
    return this != EngineStatus.failed;
  }
}