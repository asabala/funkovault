import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/academy/helpers/academy_request_factory.dart';
import 'package:funkovault2/academy/models/academy_request.dart';

void main() {
  group('AcademyRequestFactory', () {
    final DateTime createdAt = DateTime.utc(2026, 8, 13, 12);

    test('creates normalized topic requests', () {
      final AcademyRequest request = AcademyRequestFactory.createTopicRequest(
        topic: '  Sticker history  ',
        trackId: '  funko-collecting  ',
        notes: '  Collector suggestion  ',
        createdAt: createdAt,
      );

      expect(request.id, 'topic-${createdAt.microsecondsSinceEpoch}');
      expect(request.title, 'Sticker history');
      expect(request.type, AcademyRequestType.topic);
      expect(request.status, AcademyRequestStatus.newRequest);
      expect(request.source, 'Atlas Academy');
      expect(request.notes, 'Collector suggestion');
      expect(request.trackId, 'funko-collecting');
      expect(request.createdAt, createdAt);
      expect(request.updatedAt, createdAt);
    });

    test('creates normalized track requests', () {
      final AcademyRequest request = AcademyRequestFactory.createTrackRequest(
        trackTitle: '  Hot Wheels  ',
        trackId: '  hot-wheels  ',
        notes: '  Future track  ',
        createdAt: createdAt,
      );

      expect(request.id, 'track-${createdAt.microsecondsSinceEpoch}');
      expect(request.title, 'Hot Wheels');
      expect(request.type, AcademyRequestType.track);
      expect(request.status, AcademyRequestStatus.newRequest);
      expect(request.notes, 'Future track');
      expect(request.trackId, 'hot-wheels');
    });

    test('uses defaults for blank required and optional text', () {
      final AcademyRequest topicRequest =
          AcademyRequestFactory.createTopicRequest(
            topic: '   ',
            trackId: '   ',
            notes: '   ',
            createdAt: createdAt,
          );
      final AcademyRequest trackRequest =
          AcademyRequestFactory.createTrackRequest(
            trackTitle: '   ',
            trackId: '   ',
            notes: '   ',
            createdAt: createdAt,
          );

      expect(topicRequest.title, 'Academy Topic Request');
      expect(topicRequest.trackId, isNull);
      expect(topicRequest.notes, 'Requested from the topic request card.');
      expect(trackRequest.title, 'Academy Track Request');
      expect(trackRequest.trackId, isNull);
      expect(trackRequest.notes, 'Requested from the coming soon track card.');
    });

    test('request map conversion preserves existing fields', () {
      final AcademyRequest request = AcademyRequestFactory.createTopicRequest(
        topic: 'Sticker history',
        trackId: 'funko-collecting',
        notes: 'Collector suggestion',
        createdAt: createdAt,
      );

      final AcademyRequest restored = AcademyRequest.fromMap(request.toMap());

      expect(restored.id, request.id);
      expect(restored.title, request.title);
      expect(restored.description, request.description);
      expect(restored.type, request.type);
      expect(restored.status, request.status);
      expect(restored.source, request.source);
      expect(restored.notes, request.notes);
      expect(restored.trackId, request.trackId);
      expect(restored.createdAt, request.createdAt);
      expect(restored.updatedAt, request.updatedAt);
    });
  });
}
