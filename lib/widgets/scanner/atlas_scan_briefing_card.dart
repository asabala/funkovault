import 'package:flutter/material.dart';

import '../../atlas/scan/briefing/atlas_scan_briefing.dart';

class AtlasScanBriefingCard extends StatelessWidget {
  const AtlasScanBriefingCard({
    required this.briefing,
    super.key,
  });

  final AtlasScanBriefing briefing;

  @override
  Widget build(BuildContext context) {
    final IconData icon = _iconFor(
      briefing.priority,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: 30,
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Text(
                    briefing.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            Text(
              briefing.summary,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (briefing.hasHighlights) ...[
              const SizedBox(
                height: 18,
              ),
              Text(
                'What Atlas Found',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              for (final String highlight
              in briefing.highlights)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 8,
                  ),
                  child: Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(
                          top: 2,
                        ),
                        child: Icon(
                          Icons.check_circle_outline_rounded,
                          size: 18,
                        ),
                      ),
                      const SizedBox(
                        width: 9,
                      ),
                      Expanded(
                        child: Text(
                          highlight,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            const Divider(
              height: 28,
            ),
            Text(
              'Atlas Recommendation',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              briefing.recommendation,
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(
      AtlasScanBriefingPriority priority,
      ) {
    switch (priority) {
      case AtlasScanBriefingPriority.success:
        return Icons.auto_awesome_rounded;

      case AtlasScanBriefingPriority.information:
        return Icons.info_outline_rounded;

      case AtlasScanBriefingPriority.warning:
        return Icons.warning_amber_rounded;

      case AtlasScanBriefingPriority.critical:
        return Icons.error_outline_rounded;
    }
  }
}