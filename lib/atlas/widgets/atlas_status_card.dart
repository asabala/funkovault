import 'package:flutter/material.dart';

import '../services/atlas_service.dart';

class AtlasStatusCard extends StatelessWidget {
  const AtlasStatusCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(
                  Icons.shield,
                  color: Colors.blue,
                  size: 32,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Powered by Atlas',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Text(
              'Collector Intelligence Engine',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            _StatusRow(
              label: 'Status',
              value: 'Online',
              color: Colors.green,
            ),

            _StatusRow(
              label: 'Version',
              value: AtlasService.version,
            ),

            _StatusRow(
              label: 'Learning',
              value: 'Enabled',
            ),

            _StatusRow(
              label: 'Knowledge',
              value: 'Ready',
            ),

            const SizedBox(height: 16),

            Text(
              AtlasService.motto,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Atlas Command Center coming soon...',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.smart_toy),
                label: const Text(
                  'Open Atlas',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _StatusRow({
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}