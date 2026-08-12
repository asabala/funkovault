import 'package:flutter/material.dart';

class AcademySnackbars {
  const AcademySnackbars._();

  static void showComingSoonTrack({
    required BuildContext context,
    required String trackTitle,
  }) {
    final String cleanedTrackTitle =
    trackTitle.trim();

    _show(
      context: context,
      message: cleanedTrackTitle.isEmpty
          ? 'This Academy track is coming soon.'
          : '$cleanedTrackTitle Academy is coming soon.',
    );
  }

  static void showTopicRequestReceived({
    required BuildContext context,
    required String topic,
    required int newRequestCount,
  }) {
    final String cleanedTopic =
    topic.trim();

    final String requestCountLabel =
    _requestCountLabel(
      newRequestCount,
    );

    _show(
      context: context,
      message: cleanedTopic.isEmpty
          ? 'Academy topic request received • $requestCountLabel'
          : 'Topic request received: $cleanedTopic • $requestCountLabel',
    );
  }

  static void showTrackRequestReceived({
    required BuildContext context,
    required String trackTitle,
    required int newRequestCount,
  }) {
    final String cleanedTrackTitle =
    trackTitle.trim();

    final String requestCountLabel =
    _requestCountLabel(
      newRequestCount,
    );

    _show(
      context: context,
      message: cleanedTrackTitle.isEmpty
          ? 'Academy track request received • $requestCountLabel'
          : '$cleanedTrackTitle Academy request received • $requestCountLabel',
    );
  }

  static void showAdminAction({
    required BuildContext context,
    required String message,
  }) {
    final String cleanedMessage =
    message.trim();

    _show(
      context: context,
      message: cleanedMessage.isEmpty
          ? 'Academy request updated.'
          : cleanedMessage,
    );
  }

  static String _requestCountLabel(
      int count,
      ) {
    final int safeCount =
    count < 0 ? 0 : count;

    if (safeCount == 1) {
      return '1 new admin request';
    }

    return '$safeCount new admin requests';
  }

  static void _show({
    required BuildContext context,
    required String message,
  }) {
    final ScaffoldMessengerState messenger =
    ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
        behavior:
        SnackBarBehavior.floating,
      ),
    );
  }
}