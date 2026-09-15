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
      title: _cleanRequiredText(topic, fallback: 'Academy Topic Request'),
      description: AcademyRequestDefaults.topicDescription,
      type: AcademyRequestType.topic,
      status: AcademyRequestStatus.newRequest,
      source: AcademyRequestDefaults.source,
      notes: _cleanOptionalText(notes) ?? AcademyRequestDefaults.topicNotes,
      trackId: _cleanOptionalText(trackId),
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
      title: _cleanRequiredText(trackTitle, fallback: 'Academy Track Request'),
      description: AcademyRequestDefaults.trackDescription,
      type: AcademyRequestType.track,
      status: AcademyRequestStatus.newRequest,
      source: AcademyRequestDefaults.source,
      notes: _cleanOptionalText(notes) ?? AcademyRequestDefaults.trackNotes,
      trackId: _cleanOptionalText(trackId),
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }

  static String _cleanRequiredText(String value, {required String fallback}) {
    final String cleaned = value.trim();

    if (cleaned.isEmpty) {
      return fallback;
    }

    return cleaned;
  }

  static String? _cleanOptionalText(String? value) {
    final String cleaned = value?.trim() ?? '';

    if (cleaned.isEmpty) {
      return null;
    }

    return cleaned;
  }
}
