import 'package:flutter/material.dart';

import 'academy_roadmap_topic_preview_sheet.dart';

class AcademyRoadmapTopicPreviewLauncher {
  const AcademyRoadmapTopicPreviewLauncher._();

  static void show({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool isPremium,
  }) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: const Color(0xFF1A1A1A),
      builder: (_) {
        return AcademyRoadmapTopicPreviewSheet(
          title: title,
          subtitle: subtitle,
          isPremium: isPremium,
        );
      },
    );
  }
}