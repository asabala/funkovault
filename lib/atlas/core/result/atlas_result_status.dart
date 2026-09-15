// Describes the outcome of an Atlas Engine execution.
//
// These statuses represent expected domain outcomes. An engine should return
// an [AtlasResultStatus] rather than throw an exception for ordinary
// validation, policy, missing-data, or evidence-conflict conditions.
enum AtlasResultStatus {
  // The engine completed successfully and produced its expected output.
  success,

  // The engine produced usable output, but one or more parts of the
  // operation could not be completed.
  partialSuccess,

  // The supplied input did not satisfy the engine's validation rules.
  validationFailure,

  // The engine could not continue because an applicable policy was missing,
  // incompatible, or could not be applied.
  policyFailure,

  // The engine could not reach a complete conclusion because required
  // information was unavailable.
  missingData,

  // The engine encountered credible evidence that could not be reconciled.
  conflictingEvidence,

  // The engine encountered an unexpected execution failure.
  executionFailure;

  // Whether the engine produced output that may be consumed.
  bool get hasUsableOutput {
    return this == AtlasResultStatus.success ||
        this == AtlasResultStatus.partialSuccess;
  }

  // Whether the engine completed without any failure status.
  bool get isSuccess {
    return this == AtlasResultStatus.success;
  }

  // Whether the result requires additional review.
  bool get requiresReview {
    return this == AtlasResultStatus.partialSuccess ||
        this == AtlasResultStatus.missingData ||
        this == AtlasResultStatus.conflictingEvidence;
  }

  // Whether the engine failed to produce a usable result.
  bool get isFailure => !hasUsableOutput;

  // Stable value used for persistence and API serialization.
  String get serializedValue {
    switch (this) {
      case AtlasResultStatus.success:
        return 'success';
      case AtlasResultStatus.partialSuccess:
        return 'partial_success';
      case AtlasResultStatus.validationFailure:
        return 'validation_failure';
      case AtlasResultStatus.policyFailure:
        return 'policy_failure';
      case AtlasResultStatus.missingData:
        return 'missing_data';
      case AtlasResultStatus.conflictingEvidence:
        return 'conflicting_evidence';
      case AtlasResultStatus.executionFailure:
        return 'execution_failure';
    }
  }

  // Restores a status from its persisted representation.
  //
  // Unknown values resolve to [AtlasResultStatus.executionFailure] rather
  // than silently being treated as successful.
  static AtlasResultStatus fromSerializedValue(String value) {
    switch (value.trim().toLowerCase()) {
      case 'success':
        return AtlasResultStatus.success;
      case 'partial_success':
        return AtlasResultStatus.partialSuccess;
      case 'validation_failure':
        return AtlasResultStatus.validationFailure;
      case 'policy_failure':
        return AtlasResultStatus.policyFailure;
      case 'missing_data':
        return AtlasResultStatus.missingData;
      case 'conflicting_evidence':
        return AtlasResultStatus.conflictingEvidence;
      case 'execution_failure':
      default:
        return AtlasResultStatus.executionFailure;
    }
  }
}
