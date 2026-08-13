import '../helpers/academy_request_factory.dart';
import '../helpers/academy_request_status_updater.dart';
import '../models/academy_request.dart';
import '../models/academy_request_submission_result.dart';
import 'academy_request_repository_contract.dart';

class AcademyRequestRepository implements AcademyRequestRepositoryContract {
  AcademyRequestRepository({this.submissionsEnabled = true});

  final bool submissionsEnabled;
  final List<AcademyRequest> _requests = [];

  @override
  AcademyRequestStorageBehavior get storageBehavior {
    return submissionsEnabled
        ? AcademyRequestStorageBehavior.sessionOnly
        : AcademyRequestStorageBehavior.unavailable;
  }

  @override
  bool get canSubmitRequests {
    return submissionsEnabled;
  }

  @override
  List<AcademyRequest> getRequests() {
    return List.unmodifiable(_requests);
  }

  @override
  List<AcademyRequest> getNewRequests() {
    return _requests.where((request) => request.isNew).toList();
  }

  @override
  int getNewRequestCount() {
    return getNewRequests().length;
  }

  @override
  Future<AcademyRequestSubmissionResult> submitTopicRequest({
    required String topic,
    String? trackId,
    String? notes,
  }) async {
    if (!canSubmitRequests) {
      return const AcademyRequestSubmissionResult.unavailable();
    }

    final now = DateTime.now();

    final request = AcademyRequestFactory.createTopicRequest(
      topic: topic,
      trackId: trackId,
      notes: notes,
      createdAt: now,
    );

    _insertRequest(request);

    return AcademyRequestSubmissionResult.submitted(
      request: request,
      storageBehavior: storageBehavior,
    );
  }

  @override
  Future<AcademyRequestSubmissionResult> submitTrackRequest({
    required String trackTitle,
    required String trackId,
    String? notes,
  }) async {
    if (!canSubmitRequests) {
      return const AcademyRequestSubmissionResult.unavailable();
    }

    final now = DateTime.now();

    final request = AcademyRequestFactory.createTrackRequest(
      trackTitle: trackTitle,
      trackId: trackId,
      notes: notes,
      createdAt: now,
    );

    _insertRequest(request);

    return AcademyRequestSubmissionResult.submitted(
      request: request,
      storageBehavior: storageBehavior,
    );
  }

  @override
  bool markReviewed(String requestId) {
    return _updateRequestStatus(
      requestId: requestId,
      status: AcademyRequestStatus.reviewed,
    );
  }

  @override
  bool approve(String requestId) {
    return _updateRequestStatus(
      requestId: requestId,
      status: AcademyRequestStatus.approved,
    );
  }

  @override
  bool decline(String requestId) {
    return _updateRequestStatus(
      requestId: requestId,
      status: AcademyRequestStatus.declined,
    );
  }

  void _insertRequest(AcademyRequest request) {
    _requests.insert(0, request);
  }

  int _findRequestIndex(String requestId) {
    return _requests.indexWhere((request) => request.id == requestId);
  }

  bool _updateRequestStatus({
    required String requestId,
    required AcademyRequestStatus status,
  }) {
    final index = _findRequestIndex(requestId);

    if (index == -1) {
      return false;
    }

    final AcademyRequest currentRequest = _requests[index];
    final AcademyRequest updatedRequest =
        AcademyRequestStatusUpdater.updateStatus(
          request: currentRequest,
          status: status,
          updatedAt: DateTime.now(),
        );

    if (identical(currentRequest, updatedRequest)) {
      return false;
    }

    _requests[index] = updatedRequest;

    return true;
  }
}
