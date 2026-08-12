import 'package:flutter/material.dart';

import 'academy_roadmap_topic_preview_sheet.dart';

class AcademyRoadmapTopicPreviewLauncher {
  const AcademyRoadmapTopicPreviewLauncher._();

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool isPremium,
  }) async {
    final String cleanedTitle = title.trim();
    final String cleanedSubtitle = subtitle.trim();

    if (cleanedTitle.isEmpty) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return AcademyRoadmapTopicPreviewSheet(
          title: cleanedTitle,
          subtitle: cleanedSubtitle,
          isPremium: isPremium,
        );
      },
    );
  }
}