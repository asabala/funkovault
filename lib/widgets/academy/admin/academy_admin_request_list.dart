import 'package:flutter/material.dart';

import '../../../academy/config/academy_admin_ui_config.dart';
import '../../../academy/models/academy_request.dart';
import '../../../theme/atlas_spacing.dart';
import 'academy_admin_empty_inbox_state.dart';
import 'academy_admin_more_requests_label.dart';
import 'academy_admin_request_tile.dart';

class AcademyAdminRequestList extends StatelessWidget {
  const AcademyAdminRequestList({
    super.key,
    required this.requests,
    required this.onReviewTap,
    required this.onApproveTap,
    required this.onDeclineTap,
  });

  final List<AcademyRequest> requests;
  final ValueChanged<AcademyRequest> onReviewTap;
  final ValueChanged<AcademyRequest> onApproveTap;
  final ValueChanged<AcademyRequest> onDeclineTap;

  @override
  Widget build(BuildContext context) {
    final List<AcademyRequest> visibleRequests = requests
        .take(AcademyAdminUiConfig.maxVisibleInboxRequests)
        .toList(growable: false);

    final int hiddenRequestCount = requests.length - visibleRequests.length;

    if (visibleRequests.isEmpty) {
      return const AcademyAdminEmptyInboxState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int index = 0; index < visibleRequests.length; index++) ...[
          AcademyAdminRequestTile(
            request: visibleRequests[index],
            onReviewTap: () {
              onReviewTap(visibleRequests[index]);
            },
            onApproveTap: () {
              onApproveTap(visibleRequests[index]);
            },
            onDeclineTap: () {
              onDeclineTap(visibleRequests[index]);
            },
          ),
          if (index != visibleRequests.length - 1)
            const SizedBox(height: AtlasSpacing.sm),
        ],
        if (hiddenRequestCount > 0) ...[
          const SizedBox(height: AtlasSpacing.md),
          AcademyAdminMoreRequestsLabel(hiddenRequestCount: hiddenRequestCount),
        ],
      ],
    );
  }
}
