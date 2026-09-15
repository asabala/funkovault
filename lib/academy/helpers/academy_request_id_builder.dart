import '../data/academy_request_id_prefixes.dart';

class AcademyRequestIdBuilder {
  const AcademyRequestIdBuilder._();

  static String buildTopicRequestId(DateTime dateTime) {
    return _buildId(prefix: AcademyRequestIdPrefixes.topic, dateTime: dateTime);
  }

  static String buildTrackRequestId(DateTime dateTime) {
    return _buildId(prefix: AcademyRequestIdPrefixes.track, dateTime: dateTime);
  }

  static String _buildId({required String prefix, required DateTime dateTime}) {
    return '$prefix-${dateTime.microsecondsSinceEpoch}';
  }
}
