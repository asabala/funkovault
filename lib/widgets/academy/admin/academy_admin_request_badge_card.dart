import 'package:flutter/material.dart';

class AcademyAdminRequestBadgeCard extends StatelessWidget {
  const AcademyAdminRequestBadgeCard({
    super.key,
    required this.newRequestCount,
  });

  final int newRequestCount;

  @override
  Widget build(BuildContext context) {
    final hasNewRequests = newRequestCount > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasNewRequests
            ? const Color(0xFFD6B25E).withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: hasNewRequests
              ? const Color(0xFFD6B25E).withValues(alpha: 0.28)
              : Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: hasNewRequests
                  ? const Color(0xFFD6B25E).withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              hasNewRequests
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_none_rounded,
              color: hasNewRequests
                  ? const Color(0xFFD6B25E)
                  : Colors.white.withValues(alpha: 0.58),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasNewRequests
                      ? '$newRequestCount new Academy request(s)'
                      : 'No new Academy requests',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasNewRequests
                      ? 'Review requested topics and future track interest.'
                      : 'Topic and track requests will appear here when submitted.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}