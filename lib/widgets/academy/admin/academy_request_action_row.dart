import 'package:flutter/material.dart';

class AcademyRequestActionRow extends StatelessWidget {
  const AcademyRequestActionRow({
    super.key,
    required this.onReviewTap,
    required this.onApproveTap,
    required this.onDeclineTap,
  });

  final VoidCallback onReviewTap;
  final VoidCallback onApproveTap;
  final VoidCallback onDeclineTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(
          onPressed: onReviewTap,
          child: const Text('Review'),
        ),
        const SizedBox(width: 4),
        TextButton(
          onPressed: onApproveTap,
          child: const Text('Approve'),
        ),
        const SizedBox(width: 4),
        TextButton(
          onPressed: onDeclineTap,
          child: const Text('Decline'),
        ),
      ],
    );
  }
}