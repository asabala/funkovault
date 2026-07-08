import '../helpers/academy_request_factory.dart';
import '../helpers/academy_request_status_updater.dart';
import '../models/academy_request.dart';
import 'academy_request_repository_contract.dart';

class AcademyRequestRepository implements AcademyRequestRepositoryContract {
  final List<AcademyRequest> _requests = [];

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
  AcademyRequest addTopicRequest({
    required String topic,
    String? trackId,
    String? notes,
  }) {
    final now = DateTime.now();

    final request = AcademyRequestFactory.createTopicRequest(
      topic: topic,
      trackId: trackId,
      notes: notes,
      createdAt: now,
    );

    return _insertRequest(request);
  }

  @override
  AcademyRequest addTrackRequest({
    required String trackTitle,
    required String trackId,
    String? notes,
  }) {
    final now = DateTime.now();

    final request = AcademyRequestFactory.createTrackRequest(
      trackTitle: trackTitle,
      trackId: trackId,
      notes: notes,
      createdAt: now,
    );

    return _insertRequest(request);
  }

  @override
  void markReviewed(String requestId) {
    _updateRequestStatus(
      requestId: requestId,
      status: AcademyRequestStatus.reviewed,
    );
  }

  @override
  void approve(String requestId) {
    _updateRequestStatus(
      requestId: requestId,
      status: AcademyRequestStatus.approved,
    );
  }

  @override
  void decline(String requestId) {
    _updateRequestStatus(
      requestId: requestId,
      status: AcademyRequestStatus.declined,
    );
  }

  @override
  void clearAll() {
    _requests.clear();
  }

  AcademyRequest _insertRequest(AcademyRequest request) {
    _requests.insert(0, request);

    return request;
  }

  int _findRequestIndex(String requestId) {
    return _requests.indexWhere(
          (request) => request.id == requestId,
    );
  }

  void _updateRequestStatus({
    required String requestId,
    required AcademyRequestStatus status,
  }) {
    final index = _findRequestIndex(requestId);

    if (index == -1) {
      return;
    }

    _requests[index] = AcademyRequestStatusUpdater.updateStatus(
      request: _requests[index],
      status: status,
      updatedAt: DateTime.now(),
    );
  }
}