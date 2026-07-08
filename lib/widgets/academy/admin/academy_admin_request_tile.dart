import 'package:flutter/material.dart';

import '../../../academy/models/academy_request.dart';
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AcademyRequestBadgeRow(
            request: request,
          ),
          const SizedBox(height: 10),
          Text(
            request.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            request.source,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.58),
              fontSize: 12,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          AcademyRequestActionRow(
            onReviewTap: onReviewTap,
            onApproveTap: onApproveTap,
            onDeclineTap: onDeclineTap,
          ),
        ],
      ),
    );
  }
}