import 'package:flutter/material.dart';

class AcademySnackbars {
  const AcademySnackbars._();

  static void showComingSoonTrack({
    required BuildContext context,
    required String trackTitle,
  }) {
    _show(
      context: context,
      message: '$trackTitle Academy is coming soon.',
    );
  }

  static void showTopicRequestReceived({
    required BuildContext context,
    required String topic,
    required int newRequestCount,
  }) {
    _show(
      context: context,
      message:
      'Topic request received: $topic • $newRequestCount new admin request(s)',
    );
  }

  static void showTrackRequestReceived({
    required BuildContext context,
    required String trackTitle,
    required int newRequestCount,
  }) {
    _show(
      context: context,
      message:
      '$trackTitle Academy request received • $newRequestCount new admin request(s)',
    );
  }

  static void showAdminAction({
    required BuildContext context,
    required String message,
  }) {
    _show(
      context: context,
      message: message,
    );
  }

  static void _show({
    required BuildContext context,
    required String message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}