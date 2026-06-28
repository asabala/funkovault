import 'package:flutter/material.dart';

class AtlasPriorityChip extends StatelessWidget {
  const AtlasPriorityChip({
    super.key,
    required this.severity,
  });

  final String severity;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String text;

    switch (severity) {
      case 'High':
        icon = Icons.warning;
        color = Colors.red;
        text = 'HIGH';
        break;

      case 'Medium':
        icon = Icons.error_outline;
        color = Colors.orange;
        text = 'MEDIUM';
        break;

      default:
        icon = Icons.check_circle_outline;
        color = Colors.green;
        text = 'LOW';
    }

    return Chip(
      avatar: Icon(
        icon,
        size: 18,
        color: Colors.white,
      ),
      label: Text(text),
      backgroundColor: color,
      labelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}