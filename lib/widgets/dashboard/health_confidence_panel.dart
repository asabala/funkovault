import 'package:flutter/material.dart';

class HealthConfidencePanel extends StatelessWidget {
  const HealthConfidencePanel({
    super.key,
    required this.health,
    required this.confidence,
    this.onHealthTap,
    this.onConfidenceTap,
  });

  final double health;
  final double confidence;

  final VoidCallback? onHealthTap;
  final VoidCallback? onConfidenceTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            title: 'Vault Health',
            value: '${health.toStringAsFixed(0)}%',
            icon: Icons.favorite,
            onTap: onHealthTap,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _MetricCard(
            title: 'Atlas Confidence',
            value: '${confidence.toStringAsFixed(0)}%',
            icon: Icons.psychology,
            onTap: onConfidenceTap,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
          child: Column(
            children: [
              Icon(icon, size: 34),

              const SizedBox(height: 12),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
