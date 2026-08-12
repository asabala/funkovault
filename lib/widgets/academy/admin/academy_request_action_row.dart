import 'package:flutter/material.dart';

import '../../../academy/models/academy_request.dart';
import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';

class AcademyRequestActionRow extends StatelessWidget {
  const AcademyRequestActionRow({
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

  bool get _canReview {
    return request.status ==
        AcademyRequestStatus.newRequest;
  }

  bool get _canResolve {
    return request.status ==
        AcademyRequestStatus.newRequest ||
        request.status ==
            AcademyRequestStatus.reviewed;
  }

  bool get _isResolved {
    return request.status ==
        AcademyRequestStatus.approved ||
        request.status ==
            AcademyRequestStatus.declined;
  }

  @override
  Widget build(BuildContext context) {
    if (_isResolved) {
      return Row(
        children: [
          Icon(
            request.status ==
                AcademyRequestStatus.approved
                ? Icons.check_circle_outline_rounded
                : Icons.cancel_outlined,
            size: 18,
            color: request.status ==
                AcademyRequestStatus.approved
                ? AtlasColors.success
                : AtlasColors.warning,
          ),
          const SizedBox(
            width: AtlasSpacing.sm,
          ),
          Text(
            request.statusLabel,
            style: TextStyle(
              color: request.status ==
                  AcademyRequestStatus.approved
                  ? AtlasColors.success
                  : AtlasColors.warning,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }

    return Wrap(
      spacing: AtlasSpacing.sm,
      runSpacing: AtlasSpacing.sm,
      children: [
        OutlinedButton.icon(
          onPressed:
          _canReview ? onReviewTap : null,
          icon: const Icon(
            Icons.visibility_outlined,
            size: 18,
          ),
          label: Text(
            request.status ==
                AcademyRequestStatus.reviewed
                ? 'Reviewed'
                : 'Review',
          ),
        ),
        FilledButton.icon(
          onPressed:
          _canResolve ? onApproveTap : null,
          icon: const Icon(
            Icons.check_rounded,
            size: 18,
          ),
          label: const Text(
            'Approve',
          ),
        ),
        TextButton.icon(
          onPressed:
          _canResolve ? onDeclineTap : null,
          icon: const Icon(
            Icons.close_rounded,
            size: 18,
          ),
          label: const Text(
            'Decline',
          ),
        ),
      ],
    );
  }
}