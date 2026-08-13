import 'academy_request.dart';

enum AcademyRequestStorageBehavior { unavailable, sessionOnly, durable }

enum AcademyRequestSubmissionStatus { submitted, unavailable, failed }

class AcademyRequestSubmissionResult {
  const AcademyRequestSubmissionResult.submitted({
    required AcademyRequest this.request,
    required this.storageBehavior,
  }) : status = AcademyRequestSubmissionStatus.submitted,
       assert(
         storageBehavior != AcademyRequestStorageBehavior.unavailable,
         'A successful request must have an available storage behavior.',
       );

  const AcademyRequestSubmissionResult.unavailable()
    : status = AcademyRequestSubmissionStatus.unavailable,
      storageBehavior = AcademyRequestStorageBehavior.unavailable,
      request = null;

  const AcademyRequestSubmissionResult.failed({required this.storageBehavior})
    : status = AcademyRequestSubmissionStatus.failed,
      request = null;

  final AcademyRequestSubmissionStatus status;
  final AcademyRequestStorageBehavior storageBehavior;
  final AcademyRequest? request;

  bool get isSuccessful {
    return status == AcademyRequestSubmissionStatus.submitted &&
        request != null;
  }

  bool get isUnavailable {
    return status == AcademyRequestSubmissionStatus.unavailable;
  }

  bool get isSessionOnly {
    return storageBehavior == AcademyRequestStorageBehavior.sessionOnly;
  }
}
