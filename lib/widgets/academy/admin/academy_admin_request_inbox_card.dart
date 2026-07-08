import 'package:flutter/material.dart';

import '../../../academy/models/academy_request.dart';
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AcademyAdminInboxHeader(
            requestCount: requests.length,
          ),
          const SizedBox(height: 16),
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