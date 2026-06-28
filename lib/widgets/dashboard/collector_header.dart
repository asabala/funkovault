import 'package:flutter/material.dart';

class CollectorHeader extends StatelessWidget {
  const CollectorHeader({
    super.key,
    required this.collectorName,
    required this.status,
  });

  final String collectorName;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              '🛡️ ATLAS',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Good ${_dayPart()}, $collectorName',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            Chip(
              avatar: const Icon(Icons.verified_user),
              label: Text(status),
            ),
          ],
        ),
      ),
    );
  }

  String _dayPart() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Morning';
    }

    if (hour < 17) {
      return 'Afternoon';
    }

    return 'Evening';
  }
}