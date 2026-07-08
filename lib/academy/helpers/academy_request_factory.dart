import '../data/academy_request_defaults.dart';
import '../models/academy_request.dart';
import 'academy_request_id_builder.dart';

class AcademyRequestFactory {
  const AcademyRequestFactory._();

  static AcademyRequest createTopicRequest({
    required String topic,
    String? trackId,
    String? notes,
    required DateTime createdAt,
  }) {
    return AcademyRequest(
      id: AcademyRequestIdBuilder.buildTopicRequestId(createdAt),
      title: topic.trim(),
      description: AcademyRequestDefaults.topicDescription,
      type: AcademyRequestType.topic,
      status: AcademyRequestStatus.newRequest,
      source: AcademyRequestDefaults.source,
      notes: notes ?? AcademyRequestDefaults.topicNotes,
      trackId: trackId,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }

  static AcademyRequest createTrackRequest({
    required String trackTitle,
    required String trackId,
    String? notes,
    required DateTime createdAt,
  }) {
    return AcademyRequest(
      id: AcademyRequestIdBuilder.buildTrackRequestId(createdAt),
      title: trackTitle.trim(),
      description: AcademyRequestDefaults.trackDescription,
      type: AcademyRequestType.track,
      status: AcademyRequestStatus.newRequest,
      source: AcademyRequestDefaults.source,
      notes: notes ?? AcademyRequestDefaults.trackNotes,
      trackId: trackId,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }
}