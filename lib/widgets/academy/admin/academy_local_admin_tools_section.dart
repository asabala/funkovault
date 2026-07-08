import 'package:flutter/material.dart';

import '../../../academy/models/academy_request.dart';
import 'academy_admin_request_badge_card.dart';
import 'academy_admin_request_inbox_card.dart';

class AcademyLocalAdminToolsSection extends StatelessWidget {
  const AcademyLocalAdminToolsSection({
    super.key,
    required this.newRequestCount,
    required this.requests,
    required this.onReviewTap,
    required this.onApproveTap,
    required this.onDeclineTap,
  });

  final int newRequestCount;
  final List<AcademyRequest> requests;
  final ValueChanged<AcademyRequest> onReviewTap;
  final ValueChanged<AcademyRequest> onApproveTap;
  final ValueChanged<AcademyRequest> onDeclineTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AcademyAdminRequestBadgeCard(
          newRequestCount: newRequestCount,
        ),
        const SizedBox(height: 12),
        AcademyAdminRequestInboxCard(
          requests: requests,
          onReviewTap: onReviewTap,
          onApproveTap: onApproveTap,
          onDeclineTap: onDeclineTap,
        ),
      ],
    );
  }
}