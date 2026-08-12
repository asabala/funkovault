import 'package:flutter/material.dart';

import '../../../academy/models/academy_request.dart';
import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_typography.dart';
import '../../atlas/atlas_glass_card.dart';
import 'academy_request_action_row.dart';
import 'academy_request_badge_row.dart';

class AcademyAdminRequestTile extends StatelessWidget {
  const AcademyAdminRequestTile({
    super.key,
    required this.request,
    required this.onReviewTap,
    required this.onApproveTap,
    required this.onDeclineTap,
  });

  final AcademyRequest request;
  final VoidCallback onReviewTap;
  final VoidCallback onApproveTap;
  final VoidCallback onDeclineTap;

  @override
  Widget build(BuildContext context) {
    final String title =
    request.title.trim();

    final String source =
    request.source.trim();

    return AtlasGlassCard(
      accentColor:
      AtlasColors.intelligenceBlue,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          AcademyRequestBadgeRow(
            request: request,
          ),
          const SizedBox(
            height: AtlasSpacing.md,
          ),
          Text(
            title.isEmpty
                ? 'Academy Request'
                : title,
            style:
            AtlasTypography.headingSmall,
          ),
          const SizedBox(
            height: AtlasSpacing.xs,
          ),
          Text(
            source.isEmpty
                ? 'Atlas Academy'
                : source,
            style:
            AtlasTypography.bodySmall.copyWith(
              color:
              AtlasColors.textSecondary,
              height: 1.3,
            ),
          ),
          const SizedBox(
            height: AtlasSpacing.md,
          ),
          AcademyRequestActionRow(
            request: request,
            onReviewTap: onReviewTap,
            onApproveTap: onApproveTap,
            onDeclineTap: onDeclineTap,
          ),
        ],
      ),
    );
  }
}