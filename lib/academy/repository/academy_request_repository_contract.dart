import '../models/academy_request.dart';

abstract class AcademyRequestRepositoryContract {
  List<AcademyRequest> getRequests();

  List<AcademyRequest> getNewRequests();

  int getNewRequestCount();

  AcademyRequest addTopicRequest({
    required String topic,
    String? trackId,
    String? notes,
  });

  AcademyRequest addTrackRequest({
    required String trackTitle,
    required String trackId,
    String? notes,
  });

  void markReviewed(String requestId);

  void approve(String requestId);

  void decline(String requestId);

  void clearAll();
}