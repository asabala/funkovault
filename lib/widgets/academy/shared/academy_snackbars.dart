import 'package:flutter/material.dart';

import '../../../academy/models/academy_request_submission_result.dart';

class AcademySnackbars {
  const AcademySnackbars._();

  static void showComingSoonTrack({
    required BuildContext context,
    required String trackTitle,
  }) {
    final String cleanedTrackTitle = trackTitle.trim();

    _show(
      context: context,
      message: cleanedTrackTitle.isEmpty
          ? 'This Academy track is coming soon.'
          : '$cleanedTrackTitle Academy is coming soon.',
    );
  }

  static void showTopicRequestSubmitted({
    required BuildContext context,
    required String topic,
    required int newRequestCount,
    required AcademyRequestStorageBehavior storageBehavior,
  }) {
    final String cleanedTopic = topic.trim();

    final String requestCountLabel = _requestCountLabel(newRequestCount);

    _show(
      context: context,
      message: storageBehavior == AcademyRequestStorageBehavior.sessionOnly
          ? cleanedTopic.isEmpty
                ? 'Topic request saved to this debug session • $requestCountLabel'
                : 'Topic request saved to this debug session: $cleanedTopic • $requestCountLabel'
          : cleanedTopic.isEmpty
          ? 'Academy topic request received • $requestCountLabel'
          : 'Topic request received: $cleanedTopic • $requestCountLabel',
    );
  }

  static void showTrackRequestSubmitted({
    required BuildContext context,
    required String trackTitle,
    required int newRequestCount,
    required AcademyRequestStorageBehavior storageBehavior,
  }) {
    final String cleanedTrackTitle = trackTitle.trim();

    final String requestCountLabel = _requestCountLabel(newRequestCount);

    _show(
      context: context,
      message: storageBehavior == AcademyRequestStorageBehavior.sessionOnly
          ? cleanedTrackTitle.isEmpty
                ? 'Track request saved to this debug session • $requestCountLabel'
                : '$cleanedTrackTitle request saved to this debug session • $requestCountLabel'
          : cleanedTrackTitle.isEmpty
          ? 'Academy track request received • $requestCountLabel'
          : '$cleanedTrackTitle Academy request received • $requestCountLabel',
    );
  }

  static void showRequestSubmissionUnavailable({
    required BuildContext context,
  }) {
    _show(
      context: context,
      message:
          'Academy requests are unavailable until durable storage is connected.',
    );
  }

  static void showRequestSubmissionFailed({required BuildContext context}) {
    _show(
      context: context,
      message: 'Academy could not save that request. Please try again.',
    );
  }

  static void showAdminActionUnavailable({required BuildContext context}) {
    _show(
      context: context,
      message: 'That Academy request could not be updated.',
    );
  }

  static void showAdminAction({
    required BuildContext context,
    required String message,
  }) {
    final String cleanedMessage = message.trim();

    _show(
      context: context,
      message: cleanedMessage.isEmpty
          ? 'Academy request updated.'
          : cleanedMessage,
    );
  }

  static String _requestCountLabel(int count) {
    final int safeCount = count < 0 ? 0 : count;

    if (safeCount == 1) {
      return '1 new admin request';
    }

    return '$safeCount new admin requests';
  }

  static void _show({required BuildContext context, required String message}) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
