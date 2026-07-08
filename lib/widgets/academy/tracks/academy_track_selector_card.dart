import 'package:flutter/material.dart';

class AcademyTrackSelectorCard extends StatelessWidget {
  const AcademyTrackSelectorCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.tracks,
    required this.selectedTrackId,
    required this.onTrackSelected,
  });

  final String title;
  final String subtitle;
  final List<AcademyTrackSelectorItem> tracks;
  final String selectedTrackId;
  final ValueChanged<String> onTrackSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.18),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: tracks.map((track) {
                  final isSelected = track.id == selectedTrackId;

                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _TrackChip(
                      track: track,
                      isSelected: isSelected,
                      onTap: () => onTrackSelected(track.id),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AcademyTrackSelectorItem {
  const AcademyTrackSelectorItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isAvailable,
    this.badge,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isAvailable;
  final String? badge;
}

class _TrackChip extends StatelessWidget {
  const _TrackChip({
    required this.track,
    required this.isSelected,
    required this.onTap,
  });

  final AcademyTrackSelectorItem track;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final backgroundColor = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.68);

    final foregroundColor = isSelected
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;

    final borderColor = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.outline.withValues(alpha: 0.16);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 190,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  track.icon,
                  size: 20,
                  color: foregroundColor,
                ),
                const Spacer(),
                if (track.badge != null)
                  _TrackBadge(
                    label: track.badge!,
                    isSelected: isSelected,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              track.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              track.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: foregroundColor.withValues(alpha: 0.78),
                height: 1.25,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  track.isAvailable
                      ? Icons.check_circle_rounded
                      : Icons.lock_clock_rounded,
                  size: 16,
                  color: foregroundColor.withValues(alpha: 0.84),
                ),
                const SizedBox(width: 6),
                Text(
                  track.isAvailable ? 'Available' : 'Coming Soon',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: foregroundColor.withValues(alpha: 0.84),
                    fontWeight: FontWeight.w700,
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

class _TrackBadge extends StatelessWidget {
  const _TrackBadge({
    required this.label,
    required this.isSelected,
  });

  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.onPrimary.withValues(alpha: 0.16)
            : theme.colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: isSelected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}