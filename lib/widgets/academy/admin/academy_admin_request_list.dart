import 'package:flutter/material.dart';

import '../../../academy/config/academy_admin_ui_config.dart';
import '../../../academy/models/academy_request.dart';
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
    final visibleRequests = requests
        .take(AcademyAdminUiConfig.maxVisibleInboxRequests)
        .toList();

    final hiddenRequestCount = requests.length - visibleRequests.length;

    if (visibleRequests.isEmpty) {
      return const AcademyAdminEmptyInboxState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final request in visibleRequests) ...[
          AcademyAdminRequestTile(
            request: request,
            onReviewTap: () => onReviewTap(request),
            onApproveTap: () => onApproveTap(request),
            onDeclineTap: () => onDeclineTap(request),
          ),
          const SizedBox(height: 10),
        ],
        if (hiddenRequestCount > 0) ...[
          const SizedBox(height: 4),
          AcademyAdminMoreRequestsLabel(
            hiddenRequestCount: hiddenRequestCount,
          ),
        ],
      ],
    );
  }
}