import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/academy/config/academy_request_repository_provider.dart';
import 'package:funkovault2/academy/models/academy_request.dart';
import 'package:funkovault2/academy/models/academy_request_submission_result.dart';
import 'package:funkovault2/academy/repository/academy_request_repository.dart';
import 'package:funkovault2/academy/repository/supabase_academy_request_repository.dart';

void main() {
  group('AcademyRequestRepository submission', () {
    test('enabled local repository is explicitly session-only', () {
      final AcademyRequestRepository repository = AcademyRequestRepository();

      expect(repository.canSubmitRequests, isTrue);
      expect(
        repository.storageBehavior,
        AcademyRequestStorageBehavior.sessionOnly,
      );
    });

    test('creates topic requests asynchronously', () async {
      final AcademyRequestRepository repository = AcademyRequestRepository();

      final AcademyRequestSubmissionResult result = await repository
          .submitTopicRequest(
            topic: '  Sticker history  ',
            trackId: 'funko-collecting',
          );

      expect(result.isSuccessful, isTrue);
      expect(result.isSessionOnly, isTrue);
      expect(result.request?.title, 'Sticker history');
      expect(result.request?.type, AcademyRequestType.topic);
      expect(result.request?.status, AcademyRequestStatus.newRequest);
      expect(repository.getRequests(), hasLength(1));
      expect(repository.getNewRequestCount(), 1);
    });

    test('creates track requests and keeps newest requests first', () async {
      final AcademyRequestRepository repository = AcademyRequestRepository();

      final AcademyRequestSubmissionResult topicResult = await repository
          .submitTopicRequest(topic: 'First topic');
      final AcademyRequestSubmissionResult trackResult = await repository
          .submitTrackRequest(trackTitle: 'Hot Wheels', trackId: 'hot-wheels');

      expect(trackResult.isSuccessful, isTrue);
      expect(trackResult.request?.type, AcademyRequestType.track);
      expect(repository.getRequests().map((request) => request.id), <String>[
        trackResult.request!.id,
        topicResult.request!.id,
      ]);
    });

    test('disabled local repository stores nothing', () async {
      final AcademyRequestRepository repository = AcademyRequestRepository(
        submissionsEnabled: false,
      );

      final AcademyRequestSubmissionResult topicResult = await repository
          .submitTopicRequest(topic: 'Sticker history');
      final AcademyRequestSubmissionResult trackResult = await repository
          .submitTrackRequest(trackTitle: 'Hot Wheels', trackId: 'hot-wheels');

      expect(repository.canSubmitRequests, isFalse);
      expect(
        repository.storageBehavior,
        AcademyRequestStorageBehavior.unavailable,
      );
      expect(topicResult.isUnavailable, isTrue);
      expect(trackResult.isUnavailable, isTrue);
      expect(repository.getRequests(), isEmpty);
    });

    test('provider supports release-style local unavailability', () {
      final repository = AcademyRequestRepositoryProvider.create(
        allowLocalSessionSubmissions: false,
      );

      expect(repository.canSubmitRequests, isFalse);
      expect(
        repository.storageBehavior,
        AcademyRequestStorageBehavior.unavailable,
      );
    });

    test('Supabase placeholder returns unavailable without throwing', () async {
      const SupabaseAcademyRequestRepository repository =
          SupabaseAcademyRequestRepository();

      final AcademyRequestSubmissionResult topicResult = await repository
          .submitTopicRequest(topic: 'Sticker history');
      final AcademyRequestSubmissionResult trackResult = await repository
          .submitTrackRequest(trackTitle: 'Hot Wheels', trackId: 'hot-wheels');

      expect(repository.canSubmitRequests, isFalse);
      expect(topicResult.isUnavailable, isTrue);
      expect(trackResult.isUnavailable, isTrue);
    });
  });

  group('AcademyRequestRepository status transitions', () {
    test('reports successful legal transitions', () async {
      final AcademyRequestRepository repository = AcademyRequestRepository();
      final AcademyRequestSubmissionResult result = await repository
          .submitTopicRequest(topic: 'Sticker history');
      final String requestId = result.request!.id;

      expect(repository.markReviewed(requestId), isTrue);
      expect(
        repository.getRequests().single.status,
        AcademyRequestStatus.reviewed,
      );
      expect(repository.getNewRequestCount(), 0);
      expect(repository.approve(requestId), isTrue);
      expect(
        repository.getRequests().single.status,
        AcademyRequestStatus.approved,
      );
    });

    test('reports missing and invalid transitions as unchanged', () async {
      final AcademyRequestRepository repository = AcademyRequestRepository();
      final AcademyRequestSubmissionResult result = await repository
          .submitTopicRequest(topic: 'Sticker history');
      final String requestId = result.request!.id;

      expect(repository.markReviewed('missing-request'), isFalse);
      expect(repository.approve(requestId), isTrue);
      expect(repository.markReviewed(requestId), isFalse);
      expect(repository.decline(requestId), isFalse);
      expect(repository.approve(requestId), isFalse);
      expect(
        repository.getRequests().single.status,
        AcademyRequestStatus.approved,
      );
    });
  });
}
