import 'package:flutter/material.dart';

import '../../../academy/models/academy_request.dart';
import '../../../theme/atlas_spacing.dart';
import '../../atlas/atlas_glass_card.dart';
import 'academy_admin_inbox_header.dart';
import 'academy_admin_request_list.dart';

class AcademyAdminRequestInboxCard extends StatelessWidget {
  const AcademyAdminRequestInboxCard({
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
    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AcademyAdminInboxHeader(
            requestCount: requests.length,
          ),
          const SizedBox(
            height: AtlasSpacing.lg,
          ),
          AcademyAdminRequestList(
            requests: requests,
            onReviewTap: onReviewTap,
            onApproveTap: onApproveTap,
            onDeclineTap: onDeclineTap,
          ),
        ],
      ),
    );
  }
}