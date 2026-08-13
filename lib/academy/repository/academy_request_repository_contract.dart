import '../models/academy_request.dart';
import '../models/academy_request_submission_result.dart';

abstract class AcademyRequestRepositoryContract {
  AcademyRequestStorageBehavior get storageBehavior;

  bool get canSubmitRequests;

  List<AcademyRequest> getRequests();

  List<AcademyRequest> getNewRequests();

  int getNewRequestCount();

  Future<AcademyRequestSubmissionResult> submitTopicRequest({
    required String topic,
    String? trackId,
    String? notes,
  });

  Future<AcademyRequestSubmissionResult> submitTrackRequest({
    required String trackTitle,
    required String trackId,
    String? notes,
  });

  bool markReviewed(String requestId);

  bool approve(String requestId);

  bool decline(String requestId);
}
