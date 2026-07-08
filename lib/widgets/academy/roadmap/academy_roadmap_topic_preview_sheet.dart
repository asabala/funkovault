import 'package:flutter/material.dart';

import '../shared/academy_premium_insight_card.dart';

class AcademyRoadmapTopicPreviewSheet extends StatelessWidget {
  const AcademyRoadmapTopicPreviewSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isPremium,
  });

  final String title;
  final String subtitle;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isPremium ? 'Premium Academy Topic' : 'Academy Roadmap Topic',
              style: const TextStyle(
                color: Color(0xFFD6B25E),
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            if (isPremium)
              const AcademyPremiumInsightCard()
            else
              Text(
                'This topic is planned for a future Atlas Academy lesson.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
          ],
        ),
      ),
    );
  }
}