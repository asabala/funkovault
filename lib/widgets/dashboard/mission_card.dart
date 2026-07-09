import 'package:flutter/material.dart';

import '../vault/atlas_priority_chip.dart';

class MissionCard extends StatelessWidget {
  const MissionCard({
    super.key,
    required this.title,
    required this.description,
    required this.reward,
    required this.estimatedTime,
    required this.severity,
  });

  final String title;
  final String description;
  final String reward;
  final String estimatedTime;
  final String severity;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flag),
                const SizedBox(width: 8),
                const Text(
                  "Today's Mission",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                AtlasPriorityChip(
                  severity: severity,
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(description),

            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 18),
                const SizedBox(width: 6),
                Text(
                  estimatedTime,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.card_giftcard, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    reward,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}